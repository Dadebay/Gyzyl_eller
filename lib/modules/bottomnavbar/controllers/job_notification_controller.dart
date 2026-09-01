import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/models/job_notification_model.dart';
import '../../../core/services/job_notification_service.dart';
import '../../../core/utils/all_view_tag_resolver.dart';
import '../../all/controllers/all_controller.dart';
import '../../task/controllers/task_controller.dart';

class JobNotificationController extends GetxController {
  final JobNotificationService _service = JobNotificationService();

  /// Job IDs where another user was selected (task_status_other_selected).
  /// Populated by TaskController after each requestedJobs load.
  final Set<String> _otherSelectedJobIds = <String>{};

  /// Job IDs whose MASTER_REPLY notification was locally cleared by the user
  /// opening the card. Cleared again when fresh server data arrives.
  final RxList<String> _optimisticCleared = <String>[].obs;

  /// Reactive list of job IDs that have an unread MASTER_REPLY notification.
  /// Populated from API items (if returned) OR from FCM foreground data (job_id field).
  /// Obx widgets subscribe to this directly — no items-empty edge case.
  final RxList<String> masterReplyJobIds = <String>[].obs;

  void optimisticallyMarkCleared(String jobId) {
    if (!_optimisticCleared.contains(jobId)) {
      _optimisticCleared.add(jobId);
      masterReplyJobIds.remove(jobId);
      updateTasksTabCount();
    }
  }

  /// Called from FCM foreground handler when a MASTER_REPLY notification arrives
  /// with a known job_id. Adds the job to the reactive list so task_view Obx
  /// rebuilds and shows "Baha goýulan" tag immediately — even if API items is empty.
  void addPendingMasterReplyJob(String jobId) {
    if (!_optimisticCleared.contains(jobId) &&
        !masterReplyJobIds.contains(jobId)) {
      masterReplyJobIds.add(jobId);
    }
  }

  /// Callback registered by TaskController to sync _otherSelectedJobIds
  /// before tab counts are computed. Avoids circular imports.
  VoidCallback? _otherSelectedSyncCallback;

  void registerOtherSelectedSync(VoidCallback cb) {
    _otherSelectedSyncCallback = cb;
  }

  /// Re-entrancy guard: prevents updateTasksTabCount() → sync callback →
  /// updateOtherSelectedJobIds() → updateTasksTabCount() infinite recursion.
  bool _updatingTabCount = false;

  void updateOtherSelectedJobIds(Set<String> ids) {
    _otherSelectedJobIds
      ..clear()
      ..addAll(ids);
    // Skip recursive call; the outer updateTasksTabCount() will use the
    // freshly updated _otherSelectedJobIds once the sync callback returns.
    if (counterResponse.value != null && !_updatingTabCount) {
      updateTasksTabCount();
    }
  }

  final RxInt allTabCount = 0.obs;
  final RxInt tasksTabCount = 0.obs;

  /// Per-tab counts inside TaskView:
  ///   tab0 = my_offers  (JOB_STATUS_CHANGED=4)
  ///   tab1 = my_jobs    (REQUEST_SELECTED=2 + REQUEST_FINISHED=3)
  final RxInt tab0Count = 0.obs;
  final RxInt tab1Count = 0.obs;

  /// Tracks locally cleared tabs so updateTasksTabCount() does not restore
  /// the badge until a fresh fetchNotificationCounters() completes.
  bool _tab0Cleared = false;
  bool _tab1Cleared = false;

  final Rx<JobNotificationCounterResponse?> counterResponse = Rx(null);
  final RxBool isLoading = false.obs;
  final RxBool ignoreLocalAllTabCount = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationCounters();
  }

  void reset() {
    allTabCount.value = 0;
    tasksTabCount.value = 0;
    tab0Count.value = 0;
    tab1Count.value = 0;
    counterResponse.value = null;
    masterReplyJobIds.clear();
    _optimisticCleared.clear();
    _tab0Cleared = false;
    _tab1Cleared = false;
    _updatingTabCount = false;
  }

  /// Fetch notification counters and update tab counts
  Future<void> fetchNotificationCounters() async {
    isLoading.value = true;
    try {
      final response = await _service.getNotificationCounters();
      if (response != null) {
        counterResponse.value = response;
        print('🌐 [fetchCounters] API raw → '
            't1=${response.newRequestCount} '
            't2=${response.requestSelectedCount} '
            't3=${response.requestFinishedCount} '
            't4=${response.jobStatusChangedCount} '
            't5=${response.masterReplyCount}');

        // Fresh server data — allow badges to show again
        _tab0Cleared = false;
        _tab1Cleared = false;

        // Rebuild masterReplyJobIds from fresh API items.
        // Jobs the user already opened (_optimisticCleared) are excluded.
        final serverMasterReplyIds = response.items
            .where((i) => i.typeId == JobNotificationService.MASTER_REPLY)
            .map((i) => i.jobId)
            .toSet();

        // Merge: keep FCM-sourced IDs that the server still reports,
        // add any new server IDs, remove cleared ones.
        final merged = <String>{
          ...masterReplyJobIds.where((id) => serverMasterReplyIds.contains(id)),
          ...serverMasterReplyIds,
        }..removeAll(_optimisticCleared);
        masterReplyJobIds.assignAll(merged);

        // Preserve optimistically-cleared job IDs that the server STILL reports.
        if (_optimisticCleared.isNotEmpty) {
          final preserved =
              _optimisticCleared.where(serverMasterReplyIds.contains).toList();
          _optimisticCleared.assignAll(preserved);
        }

        // 1. Tab (AllView): Update dynamically based on local status_new jobs
        updateAllTabCount();

        // 2. Tab (TaskView): Dynamic based on sub-tab
        updateTasksTabCount();
      } else {
        print('🌐 [fetchCounters] API returned null');
      }
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
      print(
          '🔔 [JobNotificationController] updated allTabCount to: ${allTabCount.value} based on backend (ignoring local)');
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
        print(
            '🔔 [JobNotificationController] updated allTabCount to: $count based on local status_new jobs');
        return;
      }
    }

    final response = counterResponse.value;
    allTabCount.value = response?.newRequestCount ?? 0;
    print(
        '🔔 [JobNotificationController] updated allTabCount to: ${allTabCount.value} based on backend newRequestCount');
  }

  /// Update the Tasks tab badge count and both inner-tab counts.
  /// Badge is cleared only when the user navigates away from the Tasks tab
  /// (or switches between inner tabs).
  void updateTasksTabCount() {
    // Always sync _otherSelectedJobIds from TaskController before calculating.
    // The re-entrancy guard ensures the callback cannot trigger a second
    // updateTasksTabCount() call, so _otherSelectedJobIds is updated
    // synchronously and this method continues with correct data.
    if (!_updatingTabCount) {
      _updatingTabCount = true;
      _otherSelectedSyncCallback?.call();
      _updatingTabCount = false;
    }

    final response = counterResponse.value;
    if (response == null) {
      tab0Count.value = 0;
      tab1Count.value = 0;
      tasksTabCount.value = 0;
      print('📊 [TasksCount] response is null → all counts = 0');
      return;
    }

    // Split REQUEST_SELECTED (type 2) between tabs:
    //   tab0 → other user was selected (task_status_other_selected)
    //   tab1 → you were selected
    int selectedForTab0 = 0;
    int selectedForTab1 = 0;

    if (response.items.isNotEmpty) {
      for (final item in response.items) {
        if (item.typeId != JobNotificationService.REQUEST_SELECTED) continue;
        if (_otherSelectedJobIds.contains(item.jobId)) {
          selectedForTab0++;
        } else {
          selectedForTab1++;
        }
      }
    } else {
      // No items: estimate from known other-selected job count
      selectedForTab0 =
          _otherSelectedJobIds.length.clamp(0, response.requestSelectedCount);
      selectedForTab1 = (response.requestSelectedCount - selectedForTab0)
          .clamp(0, response.requestSelectedCount);
    }

    // masterReplyCount excluding jobs the user already opened (optimistic clear).
    // When items has per-job data, count precisely; otherwise subtract the
    // total number of optimistically cleared entries.
    int effectiveMasterReplyCount;
    if (response.items.isNotEmpty) {
      effectiveMasterReplyCount = response.items
          .where((i) =>
              i.typeId == JobNotificationService.MASTER_REPLY &&
              !_optimisticCleared.contains(i.jobId))
          .length;
    } else {
      effectiveMasterReplyCount =
          (response.masterReplyCount - _optimisticCleared.length)
              .clamp(0, response.masterReplyCount);
    }

    tab0Count.value = _tab0Cleared ? 0 : selectedForTab0;
    tab1Count.value = _tab1Cleared
        ? 0
        : selectedForTab1 +
            response.requestFinishedCount +
            response.jobStatusChangedCount +
            effectiveMasterReplyCount;
    tasksTabCount.value = tab0Count.value + tab1Count.value;

    // ── Per-type analysis print ──────────────────────────────────────────────
    print('📊 [TasksCount] ─────────────────────────────────────────');
    print('📊 type_id=1 newRequest       : ${response.newRequestCount}'
        '  → AllTab (not TaskView)');
    _printTypeStatus('type_id=2 requestSelected', response.requestSelectedCount,
        detail:
            'tab0(otherSelected)=$selectedForTab0  tab1(youSelected)=$selectedForTab1');
    _printTypeStatus('type_id=3 requestFinished', response.requestFinishedCount,
        detail: 'tab1');
    _printTypeStatus(
        'type_id=4 jobStatusChanged', response.jobStatusChangedCount,
        detail: 'tab1');
    _printTypeStatus('type_id=5 masterReply    ', response.masterReplyCount,
        detail: 'tab1 (ussa baha goýdy)');
    print('📊 tab0Count=${tab0Count.value}  tab1Count=${tab1Count.value}'
        '  tasksTotal=${tasksTabCount.value}');
    print('📊 ─────────────────────────────────────────────────────');
  }

  void _printTypeStatus(String label, int count, {String detail = ''}) {
    final status = count > 0 ? '✅ ÇYKDY ($count)' : '❌ ÇYKMADY (0)';
    final detailStr = detail.isNotEmpty ? '  [$detail]' : '';
    print('📊 $label: $status$detailStr');
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
    print(
        '🧹 [JobNotificationController] Clearing AllView tab API notifications...');

    // Only clear the server-side notification records.
    // The local badge (count of status_new jobs visible in AllView) is NOT
    // zeroed out here — it persists until the job status actually changes,
    // which is what the user expects.
    await clearByType(JobNotificationService.NEW_REQUEST);

    // Make sure local count is not suppressed after the API clear.
    ignoreLocalAllTabCount.value = false;
    updateAllTabCount();

    print(
        '🧹 [JobNotificationController] API notifications cleared; local badge preserved until status changes');
  }

  /// Clear Tab 0 (my_offers) badge visually. No API call here — server-side clearing
  /// happens when the user opens a specific job (clearByJob) or leaves the Tasks tab
  /// (clearTasksTabNotifications). Avoids race conditions with fetchNotificationCounters.
  void clearTab0Notifications() {
    print('🧹 [JobNotificationController] tab0 badge cleared (local only)');
    _tab0Cleared = true;
    tab0Count.value = 0;
    tasksTabCount.value = tab1Count.value;
  }

  /// Clear Tab 1 (my_jobs) badge visually. No API call here — server-side clearing
  /// happens when the user opens a specific job (clearByJob) or leaves the Tasks tab
  /// (clearTasksTabNotifications). Avoids race conditions with fetchNotificationCounters.
  void clearTab1Notifications() {
    print('🧹 [JobNotificationController] tab1 badge cleared (local only)');
    _tab1Cleared = true;
    tab1Count.value = 0;
    tasksTabCount.value = tab0Count.value;
  }

  /// Clear all Tasks tab notifications (called when user navigates away from Tasks tab).
  Future<void> clearTasksTabNotifications() async {
    print(
        '🧹 [JobNotificationController] Clearing all TaskView tab notifications...');
    print('🧹  type_id=2 requestSelected  → will clear');
    print('🧹  type_id=3 requestFinished  → will clear');
    print('🧹  type_id=4 jobStatusChanged → will clear');
    print('🧹  type_id=5 masterReply      → will clear');
    // Immediate visual feedback for bottom nav badge
    tab0Count.value = 0;
    tab1Count.value = 0;
    tasksTabCount.value = 0;
    // Async API clear
    await clearByType(JobNotificationService.REQUEST_SELECTED);
    await clearByType(JobNotificationService.REQUEST_FINISHED);
    await clearByType(JobNotificationService.JOB_STATUS_CHANGED);
    await clearByType(JobNotificationService.MASTER_REPLY);
  }

  /// Refresh processingJobs when a notification arrives (type 5 = MASTER_REPLY = "baha goyulanda")
  /// This ensures the card updates immediately with the new priceComment field.
  Future<void> refreshProcessingJobsOnNotification() async {
    if (!Get.isRegistered<TaskController>()) {
      print(
          '🔔 [JobNotificationController] TaskController not registered, skipping refresh');
      return;
    }

    final taskController = Get.find<TaskController>();

    // Only refresh if tab1 (processingJobs) is already loaded
    if (taskController.isProcessingFirstLoad.value) {
      print(
          '🔔 [JobNotificationController] tab1 not yet loaded, skipping refresh');
      return;
    }

    print(
        '🔔 [JobNotificationController] Refreshing processingJobs after MASTER_REPLY notification...');
    await taskController.fetchProcessingJobs(isRefresh: true);
    print('🔔 [JobNotificationController] processingJobs refreshed');
  }

  /// Returns true if [jobId] has an unread notification in tab0:
  ///   - type_id=2 (other user selected — task_status_other_selected)
  bool hasTab0Notification(String jobId) {
    final items = counterResponse.value?.items ?? [];
    return items.any((i) =>
        i.jobId == jobId &&
        i.typeId == JobNotificationService.REQUEST_SELECTED &&
        _otherSelectedJobIds.contains(jobId));
  }

  /// Returns true if [jobId] has a MASTER_REPLY (type_id=5) notification.
  /// Used to show "Baha goýulan" tag on a specific job card in tab1.
  /// Reading _optimisticCleared makes the calling Obx rebuild immediately on open.
  bool hasMasterReplyForJob(String jobId) {
    if (_optimisticCleared.contains(jobId)) return false;
    final items = counterResponse.value?.items ?? [];
    return items.any((i) =>
        i.jobId == jobId && i.typeId == JobNotificationService.MASTER_REPLY);
  }

  /// Returns true if [jobId] has an unread notification in tab1:
  ///   - type_id=2 (you were selected) OR
  ///   - type_id=5 (master_reply — ussa baha goýdy)
  bool hasTab1Notification(String jobId) {
    final items = counterResponse.value?.items ?? [];
    return items.any((i) =>
        i.jobId == jobId &&
        (i.typeId == JobNotificationService.MASTER_REPLY ||
            (i.typeId == JobNotificationService.REQUEST_SELECTED &&
                !_otherSelectedJobIds.contains(jobId))));
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
      case JobNotificationService.MASTER_REPLY:
        return counterResponse.value?.masterReplyCount ?? 0;
      default:
        return 0;
    }
  }
}
