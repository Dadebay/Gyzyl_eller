// ignore_for_file: empty_catches

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

class AllController extends GetxController {
  final MyJobsService _jobsService = MyJobsService();
  final GetStorage _storage = GetStorage();

  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxInt totalCount = 0.obs;
  final RxDouble userBalance = 0.0.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFirstLoad = true.obs;
  final RxBool hasMore = true.obs;

  final Rx<MyTasksOrderBy> orderBy = MyTasksOrderBy.sene.obs;
  final RxnInt status = RxnInt(null);
  final RxBool isFetchingLocation = false.obs;

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

  final RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = AuthStorage().isLoggedIn;
    _loadFilters();

    // Initialize categories from API if logged in, otherwise start empty
    if (isLoggedIn.value) {
      _initApiFilters().then((_) => fetchJobs(isRefresh: true));
    } else {
      fetchJobs(isRefresh: true);
    }

    // Fire other requests in parallel
    Future.wait([
      fetchMetadata(),
      fetchBalance(),
    ]);
  }

  Future<void> _initApiFilters() async {
    try {
      print('🚀 [AllController] Initializing filters from API...');
      final savedData = await _jobsService.getMasterSavedSearch();
      if (savedData != null) {
        // Categories
        final List<int> savedCats = (savedData['cats'] as List<int>?) ?? [];
        if (savedCats.isNotEmpty) {
          catIds.assignAll(savedCats);
        }

        // Etraps
        final List<int> savedEtraps = (savedData['etraps'] as List<int>?) ?? [];
        if (savedEtraps.isNotEmpty) {
          etrapIds.assignAll(savedEtraps);
        }

        // Prices are loaded but don't trigger the badge
        final double? minP = savedData['min_price'] as double?;
        final double? maxP = savedData['max_price'] as double?;

        if (minP != null) minPrice.value = minP;
        if (maxP != null) maxPrice.value = maxP;

        hasSavedSearch.value = savedCats.isNotEmpty || savedEtraps.isNotEmpty;
        print('✅ [AllController] API Filters initialized: $savedData');
      } else {
        hasSavedSearch.value = false;
        print('ℹ️ [AllController] No saved filters found on API.');
      }
    } catch (e) {
      print('❌ [AllController] Error initializing API filters: $e');
    }
  }

  void _saveFilters() {
    // Categories are now saved via API only
    _storage.write('all_filter_welayatIds', welayatIds.toList());
    _storage.write('all_filter_etrapIds', etrapIds.toList());
    _storage.write('all_filter_minPrice', minPrice.value);
    _storage.write('all_filter_maxPrice', maxPrice.value);
    _storage.write('all_filter_dates', selectedDates.map((d) => d.toIso8601String()).toList());
    _storage.write('all_filter_search', search.value);
  }

  void _loadFilters() {
    try {
      // Categories are now loaded via API only in _initApiFilters()

      final savedWelayatIds = _storage.read<List>('all_filter_welayatIds');
      if (savedWelayatIds != null) {
        welayatIds.assignAll(savedWelayatIds.cast<int>());
      }

      final savedEtrapIds = _storage.read<List>('all_filter_etrapIds');
      if (savedEtrapIds != null) etrapIds.assignAll(savedEtrapIds.cast<int>());

      minPrice.value = _storage.read<double>('all_filter_minPrice');
      maxPrice.value = _storage.read<double>('all_filter_maxPrice');

      final savedDates = _storage.read<List>('all_filter_dates');
      if (savedDates != null) {
        selectedDates.assignAll(savedDates.map((d) => DateTime.parse(d as String)).toList());
      }

      search.value = _storage.read<String>('all_filter_search') ?? "";
    } catch (_) {
      clearFilters();
    }
  }

  Future<void> fetchBalance() async {
    try {
      final balance = await _jobsService.fetchBalance();
      userBalance.value = balance;
    } catch (e) {}
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
    if (isLoading.value) return;

    if (isRefresh) {
      _page = 0;
      // 🔄 Reset pagination state on refresh
      refreshController.resetNoData();

      // Only show full screen loader if we have no data at all
      if (jobs.isEmpty) {
        isFirstLoad.value = true;
      }
      fetchBalance();
    }

    isLoading.value = true;

    try {
      debugPrint('[AllController] fetchJobs → sort=${orderBy.value.apiValue} lat=$_currentLat lng=$_currentLng page=$_page');
      final response = await _jobsService.getMyJobs(
        page: _page,
        limit: _limit,
        status: status.value,
        sort: orderBy.value.apiValue,
        lat: orderBy.value == MyTasksOrderBy.nearest ? _currentLat : null,
        lng: orderBy.value == MyTasksOrderBy.nearest ? _currentLng : null,
        // myJobs: false,
        catIds: catIds,
        welayatIds: welayatIds,
        etrapIds: etrapIds,
        dates: selectedDates,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        search: search.value,
        requiresToken: AuthStorage().isLoggedIn,
      );

      print('============= ALL VIEW API =============');
      print('Page: $_page, Limit: $_limit, Status: ${status.value}, Sort: ${orderBy.value.apiValue}');
      print('Categories: $catIds, Welayat: $welayatIds, Etrap: $etrapIds');
      print('Search: ${search.value}, MinPrice: ${minPrice.value}, MaxPrice: ${maxPrice.value}');
      print('Response Job Count: ${response.data.jobs.length}');
      print('========================================');

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
    // Update hasSavedSearch based on whether key filters were applied
    // (Excluding price range as requested)
    hasSavedSearch.value = catIds.isNotEmpty || etrapIds.isNotEmpty;
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
  bool get isAnyFilterActive => hasSavedSearch.value;
}
