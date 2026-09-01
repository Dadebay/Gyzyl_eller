// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';

class LocalNotificationsService {
  LocalNotificationsService._internal();

  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();

  factory LocalNotificationsService.instance() => _instance;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final _androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final _androidChannel = const AndroidNotificationChannel(
    'master_channel',
    'Aytereks\'s message',
    description:
        'Bu kanal Ayterek programmasynyň möhüm bildirişleri üçin ulanylýar.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _isFlutterLocalNotificationInitialized = false;

  int _notificationIdCounter = 0;

  Future<void> init({bool isBackground = false}) async {
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!);
          if (data['type'] == 'chat') {
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().changePage(2);
            }
          }
        } catch (e) {
          // Ignore JSON parse errors
        }
      }
    });

    if (!isBackground) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _isFlutterLocalNotificationInitialized = true;
  }

  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    print(
        '🔔 [LOCAL NOTIF] Showing notification: $title / $body (Importance: MAX, Priority: MAX)');
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      color: ColorConstants.kPrimaryColor,
      styleInformation: BigTextStyleInformation(
        body ?? '',
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatTitle: true,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      ),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      _notificationIdCounter++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
