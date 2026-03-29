import 'dart:io';

import 'package:gyzyleller/core/init/app_initialize.dart';
import 'package:gyzyleller/core/init/translation_service.dart';
import 'package:gyzyleller/core/services/analytics_service.dart';
import 'package:gyzyleller/core/services/fcm_token_provider.dart';
import 'package:gyzyleller/core/services/fcm_token_synchronizer.dart';
import 'package:gyzyleller/modules/splash/splash_screen.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/shared/no_internet_screen.dart';
import 'package:gyzyleller/utils/global_safe_area_wrapper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
}

Future<void> main() async {
  print('🎬 APP STARTING...');
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;

  try {
    print('🔥 Initializing Firebase... (step 1: initializeApp)');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    print('✅ Firebase initialized. projectId=${DefaultFirebaseOptions.currentPlatform.projectId} appId=${DefaultFirebaseOptions.currentPlatform.appId}');
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
      await fcmTokenProvider.init();
      Get.put(fcmTokenProvider, permanent: true);

      final fcmTokenSynchronizer =
          FcmTokenSynchronizer(fcmTokenProvider);
      fcmTokenSynchronizer.init();
      Get.put(fcmTokenSynchronizer, permanent: true);

      await FirebaseMessaging.instance.subscribeToTopic('EVENT');

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final firebaseMessagingService =
          FirebaseMessagingService.instance();
      await firebaseMessagingService.init(
        localNotificationsService:
            LocalNotificationsService.instance(),
      );
    } catch (e) {
      print('❌ Firebase services error: $e');
    }
  } else {
    print('⚠️ Firebase NOT initialized → services skipped');
  }

  await ApplicationInitialize.initialize();

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

class MyApp extends StatefulWidget {
  MyApp({super.key});
  final storage = GetStorage();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      setState(() {
        _hasInternet =
            result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      });
    } catch (_) {
      setState(() {
        _hasInternet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        translations: TranslationService(),
        defaultTransition: Transition.fade,
        fallbackLocale: const Locale('tk'),
        debugShowCheckedModeBanner: false,
        locale: widget.storage.read('langCode') != null
            ? Locale(widget.storage.read('langCode'))
            : const Locale('tk'),
        home:
            _hasInternet ? const SplashScreen() : const NoInternetScreen(),
        builder: (context, child) {
          return GlobalSafeAreaWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}