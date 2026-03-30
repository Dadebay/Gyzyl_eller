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
        catIds: catIds,
        welayatIds: welayatIds,
        etrapIds: etrapIds,
        dates: selectedDates,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        search: search.value,
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
        catIds: catIds,
        welayatIds: welayatIds,
        etrapIds: etrapIds,
        dates: selectedDates,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        search: search.value,
      );

      if (isRefresh) {
        processingJobs.clear();
      }

      processingJobs.addAll(response.data.jobs);
      processingTotalCount.value = response.data.count;
      hasProcessingMore.value = processingJobs.length < processingTotalCount.value;
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

    fetchRequestedJobs(isRefresh: true);
    fetchProcessingJobs(isRefresh: true);
  }

  void clearFilters() {
    catIds.clear();
    welayatIds.clear();
    etrapIds.clear();
    minPrice.value = null;
    maxPrice.value = null;
    selectedDates.clear();
    search.value = "";

    fetchRequestedJobs(isRefresh: true);
    fetchProcessingJobs(isRefresh: true);
  }
}
