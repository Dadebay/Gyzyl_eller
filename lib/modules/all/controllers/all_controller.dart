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
    fetchMetadata();
    isLoggedIn.value = AuthStorage().isLoggedIn;
    fetchBalance();
    fetchJobs(isRefresh: true);
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

  Future<void> fetchJobs({bool isRefresh = false}) async {
    if (isLoading.value) return;

    if (isRefresh) {
      _page = 0;
      isFirstLoad.value = true;
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
