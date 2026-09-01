// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../controllers/job_notification_controller.dart';
import '../../../core/services/job_notification_service.dart';

class JobNotificationAPIDebug {
  static final JobNotificationService _service = JobNotificationService();

  static Future<void> debugGetNotificationCounters() async {
    try {
      final response = await _service.getNotificationCounters();

      if (response != null) {
        print('✅ API Response: SUCCESS (200)');
        print('');
        print('📊 COUNTERS BY TYPE:');
        print('   ├─ NEW_REQUEST (1):         ${response.newRequestCount}');
        print(
            '   ├─ REQUEST_SELECTED (2):    ${response.requestSelectedCount}');
        print(
            '   ├─ REQUEST_FINISHED (3):    ${response.requestFinishedCount}');
        print(
            '   ├─ JOB_STATUS_CHANGED (4):  ${response.jobStatusChangedCount}');
        print(
            '   ├─ MASTER_REPLY (5):        ${response.masterReplyCount}');
        print('   └─ TOTAL:                   ${response.totalCount}');
        print('');
        print('📍 BADGE VALUES:');
        print('   ├─ all_tab badge:    ${response.totalCount}');
        print('   └─ tasks_tab badge:  ${response.requestFinishedCount}');
        print('');
        print('📋 ITEMS (${response.items.length} total):');
        for (int i = 0; i < response.items.length && i < 5; i++) {
          final item = response.items[i];
          print('   ├─ Item $i:');
          print('   │  ├─ ID: ${item.id}');
          print('   │  ├─ Job ID: ${item.jobId}');
          print('   │  ├─ Type: ${item.typeId} (${_getTypeName(item.typeId)})');
          print('   │  └─ Created: ${item.createdAt}');
        }
        if (response.items.length > 5) {
          print('   └─ ... and ${response.items.length - 5} more items');
        }
      } else {
        print('❌ API Response: FAILED');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }

  static Future<void> debugDeleteNotification(String notificationId) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 API #2: DELETE /api/user/job/notification-counters/:id');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 Deleting notification: $notificationId');

    try {
      final result = await _service.deleteNotification(notificationId);

      if (result) {
        print('✅ DELETE SUCCESS (200)');
        print('');
        print('📊 Result: true');
        print('💾 Database: Notification $notificationId removed');
        print('🔄 Counters: Updated (one counter decreased)');
      } else {
        print('❌ DELETE FAILED');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }

  static Future<void> debugClearNotifications({
    int? typeId,
    String? jobId,
  }) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 API #3: POST /api/user/job/notification-counters/clear');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    print('📋 REQUEST BODY:');
    final body = <String, dynamic>{};
    if (typeId != null) body['type_id'] = typeId;
    if (jobId != null) body['job_id'] = jobId;

    if (body.isEmpty) {
      print('   {} (Clear ALL notifications)');
    } else if (typeId != null && jobId == null) {
      print('   { "type_id": $typeId } (Clear ${_getTypeName(typeId)} only)');
    } else if (jobId != null && typeId == null) {
      print('   { "job_id": "$jobId" } (Clear job notifications only)');
    } else {
      print('   { "type_id": $typeId, "job_id": "$jobId" }');
    }
    print('');

    try {
      final result =
          await _service.clearNotifications(typeId: typeId, jobId: jobId);

      if (result) {
        print('✅ CLEAR SUCCESS (200)');
        if (body.isEmpty) {
          print('💾 Database: All notifications cleared');
          print('📊 Counters: All set to 0');
        } else if (typeId != null) {
          print('💾 Database: ${_getTypeName(typeId)} notifications cleared');
        } else if (jobId != null) {
          print('💾 Database: Job "$jobId" notifications cleared');
        }
      } else {
        print('❌ CLEAR FAILED');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }

  /// =========================================================================
  /// COMPLETE API FLOW EXAMPLE
  /// =========================================================================

  static Future<void> debugCompleteFlow() async {
    print('\n\n');
    print('█████████████████████████████████████████████████████████████');
    print('█  COMPLETE API FLOW - START TO FINISH                      █');
    print('█████████████████████████████████████████████████████████████');
    print('');

    // Step 1
    print('STEP 1: Fetch all counters on app start');
    print('   └─ Called from: JobNotificationController.onInit()');
    print('   └─ Polling: Every 15 seconds');
    await debugGetNotificationCounters();

    // Step 2
    print('STEP 2: User sees badges on bottom nav');
    final controller = Get.find<JobNotificationController>();
    print('   ├─ all_tab badge:   ${controller.allTabCount.value}');
    print('   ├─ tasks_tab badge: ${controller.tasksTabCount.value}');
    print('   ├─ chat badge:      (from ChatController)');
    print('   └─ settings badge:  0 (fixed)');
    print('');

    // Step 3
    print('STEP 3: User taps on a notification to delete it');
    print('   └─ Called from: Notification list item tap');
    await debugDeleteNotification('example_notif_id');

    // Step 4
    print('STEP 4: User clears all NEW_REQUEST notifications');
    print('   └─ Called from: "Mark as read" button');
    await debugClearNotifications(typeId: 1);

    // Step 5
    print('STEP 5: Auto-refresh after 15 seconds');
    print('   └─ All counters updated automatically');
    print('   └─ UI rebuilds with new badge values');
    print('');

    print('█████████████████████████████████████████████████████████████');
    print('█  COMPLETE FLOW - END                                      █');
    print('█████████████████████████████████████████████████████████████\n');
  }

  /// =========================================================================
  /// NOTIFICATION TYPE NAMES
  /// =========================================================================

  static String _getTypeName(int typeId) {
    switch (typeId) {
      case 1:
        return 'NEW_REQUEST';
      case 2:
        return 'REQUEST_SELECTED';
      case 3:
        return 'REQUEST_FINISHED';
      case 4:
        return 'JOB_STATUS_CHANGED';
      case 5:
        return 'MASTER_REPLY';
      default:
        return 'UNKNOWN';
    }
  }
}
