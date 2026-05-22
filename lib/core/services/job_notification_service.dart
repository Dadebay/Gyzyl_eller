// ignore_for_file: avoid_print, constant_identifier_names, empty_catches

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_notification_model.dart';
import 'api.dart';
import 'auth_storage.dart';

class JobNotificationService {
  final _api = Api();
  final _auth = AuthStorage();

  String get _token => _auth.token ?? '';

  /// Notification Type Constants
  static const int NEW_REQUEST = 1;
  static const int REQUEST_SELECTED = 2;
  static const int REQUEST_FINISHED = 3;
  static const int JOB_STATUS_CHANGED = 4;

  /// GET /api/user/job/notification-counters
  /// Fetch all notification counters
  Future<JobNotificationCounterResponse?> getNotificationCounters() async {
    if (_token.isEmpty) {
      return null;
    }

    try {
      final url = '${_api.urlLink}api/user/job/notification-counters';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final rawBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(rawBody);

        if (data['success'] == true && data['data'] != null) {
          final result = JobNotificationCounterResponse.fromMap(data['data']);
          return result;
        }
      }
    } catch (e) {}
    return null;
  }

  /// POST /api/user/job/notification-counters/delete/:id
  /// Delete a specific notification by ID
  Future<bool> deleteNotification(String id) async {
    if (_token.isEmpty) {
      return false;
    }

    try {
      final url =
          '${_api.urlLink}api/user/job/notification-counters/delete/$id';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  /// POST /api/user/job/notification-counters/clear
  /// Clear notifications with optional filters
  Future<bool> clearNotifications({int? typeId, String? jobId}) async {
    if (_token.isEmpty) {
      return false;
    }

    try {
      final body = <String, dynamic>{};
      if (typeId != null) body['type_id'] = typeId;
      if (jobId != null) body['job_id'] = jobId;

      final url = '${_api.urlLink}api/user/job/notification-counters/clear';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
    return clearNotifications();
  }

  /// Clear notifications by type
  Future<bool> clearNotificationsByType(int typeId) async {
    return clearNotifications(typeId: typeId);
  }

  /// Clear notifications by job
  Future<bool> clearNotificationsByJob(String jobId) async {
    return clearNotifications(jobId: jobId);
  }
}
