import 'package:gyzyleller/core/init/app_initialize.dart';
import 'package:gyzyleller/core/init/translation_service.dart';
import 'package:gyzyleller/modules/splash/splash_screen.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/utils/global_safe_area_wrapper.dart';

Future<void> main() async {
  await ApplicationInitialize.initialize();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

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
