// ignore_for_file: empty_catches

import 'package:gyzyleller/core/services/chat_socket_service.dart';
import 'package:gyzyleller/core/services/fcm_token_provider.dart';
import 'package:gyzyleller/core/services/fcm_token_synchronizer.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';
import 'package:intl/date_symbol_data_local.dart';

@immutable
final class ApplicationInitialize {
  const ApplicationInitialize._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await runZonedGuarded<Future<void>>(_initialize, (error, stack) {});
  }

  static Future<void> _initialize() async {
    print('🚀 ApplicationInitialize starting...');
    try {
      await GetStorage.init();
      print('📦 GetStorage initialized');
      Get.put(GetStorage());
      Get.put(ChatSocketService(), permanent: true);
      await initializeDateFormatting('tk', null);
      await initializeDateFormatting('ru', null);

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await DeviceUtility.instance.initPackageInfo();
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      final localNotificationsService = LocalNotificationsService.instance();
      await localNotificationsService.init();
      final firebaseMessagingService = FirebaseMessagingService.instance();
      await firebaseMessagingService.init(
          localNotificationsService: localNotificationsService);
      print('🔥 Firebase & Notifications initialized');

      // Ayterek approach: Init FCM Token Provider & Synchronizer
      final fcmTokenProvider = FcmTokenProvider();
      await fcmTokenProvider.init();
      Get.put(fcmTokenProvider, permanent: true);

      final fcmTokenSynchronizer = FcmTokenSynchronizer(fcmTokenProvider);
      fcmTokenSynchronizer.init();
      Get.put(fcmTokenSynchronizer, permanent: true);

      await FirebaseMessaging.instance.subscribeToTopic('EVENT');
      print('✅ ApplicationInitialize complete!');
    } catch (e, stack) {
      print('❌ ApplicationInitialize Error: $e');
      print('❌ StackTrace: $stack');
    }
  }
}
