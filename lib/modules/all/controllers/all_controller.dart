// ignore_for_file: empty_catches, avoid_print

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:location/location.dart' as loc;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/models/my_tasks_order_by.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/core/controllers/balance_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/job_notification_controller.dart';

class AllController extends GetxController {
  final MyJobsService _jobsService = MyJobsService();
  final GetStorage _storage = GetStorage();

  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxInt totalCount = 0.obs;

  final BalanceController _balanceController = Get.find<BalanceController>();
  RxDouble get userBalance => _balanceController.balance;
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFirstLoad = true.obs;
  final RxBool hasMore = true.obs;

  final Rx<MyTasksOrderBy> orderBy = MyTasksOrderBy.sene.obs;
  final RxnInt status = RxnInt(null);
  final RxBool isFetchingLocation = false.obs;
  final RxBool shouldShowFilterShowcase = false.obs;

  // Location for nearest sort
  final _locationPlugin = loc.Location();
  double? _currentLat;
  double? _currentLng;

  // Filter state
  final RxList<int> catIds = <int>[].obs;
  final RxList<int> welayatIds = <int>[].obs;
  final RxList<int> etrapIds = <int>[].obs;
  final RxnDouble minPrice = RxnDouble(null);
  final RxnDouble maxPrice = RxnDouble(null);
  final RxList<DateTime> selectedDates = <DateTime>[].obs;
  final RxString search = "".obs;
  final RxBool hasSavedSearch = false.obs;

  // Metadata
  final RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  final RxList<LocationModel> allLocations = <LocationModel>[].obs;

  int _page = 0;
  final int _limit = 20;
  bool _pendingRefresh = false;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void resetRefreshController() {
    refreshController.dispose();
    refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = AuthStorage().isLoggedIn;
    _loadFilters();

    // Keep notification count badge synchronized whenever jobs list changes
    ever(jobs, (_) {
      if (Get.isRegistered<JobNotificationController>()) {
        Get.find<JobNotificationController>().updateAllTabCount();
      }
    });

    // Listen to login/logout events to refresh filter state
    ever(isLoggedIn, (bool loggedIn) {
      print('🔄 [AllController] isLoggedIn changed to: $loggedIn');
      if (loggedIn) {
        fetchJobs(isRefresh: true);
      } else {
        clearFilters();
      }
    });

    // Initialize categories from API if logged in, otherwise start empty
    if (isLoggedIn.value) {
      fetchJobs(isRefresh: true);
    } else {
      fetchJobs(isRefresh: true);
    }

    // Fire other requests in parallel
    Future.wait([
      fetchMetadata(),
      fetchBalance(),
    ]);
  }

  void _saveFilters() {
    _storage.write('all_filter_catIds', catIds.toList());
    _storage.write('all_filter_welayatIds', welayatIds.toList());
    _storage.write('all_filter_etrapIds', etrapIds.toList());
    _storage.write('all_filter_minPrice', minPrice.value);
    _storage.write('all_filter_maxPrice', maxPrice.value);
    _storage.write('all_filter_dates',
        selectedDates.map((d) => d.toIso8601String()).toList());
    _storage.write('all_filter_search', search.value);
    // Dates are session-only — not persisted.
  }

  void _loadFilters() {
    try {
      // For guest users, do not persist filters between app launches.
      if (!AuthStorage().isLoggedIn) {
        _clearPersistedFilters();
        return;
      }

      final savedCatIds = _storage.read<List>('all_filter_catIds');
      if (savedCatIds != null) {
        catIds.assignAll(savedCatIds.cast<int>());
      }

      final savedWelayatIds = _storage.read<List>('all_filter_welayatIds');
      if (savedWelayatIds != null) {
        welayatIds.assignAll(savedWelayatIds.cast<int>());
      }

      final savedEtrapIds = _storage.read<List>('all_filter_etrapIds');
      if (savedEtrapIds != null) {
        etrapIds.assignAll(savedEtrapIds.cast<int>());
      }

      final savedMinPrice = _storage.read<double>('all_filter_minPrice');
      minPrice.value = (savedMinPrice == 0) ? null : savedMinPrice;

      final savedMaxPrice = _storage.read<double>('all_filter_maxPrice');
      maxPrice.value = (savedMaxPrice == 1000000) ? null : savedMaxPrice;

      final savedDates = _storage.read<List>('all_filter_dates');
      if (savedDates != null) {
        selectedDates.assignAll(
            savedDates.map((d) => DateTime.parse(d as String)).toList());
      }

      search.value = _storage.read<String>('all_filter_search') ?? "";
    } catch (_) {
      clearFilters();
    }
  }

  void _clearPersistedFilters() {
    _storage.remove('all_filter_catIds');
    _storage.remove('all_filter_welayatIds');
    _storage.remove('all_filter_etrapIds');
    _storage.remove('all_filter_minPrice');
    _storage.remove('all_filter_maxPrice');
    _storage.remove('all_filter_dates');
    _storage.remove('all_filter_search');

    catIds.clear();
    welayatIds.clear();
    etrapIds.clear();
    minPrice.value = null;
    maxPrice.value = null;
    selectedDates.clear();
    search.value = "";
  }

  Future<void> fetchBalance() async {
    await _balanceController.fetchBalance();
  }

  Future<void> fetchMetadata() async {
    // Only fetch if empty to save time on tab switches
    if (allCategories.isNotEmpty && allLocations.isNotEmpty) return;

    try {
      final results = await Future.wait([
        _jobsService.getCategories(),
        _jobsService.getLocations(),
      ]);

      allCategories.assignAll(results[0] as List<CategoryModel>);
      allLocations.assignAll(results[1] as List<LocationModel>);
    } catch (e) {}
  }

  Future<void> fetchJobs({bool isRefresh = false}) async {
    if (isLoading.value) {
      if (isRefresh) {
        _pendingRefresh = true;
      }
      return;
    }

    if (isRefresh) {
      _page = 0;
      // 🔄 Reset pagination state on refresh
      refreshController.resetNoData();

      // Only show full screen loader if we have no data at all
      if (jobs.isEmpty) {
        isFirstLoad.value = true;
      }
      fetchBalance();
      if (Get.isRegistered<JobNotificationController>()) {
        Get.find<JobNotificationController>().fetchNotificationCounters();
      }
    }

    isLoading.value = true;

    try {
      debugPrint(
          '[AllController] fetchJobs → sort=${orderBy.value.apiValue} lat=$_currentLat lng=$_currentLng page=$_page');
      final response = await _jobsService.getMyJobs(
        page: _page,
        limit: _limit,
        status: status.value,
        sort: orderBy.value.apiValue,
        lat: orderBy.value == MyTasksOrderBy.nearest ? _currentLat : null,
        lng: orderBy.value == MyTasksOrderBy.nearest ? _currentLng : null,
        requiresToken: true,
        catIds: catIds,
        welayatIds: welayatIds,
        etrapIds: etrapIds,
        dates: selectedDates,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        search: search.value,
      );

      if (isRefresh) {
        jobs.clear();
      }

      jobs.addAll(response.data.jobs);
      totalCount.value = response.data.count;
      hasMore.value = jobs.length < totalCount.value;
      _page++;

      isFirstLoad.value = false;
      isLoading.value = false;

      if (isRefresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }

      if (!hasMore.value) {
        refreshController.loadNoData();
      }
    } catch (e, st) {
      debugPrint('[AllController] fetchJobs ERROR: $e');
      debugPrint('[AllController] fetchJobs STACKTRACE: $st');
      isLoading.value = false;
      isFirstLoad.value = false;
      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
    }

    if (_pendingRefresh && !isLoading.value) {
      _pendingRefresh = false;
      Future.microtask(() => fetchJobs(isRefresh: true));
    }
  }

  void changeOrderBy(MyTasksOrderBy value) {
    orderBy.value = value;
    status.value = value.statusFilter;
    if (value == MyTasksOrderBy.nearest) {
      // If we already have a cached location, skip re-fetching
      if (_currentLat != null && _currentLng != null) {
        fetchJobs(isRefresh: true);
      } else {
        _fetchLocationThenRefresh();
      }
    } else {
      fetchJobs(isRefresh: true);
    }
  }

  Future<void> _fetchLocationThenRefresh() async {
    isFetchingLocation.value = true;
    try {
      bool serviceEnabled = await _locationPlugin.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationPlugin.requestService();
        if (!serviceEnabled) {
          isFetchingLocation.value = false;
          isLoading.value = false;
          fetchJobs(isRefresh: true);
          return;
        }
      }
      loc.PermissionStatus permission = await _locationPlugin.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _locationPlugin.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          isFetchingLocation.value = false;
          isLoading.value = false;
          fetchJobs(isRefresh: true);
          return;
        }
      }
      await _locationPlugin.changeSettings(
        accuracy: loc.LocationAccuracy.low,
        interval: 500,
        distanceFilter: 0,
      );
      final locationData = await _locationPlugin.getLocation().timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw Exception('Location timeout'),
          );
      _currentLat = locationData.latitude;
      _currentLng = locationData.longitude;
      debugPrint('[AllController] Location: $_currentLat, $_currentLng');
    } catch (e) {
      debugPrint('[AllController] Location error: $e');
    }
    isFetchingLocation.value = false;
    // Reset loading guard in case a previous fetch was still marked as loading
    isLoading.value = false;
    fetchJobs(isRefresh: true);
  }

  void changeStatus(int? value) {
    status.value = value;
    fetchJobs(isRefresh: true);
  }

  void applyFilters({
    List<int>? newCatIds,
    List<int>? newWelayatIds,
    List<int>? newEtrapIds,
    double? newMinPrice,
    double? newMaxPrice,
    List<DateTime>? newDates,
    String? newSearch,
  }) {
    if (newCatIds != null) {
      catIds.assignAll(newCatIds);
    } else {
      catIds.clear();
    }
    if (newWelayatIds != null) {
      welayatIds.assignAll(newWelayatIds);
    } else {
      welayatIds.clear();
    }
    if (newEtrapIds != null) {
      etrapIds.assignAll(newEtrapIds);
    } else {
      etrapIds.clear();
    }
    minPrice.value = newMinPrice;
    maxPrice.value = newMaxPrice;
    if (newDates != null) {
      selectedDates.assignAll(newDates);
    } else {
      selectedDates.clear();
    }
    if (newSearch != null) {
      search.value = newSearch;
    } else {
      search.value = "";
    }

    _saveFilters();
    hasSavedSearch.value = isAnyFilterActive;
    fetchJobs(isRefresh: true);
  }

  void clearFilters() {
    catIds.clear();
    welayatIds.clear();
    etrapIds.clear();
    minPrice.value = null;
    maxPrice.value = null;
    selectedDates.clear();
    search.value = "";

    _saveFilters();
    hasSavedSearch.value = false;
    fetchJobs(isRefresh: true);
  }

  // The red badge only shows if there is a saved search on the server
  bool get isAnyFilterActive {
    return catIds.isNotEmpty ||
        welayatIds.isNotEmpty ||
        etrapIds.isNotEmpty ||
        minPrice.value != null ||
        maxPrice.value != null ||
        selectedDates.isNotEmpty ||
        search.value.trim().isNotEmpty;
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
