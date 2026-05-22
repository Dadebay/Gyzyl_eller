import 'dart:async';
import 'package:get/get.dart';
import '../../../core/models/job_notification_model.dart';
import '../../../core/services/job_notification_service.dart';
import '../../task/controllers/task_controller.dart';
import 'home_controller.dart';
import '../../../core/utils/all_view_tag_resolver.dart';
import '../../all/controllers/all_controller.dart';

class JobNotificationController extends GetxController {
  final JobNotificationService _service = JobNotificationService();

  final RxInt allTabCount = 0.obs;
  final RxInt tasksTabCount = 0.obs;
  final Rx<JobNotificationCounterResponse?> counterResponse = Rx(null);
  final RxBool isLoading = false.obs;
  final RxBool ignoreLocalAllTabCount = false.obs;

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationCounters();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchNotificationCounters();
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void reset() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    allTabCount.value = 0;
    tasksTabCount.value = 0;
    counterResponse.value = null;
  }

  /// Fetch notification counters and update tab counts
  Future<void> fetchNotificationCounters() async {
    isLoading.value = true;
    try {
      final response = await _service.getNotificationCounters();
      if (response != null) {
        counterResponse.value = response;

        // 1. Tab (AllView): Update dynamically based on local status_new jobs
        updateAllTabCount();

        // 2. Tab (TaskView): Dynamic based on sub-tab
        updateTasksTabCount();
      } else {}
    } finally {
      isLoading.value = false;
    }
  }

  /// Update the All tab badge count dynamically based on local status_new jobs
  void updateAllTabCount() {
    // If we've cleared notifications by switching tabs, ignore local count
    if (ignoreLocalAllTabCount.value) {
      final response = counterResponse.value;
      allTabCount.value = response?.newRequestCount ?? 0;
      print('🔔 [JobNotificationController] updated allTabCount to: ${allTabCount.value} based on backend (ignoring local)');
      return;
    }

    if (Get.isRegistered<AllController>()) {
      final allController = Get.find<AllController>();
      final tagResolver = AllViewTagResolver();
      final isLoggedIn = allController.isLoggedIn.value;

      if (allController.jobs.isNotEmpty) {
        int count = 0;
        for (final job in allController.jobs) {
          final tag = tagResolver.resolve(job, isLoggedIn: isLoggedIn);
          if (!tag.hideTag && tag.label == 'status_new'.tr) {
            count++;
          }
        }
        allTabCount.value = count;
        print('🔔 [JobNotificationController] updated allTabCount to: $count based on local status_new jobs');
        return;
      }
    }

    final response = counterResponse.value;
    allTabCount.value = response?.newRequestCount ?? 0;
    print('🔔 [JobNotificationController] updated allTabCount to: ${allTabCount.value} based on backend newRequestCount');
  }

  /// Update the Tasks tab badge count dynamically based on the active page and sub-tab
  void updateTasksTabCount() {
    final response = counterResponse.value;
    if (response == null) {
      tasksTabCount.value = 0;
      return;
    }

    final bool isPage1Active = Get.isRegistered<HomeController>() &&
        Get.find<HomeController>().bottomNavBarSelectedIndex.value == 1;

    if (isPage1Active && Get.isRegistered<TaskController>()) {
      final taskController = Get.find<TaskController>();
      if (taskController.activeTabIndex.value == 0) {
        // User is currently viewing My Offers (types 2 and 4).
        // Show only My Jobs notifications (type 3: REQUEST_FINISHED).
        tasksTabCount.value = response.requestFinishedCount;
      } else {
        // User is currently viewing My Jobs (type 3).
        // Show only My Offers notifications (types 2 and 4).
        tasksTabCount.value = response.requestSelectedCount + response.jobStatusChangedCount;
      }
    } else {
      // User is not on TaskView, show the total sum of all Tasks tab notifications
      tasksTabCount.value = response.requestSelectedCount +
          response.requestFinishedCount +
          response.jobStatusChangedCount;
    }
  }

  /// Delete a single notification
  Future<bool> deleteNotification(String id) async {
    final result = await _service.deleteNotification(id);
    if (result) {
      await fetchNotificationCounters();
    } else {}
    return result;
  }

  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
    final result = await _service.clearAllNotifications();
    if (result) {
      await fetchNotificationCounters();
    } else {}
    return result;
  }

  /// Clear notifications by type
  Future<bool> clearByType(int typeId) async {
    final result = await _service.clearNotificationsByType(typeId);
    if (result) {
      await fetchNotificationCounters();
    } else {}
    return result;
  }

  /// Clear notifications by job
  Future<bool> clearByJob(String jobId) async {
    final result = await _service.clearNotificationsByJob(jobId);
    if (result) {
      await fetchNotificationCounters();
    } else {}
    return result;
  }

  /// Alias for [clearByJob] — used across the codebase
  Future<bool> clearNotificationsByJob(String jobId) => clearByJob(jobId);

  /// Alias for [clearByType] — used across the codebase
  Future<bool> clearNotificationsByType(int typeId) => clearByType(typeId);

  /// Clear notifications for All tab (type 1)
  Future<void> clearAllTabNotifications() async {
    print('🧹 [JobNotificationController] Clearing AllView tab notifications...');

    // Set flag to ignore local count from now on
    ignoreLocalAllTabCount.value = true;

    // Clear API notifications
    await clearByType(JobNotificationService.NEW_REQUEST);

    // Reset the badge count to 0 immediately (don't wait for next polling)
    allTabCount.value = 0;
    print('🧹 [JobNotificationController] Reset allTabCount to 0 and set ignoreLocalAllTabCount flag');
  }

  /// Clear notifications for Tasks tab based on active sub-tab index
  Future<void> clearTasksTabNotifications(int activeSubTabIndex) async {
    print('🧹 [JobNotificationController] Clearing TaskView tab notifications for sub-tab $activeSubTabIndex...');
    if (activeSubTabIndex == 0) {
      // Clear My Offers notifications (REQUEST_SELECTED: 2 and JOB_STATUS_CHANGED: 4)
      await clearByType(JobNotificationService.REQUEST_SELECTED);
      await clearByType(JobNotificationService.JOB_STATUS_CHANGED);
    } else if (activeSubTabIndex == 1) {
      // Clear My Jobs notifications (REQUEST_FINISHED: 3)
      await clearByType(JobNotificationService.REQUEST_FINISHED);
    }
  }

  /// Get count by type
  int getCountByType(int typeId) {
    switch (typeId) {
      case JobNotificationService.NEW_REQUEST:
        return counterResponse.value?.newRequestCount ?? 0;
      case JobNotificationService.REQUEST_SELECTED:
        return counterResponse.value?.requestSelectedCount ?? 0;
      case JobNotificationService.REQUEST_FINISHED:
        return counterResponse.value?.requestFinishedCount ?? 0;
      case JobNotificationService.JOB_STATUS_CHANGED:
        return counterResponse.value?.jobStatusChangedCount ?? 0;
      default:
        return 0;
    }
  }
}
