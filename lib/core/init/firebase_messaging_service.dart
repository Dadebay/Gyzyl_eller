import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/init/local_notifications_service.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/modules/chats/controllers/notification_controller.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();

  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;

  Future<void> init(
      {required LocalNotificationsService localNotificationsService}) async {
    _localNotificationsService = localNotificationsService;

    _handlePushNotificationsToken();

    // Background handler moved to main.dart

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleOnNotificationTapped(message.data);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleOnNotificationTapped(initialMessage.data);
      });
    }
  }

  void _handleOnNotificationTapped(Map<String, dynamic> data) {
    if (data['type'] == '9' || data['type'] == 'chat') {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().changePage(2);
      }
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    // Handled by FcmTokenSynchronizer
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    await _incrementNotificationCount();

    // Fallback: If socket is disconnected or just as an extra trigger (like Ayterek's notification socket)
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().fetchChats();
    }
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotifications();
    }

    final notificationData = message.notification;
    final title = notificationData?.title ?? message.data['title'] as String?;
    final body = notificationData?.body ?? message.data['body'] as String?;
    if (title != null || body != null) {
      _localNotificationsService?.showNotification(
          title, body, jsonEncode(message.data));
    }
  }

  Future<void> _incrementNotificationCount() async {
    await GetStorage.init();
    final box = GetStorage();
    final currentCount = box.read<int>('notification_count') ?? 0;
    await box.write('notification_count', currentCount + 1);
  }
}
