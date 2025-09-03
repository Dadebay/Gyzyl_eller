import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';

@immutable
final class ApplicationInitialize {
  const ApplicationInitialize._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await runZonedGuarded<Future<void>>(_initialize, (error, stack) {});
  }

  static Future<void> _initialize() async {
    try {
      await GetStorage.init();
      Get.put(ThemeController());
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await DeviceUtility.instance.initPackageInfo();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final localNotificationsService = LocalNotificationsService.instance();
      await localNotificationsService.init();
      final firebaseMessagingService = FirebaseMessagingService.instance();
      await firebaseMessagingService.init(localNotificationsService: localNotificationsService);
      await FirebaseMessaging.instance.subscribeToTopic('EVENT');
    } catch (e) {}
  }
}
