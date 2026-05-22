// ignore_for_file: avoid_print

import 'package:gyzyleller/core/init/app_initialize.dart';
import 'package:gyzyleller/core/init/translation_service.dart';
import 'package:gyzyleller/core/services/analytics_service.dart';
import 'package:gyzyleller/core/services/fcm_token_provider.dart';
import 'package:gyzyleller/core/services/fcm_token_synchronizer.dart';
import 'package:gyzyleller/core/theme/custom_light_theme.dart';
import 'package:gyzyleller/modules/splash/splash_screen.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';

import 'package:gyzyleller/utils/global_safe_area_wrapper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🔔 [FCM BACKGROUND] Message receivedddddddd:');
  print('   Dataaaaaaaa: ${message.data}');
  print('   Notification Titleeee: ${message.notification?.title}');
  print('   Notification Bodyrrrrrrrr: ${message.notification?.body}');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  try {
    final localNotifications = LocalNotificationsService.instance();
    await localNotifications.init(isBackground: true);

    final title = message.data['title'] as String?;
    final body = message.data['body'] as String?;

    // Firebase Messaging on Android natively displays background notifications
    // if `message.notification` is not null. We only manually show a local
    // notification if the server sent a pure data payload (notification is null).
    if (message.notification == null && (title != null || body != null)) {
      await localNotifications.showNotification(
          title, body, jsonEncode(message.data));
    }
  } catch (e) {
    print('❌ [FCM BACKGROUND] Error showing notification: $e');
  }
}

Future<void> main() async {
  print('🎬 APP STARTING...');
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Initialize basic services and GetStorage first
  await ApplicationInitialize.initialize();

  bool firebaseReady = false;

  try {
    print('🔥 Initializing Firebase... (step 1: initializeApp)');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    print(
        '✅ Firebase initialized. projectId=${DefaultFirebaseOptions.currentPlatform.projectId} appId=${DefaultFirebaseOptions.currentPlatform.appId}');
  } catch (e, stack) {
    print('❌ Firebase initializeApp ERROR: ${e.runtimeType}: $e');
    print('📋 Stack trace:\n$stack');
  }

  /// ✅ Firebase varsa çalıştır
  if (firebaseReady) {
    try {
      await AnalyticsService.initialize();
      await AnalyticsService.trackAppOpen();

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      final fcmTokenProvider = FcmTokenProvider();
      // FCM token alma internet gerektirdiği üçin fire-and-forget
      unawaited(fcmTokenProvider.init());
      Get.put(fcmTokenProvider, permanent: true);

      final fcmTokenSynchronizer = FcmTokenSynchronizer(fcmTokenProvider);
      fcmTokenSynchronizer.init();
      Get.put(fcmTokenSynchronizer, permanent: true);

      // Topic subscription-lar internet gerektirýär, fire-and-forget
      unawaited(FirebaseMessaging.instance.subscribeToTopic('EVENT'));

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      final firebaseMessagingService = FirebaseMessagingService.instance();
      await firebaseMessagingService.init(
        localNotificationsService: LocalNotificationsService.instance(),
      );
    } catch (e) {
      print('❌ Firebase services error: $e');
    }
  } else {
    print('⚠️ Firebase NOT initialized → services skipped');
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        theme: CustomLightTheme().themeData,
        // darkTheme: CustomDarkTheme().themeData,
        translations: TranslationService(),
        defaultTransition: Transition.fade,
        fallbackLocale: const Locale('tk'),
        debugShowCheckedModeBanner: false,
        locale: storage.read('langCode') != null
            ? Locale(storage.read('langCode'))
            : const Locale('tk'),
        home: const SplashScreen(),
        builder: (context, child) {
          return GlobalSafeAreaWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
