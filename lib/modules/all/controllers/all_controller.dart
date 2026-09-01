// ignore_for_file: empty_catches, avoid_print

import 'dart:convert';
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
    final old = refreshController;
    refreshController = RefreshController(initialRefresh: false);
    // Delay dispose so any in-flight 300ms timer inside pull_to_refresh
    // finishes before the scroll position is torn down.
    Future.delayed(const Duration(milliseconds: 400), old.dispose);
  }

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = AuthStorage().isLoggedIn;

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
        _loadFiltersFromApi().then((_) {
          hasSavedSearch.value = isAnyFilterActive; // Update UI state
          fetchJobs(isRefresh: true); // Fetch with loaded filters
        });
      } else {
        clearFilters();
      }
    });

    // Load filters from API and then fetch jobs
    if (isLoggedIn.value) {
      _loadFiltersFromApi().then((_) {
        hasSavedSearch.value = isAnyFilterActive;
        fetchJobs(isRefresh: true); // Fetch AFTER filters are loaded
      });
    } else {
      fetchJobs(isRefresh: true);
    }

    // Fire other requests in parallel
    Future.wait([
      fetchMetadata(),
      fetchBalance(),
    ]);
  }

  /// Convert current filters to JSON for API storage
  Map<String, dynamic> _filterToJson() {
    return {
      'catIds': catIds.toList(),
      'welayatIds': welayatIds.toList(),
      'etrapIds': etrapIds.toList(),
      'minPrice': minPrice.value,
      'maxPrice': maxPrice.value,
      'dates': selectedDates.map((d) => d.toIso8601String()).toList(),
      'search': search.value,
    };
  }

  /// Parse filter JSON from API storage
  void _filterFromJson(Map<String, dynamic> json) {
    try {
      final catIdsList = json['catIds'] as List<dynamic>?;
      if (catIdsList != null) {
        catIds.assignAll(catIdsList.cast<int>());
      }

      final welayatIdsList = json['welayatIds'] as List<dynamic>?;
      if (welayatIdsList != null) {
        welayatIds.assignAll(welayatIdsList.cast<int>());
      }

      final etrapIdsList = json['etrapIds'] as List<dynamic>?;
      if (etrapIdsList != null) {
        etrapIds.assignAll(etrapIdsList.cast<int>());
      }

      minPrice.value =
          (json['minPrice'] == 0) ? null : json['minPrice'] as double?;
      maxPrice.value =
          (json['maxPrice'] == 1000000) ? null : json['maxPrice'] as double?;

      final datesList = json['dates'] as List<dynamic>?;
      if (datesList != null) {
        selectedDates.assignAll(
            datesList.map((d) => DateTime.parse(d as String)).toList());
      }

      search.value = json['search'] as String? ?? "";
    } catch (e) {
      print('🔴 Error parsing filters from JSON: $e');
      clearFilters();
    }
  }

  /// Save filters to API
  Future<void> _saveFiltersToApi() async {
    try {
      if (!AuthStorage().isLoggedIn) return;

      print('📤 [AllController] Saving filters to API');
      final filterJson = _filterToJson();
      await _jobsService.createSavedRequest(
        jsonEncode(filterJson),
      );
      print('✅ [AllController] Filters saved to API');
    } catch (e) {
      print('🔴 [AllController] Error saving filters to API: $e');
    }
  }

  /// Load filters from API
  Future<void> _loadFiltersFromApi() async {
    try {
      if (!AuthStorage().isLoggedIn) {
        clearFilters();
        return;
      }

      print('📥 [AllController] Loading filters from API');
      final savedRequests = await _jobsService.getSavedRequests();

      if (savedRequests.isNotEmpty) {
        // Get the first saved request (latest one)
        final latestRequest = savedRequests.first;
        try {
          final filterJson =
              jsonDecode(latestRequest.comment) as Map<String, dynamic>;
          _filterFromJson(filterJson);
          print('✅ [AllController] Filters loaded from API');
        } catch (e) {
          print('⚠️ [AllController] Could not parse saved filters: $e');
          clearFilters();
        }
      } else {
        print('ℹ️ [AllController] No saved filters found');
        clearFilters();
      }
    } catch (e) {
      print('🔴 [AllController] Error loading filters from API: $e');
      clearFilters();
    }
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
        welayatIds: etrapIds.isEmpty ? welayatIds : [],
        etrapIds: etrapIds,
        dates: selectedDates,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        search: search.value,
      );

      // If a newer filter-apply arrived while this fetch was in flight,
      // discard these stale results — the pending refresh will show correct data.
      if (_pendingRefresh) {
        isLoading.value = false;
      } else {
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

    _saveFiltersToApi(); // Save to API (fire and forget)
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

    _saveFiltersToApi(); // Save empty filters to API
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
