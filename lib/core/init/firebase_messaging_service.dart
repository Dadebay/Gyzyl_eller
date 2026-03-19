import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/init/local_notifications_service.dart';

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

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {}
  }

  Future<void> _handlePushNotificationsToken() async {
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {})
        .onError((error) {});
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    await _incrementNotificationCount();
    final notificationData = message.notification;
    if (notificationData != null) {
      _localNotificationsService?.showNotification(notificationData.title,
          notificationData.body, message.data.toString());
    }
  }
}

Future<void> _incrementNotificationCount() async {
  await GetStorage.init();
  final box = GetStorage();
  final currentCount = box.read<int>('notification_count') ?? 0;
  await box.write('notification_count', currentCount + 1);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _incrementNotificationCount();
}
