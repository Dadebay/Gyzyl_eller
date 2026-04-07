// ignore_for_file: empty_catches

import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/models/my_tasks_order_by.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';

class AllController extends GetxController {
  final MyJobsService _jobsService = MyJobsService();

  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxInt totalCount = 0.obs;
  final RxDouble userBalance = 0.0.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFirstLoad = true.obs;
  final RxBool hasMore = true.obs;

  final Rx<MyTasksOrderBy> orderBy = MyTasksOrderBy.sene.obs;
  final RxnInt status = RxnInt(null);

  // Filter state
  final RxList<int> catIds = <int>[].obs;
  final RxList<int> welayatIds = <int>[].obs;
  final RxList<int> etrapIds = <int>[].obs;
  final RxnDouble minPrice = RxnDouble(null);
  final RxnDouble maxPrice = RxnDouble(null);
  final RxList<DateTime> selectedDates = <DateTime>[].obs;
  final RxString search = "".obs;

  // Metadata
  final RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  final RxList<LocationModel> allLocations = <LocationModel>[].obs;

  int _page = 0;
  final int _limit = 20;

  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = AuthStorage().isLoggedIn;

    // Fire all requests in parallel
    Future.wait([
      fetchMetadata(),
      fetchBalance(),
      fetchJobs(isRefresh: true),
    ]);
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
      final response = await _jobsService.getMyJobs(
        page: _page,
        limit: _limit,
        status: status.value,
        sort: orderBy.value.apiValue,
        // myJobs: false,
        catIds: catIds,
        welayatIds: welayatIds,
        etrapIds: etrapIds,
        dates: selectedDates,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        search: search.value,
      );

      print('============= ALL VIEW API =============');
      print(
          'Page: $_page, Limit: $_limit, Status: ${status.value}, Sort: ${orderBy.value.apiValue}');
      print('Categories: $catIds, Welayat: $welayatIds, Etrap: $etrapIds');
      print(
          'Search: ${search.value}, MinPrice: ${minPrice.value}, MaxPrice: ${maxPrice.value}');
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
    } catch (e) {
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

    fetchJobs(isRefresh: true);
  }
}
