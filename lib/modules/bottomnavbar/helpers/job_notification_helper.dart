import 'package:get/get.dart';
import '../controllers/job_notification_controller.dart';
import '../../../core/services/job_notification_service.dart';

class JobNotificationHelper {
  /// Get the JobNotificationController instance
  static JobNotificationController get controller {
    return Get.find<JobNotificationController>();
  }

  /// Refresh all notification counters
  static Future<void> refreshCounters() async {
    await controller.fetchNotificationCounters();
  }

  /// Delete a specific notification by ID
  static Future<bool> deleteNotification(String id) async {
    return await controller.deleteNotification(id);
  }

  /// Clear all notifications
  static Future<bool> clearAll() async {
    return await controller.clearAllNotifications();
  }

  /// Clear notifications by type
  /// typeId: 1 (NEW_REQUEST), 2 (REQUEST_SELECTED), 3 (REQUEST_FINISHED), 4 (JOB_STATUS_CHANGED)
  static Future<bool> clearByType(int typeId) async {
    return await controller.clearByType(typeId);
  }

  /// Clear notifications by job ID
  static Future<bool> clearByJobId(String jobId) async {
    return await controller.clearByJob(jobId);
  }

  /// Get count for specific notification type
  static int getCountByType(int typeId) {
    return controller.getCountByType(typeId);
  }

  /// Get all notification counts
  static Map<String, int> getAllCounts() {
    return {
      'all_tab': controller.allTabCount.value,
      'tasks_tab': controller.tasksTabCount.value,
      'new_request':
          controller.getCountByType(JobNotificationService.NEW_REQUEST),
      'request_selected':
          controller.getCountByType(JobNotificationService.REQUEST_SELECTED),
      'request_finished':
          controller.getCountByType(JobNotificationService.REQUEST_FINISHED),
      'job_status_changed':
          controller.getCountByType(JobNotificationService.JOB_STATUS_CHANGED),
      'master_reply':
          controller.getCountByType(JobNotificationService.MASTER_REPLY),
    };
  }

  /// Check if there are any notifications
  static bool hasNotifications() {
    return controller.allTabCount.value > 0 ||
        controller.tasksTabCount.value > 0;
  }
}
