import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/init/local_notifications_service.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/modules/chats/controllers/notification_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();

  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;

  Future<void> init(
      {required LocalNotificationsService localNotificationsService}) async {
    print('🚀 [FCM SERVICE] Initializing...');
    _localNotificationsService = localNotificationsService;

    // Request notification permissions (important for Android 13+ and iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

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
    print('✅ [FCM SERVICE] Initialization complete.');
  }

  void _handleOnNotificationTapped(Map<String, dynamic> data) {
    print('🚀 [FCM ROUTE] Handling notification tap: $data');
    final String? type = data['type']?.toString();
    if (type == '9' || type == 'chat') {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().changePage(2);
      }
    } else if (type == '11' || type == 'task') {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().changePage(1);
      }
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    // Handled by FcmTokenSynchronizer
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    print('🔔 [FCM FOREGROUND] Message received:');
    print('   Data: ${message.data}');
    print('   Notification Title: ${message.notification?.title}');
    print('   Notification Body: ${message.notification?.body}');
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
      // In foreground, we show BOTH the system notification and our custom snackbar
      // to ensure maximum visibility and match Ayterek's behavior.
      _localNotificationsService?.showNotification(
          title, body, jsonEncode(message.data));

      // Show premium in-app snackbar
      Get.snackbar(
        '',
        '',
        titleText: Text(
          title ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Gilroy',
          ),
        ),
        messageText: Text(
          body ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Gilroy',
          ),
        ),
        snackPosition: SnackPosition.TOP,
        backgroundColor: ColorConstants.kPrimaryColor.withOpacity(0.95),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 5),
        onTap: (_) {
          _handleOnNotificationTapped(message.data);
          if (Get.isSnackbarOpen) Get.back();
        },
        icon: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedNotification01,
            color: Colors.white,
            size: 28,
          ),
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        mainButton: TextButton(
          onPressed: () {
            if (Get.isSnackbarOpen) Get.back();
          },
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: Colors.white,
            size: 20,
          ),
        ),
        barBlur: 10,
        forwardAnimationCurve: Curves.easeOutBack,
      );
    }
  }

  Future<void> _incrementNotificationCount() async {
    await GetStorage.init();
    final box = GetStorage();
    final currentCount = box.read<int>('notification_count') ?? 0;
    await box.write('notification_count', currentCount + 1);
  }
}
