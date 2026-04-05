// ignore_for_file: empty_catches

import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
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

  // Track active tab index
  final RxInt activeTabIndex = 0.obs;

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
      isRequestedFirstLoad.value = true;
      fetchBalance();
    }

    isRequestedLoading.value = true;

    try {
      final response = await _jobsService.getMyJobs(
        page: _requestedPage,
        limit: _limit,
        status: status.value,
        sort: orderBy.value.apiValue,
        requestedInput: true,
        requiresToken: true,
        catIds: reqCatIds,
        welayatIds: reqWelayatIds,
        etrapIds: reqEtrapIds,
        dates: reqSelectedDates,
        minPrice: reqMinPrice.value,
        maxPrice: reqMaxPrice.value,
        search: reqSearch.value,
      );

      if (isRefresh) {
        requestedJobs.clear();
      }

      requestedJobs.addAll(response.data.jobs);
      requestedTotalCount.value = response.data.count;
      hasRequestedMore.value = requestedJobs.length < requestedTotalCount.value;
      _requestedPage++;

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
      isProcessingFirstLoad.value = true;
      fetchBalance();
    }

    isProcessingLoading.value = true;

    try {
      final response = await _jobsService.getMyJobs(
        page: _processingPage,
        limit: _limit,
        status: status.value,
        sort: orderBy.value.apiValue,
        processingInput: true,
        requiresToken: true,
        catIds: procCatIds,
        welayatIds: procWelayatIds,
        etrapIds: procEtrapIds,
        dates: procSelectedDates,
        minPrice: procMinPrice.value,
        maxPrice: procMaxPrice.value,
        search: procSearch.value,
      );

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
}
