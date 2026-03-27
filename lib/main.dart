import 'package:gyzyleller/core/init/app_initialize.dart';
import 'package:gyzyleller/core/init/translation_service.dart';
import 'package:gyzyleller/modules/splash/splash_screen.dart';
import 'dart:io';
import 'package:gyzyleller/shared/no_internet_screen.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/utils/global_safe_area_wrapper.dart';

Future<void> main() async {
  print('🎬 APP STARTING...');
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
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _hasInternet = true;
        });
      } else {
        setState(() {
          _hasInternet = false;
        });
      }
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
        home: _hasInternet ? const SplashScreen() : const NoInternetScreen(),
        builder: (context, child) {
          return GlobalSafeAreaWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
