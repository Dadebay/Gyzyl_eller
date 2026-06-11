// ignore_for_file: empty_catches

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/job_notification_controller.dart';
import 'package:location/location.dart' as loc;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/models/my_tasks_order_by.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';

class TaskController extends GetxController {
  final MyJobsService _jobsService = MyJobsService();

  // state for tab 1 (requestedInput=true)
  final RxList<JobModel> requestedJobs = <JobModel>[].obs;
  final RxInt requestedTotalCount = 0.obs;
  final RxBool isRequestedLoading = false.obs;
  final RxBool isRequestedFirstLoad = true.obs;
  final RxBool hasRequestedMore = true.obs;
  int _requestedPage = 0;
  final RefreshController requestedRefreshController =
      RefreshController(initialRefresh: false);

  // state for tab 2 (processingInput=true)
  final RxList<JobModel> processingJobs = <JobModel>[].obs;
  final RxInt processingTotalCount = 0.obs;
  final RxBool isProcessingLoading = false.obs;
  final RxBool isProcessingFirstLoad = true.obs;
  final RxBool hasProcessingMore = true.obs;
  int _processingPage = 0;
  final RefreshController processingRefreshController =
      RefreshController(initialRefresh: false);

  final RxDouble userBalance = 0.0.obs;
  final RxBool isLoggedIn = false.obs;

  final Rx<MyTasksOrderBy> orderBy = MyTasksOrderBy.sene.obs;
  final RxnInt status = RxnInt(null);

  // Location for nearest sort
  final _locationPlugin = loc.Location();
  double? _currentLat;
  double? _currentLng;

  // Track active tab index
  final RxInt activeTabIndex = 0.obs;

  // Prevents fetchNotificationCounters from firing during tab-switch-triggered refreshes
  bool _skipNextNotifRefresh = false;

  void setSkipNextNotifRefresh() {
    _skipNextNotifRefresh = true;
  }

  // Filter state for tab 1 (requested / Tekliplerim)
  final RxList<int> reqCatIds = <int>[].obs;
  final RxList<int> reqWelayatIds = <int>[].obs;
  final RxList<int> reqEtrapIds = <int>[].obs;
  final RxnDouble reqMinPrice = RxnDouble(null);
  final RxnDouble reqMaxPrice = RxnDouble(null);
  final RxList<DateTime> reqSelectedDates = <DateTime>[].obs;
  final RxString reqSearch = "".obs;

  // Filter state for tab 2 (processing / Işlerim)
  final RxList<int> procCatIds = <int>[].obs;
  final RxList<int> procWelayatIds = <int>[].obs;
  final RxList<int> procEtrapIds = <int>[].obs;
  final RxnDouble procMinPrice = RxnDouble(null);
  final RxnDouble procMaxPrice = RxnDouble(null);
  final RxList<DateTime> procSelectedDates = <DateTime>[].obs;
  final RxString procSearch = "".obs;

  // Metadata
  final RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  final RxList<LocationModel> allLocations = <LocationModel>[].obs;

  final int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchMetadata();
    isLoggedIn.value = AuthStorage().isLoggedIn;
    fetchBalance();

    // Register sync callback so fetchNotificationCounters always has fresh data.
    // Uses Get.find at call-time (not capture-time) so a re-created controller
    // instance is always used instead of a stale disposed one.
    if (Get.isRegistered<JobNotificationController>()) {
      Get.find<JobNotificationController>().registerOtherSelectedSync(() {
        if (!Get.isRegistered<TaskController>()) return;
        final tc = Get.find<TaskController>();
        // requestedJobs boşsa (API henüz dönmedi veya controller yeni oluşturuldu)
        // senkronizasyonu atla — eski doğru veriyi silmemek için.
        if (tc.requestedJobs.isEmpty) return;
        tc.syncOtherSelectedJobIds();
      });
    }

    // Auto load the first tab initially. Let the View call the second tab if needed.
    fetchRequestedJobs(isRefresh: true);
    fetchProcessingJobs(isRefresh: true);
  }

  Future<void> fetchBalance() async {
    try {
      final balance = await _jobsService.fetchBalance();
      userBalance.value = balance;
    } catch (e) {}
  }

  Future<void> fetchMetadata() async {
    final categories = await _jobsService.getCategories();
    allCategories.assignAll(categories);

    final locations = await _jobsService.getLocations();
    allLocations.assignAll(locations);
  }

  Future<void> fetchRequestedJobs({bool isRefresh = false}) async {
    if (isRequestedLoading.value) return;

    if (isRefresh) {
      _requestedPage = 0;
      requestedRefreshController.resetNoData(); // 🔄 Reset pagination state
      // Don't set isRequestedFirstLoad to true on refresh to avoid showing loading spinner
      fetchBalance();
    }

    isRequestedLoading.value = true;

    try {
      debugPrint(
          '[TaskController][Requested] API start page=$_requestedPage isRefresh=$isRefresh selected=false status=${status.value} sort=${orderBy.value.apiValue}');
      final response = await _jobsService.getMyJobs(
        page: _requestedPage,
        limit: _limit,
        status: status.value,
        sort: orderBy.value.apiValue,
        lat: orderBy.value == MyTasksOrderBy.nearest ? _currentLat : null,
        lng: orderBy.value == MyTasksOrderBy.nearest ? _currentLng : null,
        requestedInput: true,
        selected: false,
        requiresToken: true,
        catIds: reqCatIds,
        welayatIds: reqWelayatIds,
        etrapIds: reqEtrapIds,
        dates: reqSelectedDates,
        minPrice: reqMinPrice.value,
        maxPrice: reqMaxPrice.value,
        search: reqSearch.value,
      );
      debugPrint(
          '[TaskController][Requested] API success count=${response.data.count} jobs=${response.data.jobs.length} nextPage=${_requestedPage + 1}');

      if (isRefresh) {
        requestedJobs.clear();
      }

      requestedJobs.addAll(response.data.jobs);
      requestedTotalCount.value = response.data.count;
      hasRequestedMore.value = requestedJobs.length < requestedTotalCount.value;
      _requestedPage++;

      // Notify notification controller which jobs have another user selected
      syncOtherSelectedJobIds();

      // Fetch fresh notification counts AFTER job IDs are synced to avoid race condition.
      // Skip during tab-switch-triggered refreshes to preserve locally cleared badges.
      if (isRefresh) {
        final skip = _skipNextNotifRefresh;
        _skipNextNotifRefresh = false;
        if (!skip && Get.isRegistered<JobNotificationController>()) {
          Get.find<JobNotificationController>().fetchNotificationCounters();
        }
      }

      isRequestedFirstLoad.value = false;
      isRequestedLoading.value = false;

      if (isRefresh) {
        requestedRefreshController.refreshCompleted();
      } else {
        requestedRefreshController.loadComplete();
      }

      if (!hasRequestedMore.value) {
        requestedRefreshController.loadNoData();
      }
    } catch (e) {
      debugPrint('[TaskController][Requested] API error: $e');
      isRequestedLoading.value = false;
      isRequestedFirstLoad.value = false;
      if (isRefresh) {
        requestedRefreshController.refreshFailed();
      } else {
        requestedRefreshController.loadFailed();
      }
    }
  }

  Future<void> fetchProcessingJobs({bool isRefresh = false}) async {
    if (isProcessingLoading.value) return;

    if (isRefresh) {
      _processingPage = 0;
      processingRefreshController.resetNoData(); // 🔄 Reset pagination state
      // Don't set isProcessingFirstLoad to true on refresh to avoid showing loading spinner
      fetchBalance();
      // Consume the skip flag so it doesn't linger into the next fetchRequestedJobs call
      _skipNextNotifRefresh = false;
    }

    isProcessingLoading.value = true;

    try {
      debugPrint(
          '[TaskController][Processing] API start page=$_processingPage isRefresh=$isRefresh selected=true status=${status.value} sort=${orderBy.value.apiValue}');
      final response = await _jobsService.getMyJobs(
        page: _processingPage,
        limit: _limit,
        status: status.value,
        sort: orderBy.value.apiValue,
        lat: orderBy.value == MyTasksOrderBy.nearest ? _currentLat : null,
        lng: orderBy.value == MyTasksOrderBy.nearest ? _currentLng : null,
        processingInput: true,
        selected: true,
        requiresToken: true,
        catIds: procCatIds,
        welayatIds: procWelayatIds,
        etrapIds: procEtrapIds,
        dates: procSelectedDates,
        minPrice: procMinPrice.value,
        maxPrice: procMaxPrice.value,
        search: procSearch.value,
      );
      debugPrint(
          '[TaskController][Processing] API success count=${response.data.count} jobs=${response.data.jobs.length} nextPage=${_processingPage + 1}');

      if (isRefresh) {
        processingJobs.clear();
      }

      processingJobs.addAll(response.data.jobs);
      processingTotalCount.value = response.data.count;
      hasProcessingMore.value =
          processingJobs.length < processingTotalCount.value;
      _processingPage++;

      isProcessingFirstLoad.value = false;
      isProcessingLoading.value = false;

      if (isRefresh) {
        processingRefreshController.refreshCompleted();
      } else {
        processingRefreshController.loadComplete();
      }

      if (!hasProcessingMore.value) {
        processingRefreshController.loadNoData();
      }
    } catch (e) {
      debugPrint('[TaskController][Processing] API error: $e');
      isProcessingLoading.value = false;
      isProcessingFirstLoad.value = false;
      if (isRefresh) {
        processingRefreshController.refreshFailed();
      } else {
        processingRefreshController.loadFailed();
      }
    }
  }

  void changeOrderBy(MyTasksOrderBy value) {
    orderBy.value = value;
    status.value = value.statusFilter;
    if (value == MyTasksOrderBy.nearest) {
      _fetchLocationThenRefresh();
    } else {
      fetchRequestedJobs(isRefresh: true);
      fetchProcessingJobs(isRefresh: true);
    }
  }

  Future<void> _fetchLocationThenRefresh() async {
    try {
      bool serviceEnabled = await _locationPlugin.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationPlugin.requestService();
        if (!serviceEnabled) return;
      }
      loc.PermissionStatus permission = await _locationPlugin.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _locationPlugin.requestPermission();
        if (permission != loc.PermissionStatus.granted) return;
      }
      final locationData = await _locationPlugin.getLocation();
      _currentLat = locationData.latitude;
      _currentLng = locationData.longitude;
    } catch (e) {
      debugPrint('[TaskController] Location error: $e');
    }
    fetchRequestedJobs(isRefresh: true);
    fetchProcessingJobs(isRefresh: true);
  }

  void changeStatus(int? value) {
    status.value = value;
    fetchRequestedJobs(isRefresh: true);
    fetchProcessingJobs(isRefresh: true);
  }

  void applyFilters({
    required int tabIndex,
    List<int>? newCatIds,
    List<int>? newWelayatIds,
    List<int>? newEtrapIds,
    double? newMinPrice,
    double? newMaxPrice,
    List<DateTime>? newDates,
    String? newSearch,
  }) {
    if (tabIndex == 0) {
      // Requested tab
      if (newCatIds != null) {
        reqCatIds.assignAll(newCatIds);
      } else {
        reqCatIds.clear();
      }
      if (newWelayatIds != null) {
        reqWelayatIds.assignAll(newWelayatIds);
      } else {
        reqWelayatIds.clear();
      }
      if (newEtrapIds != null) {
        reqEtrapIds.assignAll(newEtrapIds);
      } else {
        reqEtrapIds.clear();
      }
      reqMinPrice.value = newMinPrice;
      reqMaxPrice.value = newMaxPrice;
      if (newDates != null) {
        reqSelectedDates.assignAll(newDates);
      } else {
        reqSelectedDates.clear();
      }
      if (newSearch != null) {
        reqSearch.value = newSearch;
      } else {
        reqSearch.value = "";
      }
      fetchRequestedJobs(isRefresh: true);
    } else {
      // Processing tab
      if (newCatIds != null) {
        procCatIds.assignAll(newCatIds);
      } else {
        procCatIds.clear();
      }
      if (newWelayatIds != null) {
        procWelayatIds.assignAll(newWelayatIds);
      } else {
        procWelayatIds.clear();
      }
      if (newEtrapIds != null) {
        procEtrapIds.assignAll(newEtrapIds);
      } else {
        procEtrapIds.clear();
      }
      procMinPrice.value = newMinPrice;
      procMaxPrice.value = newMaxPrice;
      if (newDates != null) {
        procSelectedDates.assignAll(newDates);
      } else {
        procSelectedDates.clear();
      }
      if (newSearch != null) {
        procSearch.value = newSearch;
      } else {
        procSearch.value = "";
      }
      fetchProcessingJobs(isRefresh: true);
    }
  }

  void clearFilters() {
    if (activeTabIndex.value == 0) {
      reqCatIds.clear();
      reqWelayatIds.clear();
      reqEtrapIds.clear();
      reqMinPrice.value = null;
      reqMaxPrice.value = null;
      reqSelectedDates.clear();
      reqSearch.value = "";
      fetchRequestedJobs(isRefresh: true);
    } else {
      procCatIds.clear();
      procWelayatIds.clear();
      procEtrapIds.clear();
      procMinPrice.value = null;
      procMaxPrice.value = null;
      procSelectedDates.clear();
      procSearch.value = "";
      fetchProcessingJobs(isRefresh: true);
    }
  }

  void syncOtherSelectedJobIds() {
    if (!Get.isRegistered<JobNotificationController>()) return;
    final user = AuthStorage().getUser();
    final myId = int.tryParse((user?['id'] ?? '').toString());
    if (myId == null) return;
    final ids = requestedJobs
        .where((j) =>
            j.status == 3 &&
            j.selectedUserId != null &&
            j.selectedUserId != myId &&
            !j.finished)
        .map((j) => j.id.toString())
        .toSet();
    Get.find<JobNotificationController>().updateOtherSelectedJobIds(ids);
  }

  bool get isAnyFilterActive {
    if (activeTabIndex.value == 0) {
      return reqCatIds.isNotEmpty ||
          reqWelayatIds.isNotEmpty ||
          reqEtrapIds.isNotEmpty;
    } else {
      return procCatIds.isNotEmpty ||
          procWelayatIds.isNotEmpty ||
          procEtrapIds.isNotEmpty;
    }
  }

  /// Refresh the currently active tab
  Future<void> refreshCurrentTab() async {
    if (activeTabIndex.value == 0) {
      await fetchRequestedJobs(isRefresh: true);
    } else {
      await fetchProcessingJobs(isRefresh: true);
    }
  }
}
