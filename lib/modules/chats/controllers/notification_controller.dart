import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api.dart';
import '../../../core/services/auth_storage.dart';
import '../../../core/models/notification_model.dart';

class NotificationController extends GetxController {
  final _api = Api();
  final _auth = AuthStorage();
  final _storage = GetStorage();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  String get _lang => _storage.read('langCode') ?? 'tk';
  String get _token => _auth.token ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    if (_token.isEmpty) return;
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${_api.urlLink}api/user/$_lang/get-notifications'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['status'] == 200 && data['notifications'] != null) {
          final List list = data['notifications'];
          notifications.value = list.map((e) => NotificationModel.fromMap(e)).toList();
          _updateUnreadCount();
        }
      }
    } catch (e) {
      Get.log('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => n.showed == 'false').length;
  }

  Future<void> markAsShowed(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && notifications[index].showed == 'false') {
      notifications[index] = notifications[index].copyWith(showed: 'true');
      _updateUnreadCount();
      
      try {
        await http.post(
          Uri.parse('${_api.urlLink}api/user/$_lang/showed-notification/$id'),
          headers: {'Authorization': 'Bearer $_token'},
        );
      } catch (e) {
         Get.log('Error marking notification as showed: $e');
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    
    try {
      await http.post(
        Uri.parse('${_api.urlLink}api/user/$_lang/delete-notification/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );
    } catch (e) {
       Get.log('Error deleting notification: $e');
    }
  }
}
