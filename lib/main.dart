import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/init/app_initialize.dart';
import 'package:gyzyleller/core/init/theme_controller.dart';
import 'package:gyzyleller/core/init/translation_service.dart';
import 'package:gyzyleller/core/theme/custom_dark_theme.dart';
import 'package:gyzyleller/core/theme/custom_light_theme.dart';

Future<void> main() async {
  await ApplicationInitialize.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: TranslationService(),
      defaultTransition: Transition.fade,
      fallbackLocale: const Locale('tr'),
      debugShowCheckedModeBanner: false,
      locale: storage.read('langCode') != null ? Locale(storage.read('langCode')) : const Locale('tr'),
      theme: CustomLightTheme().themeData,
      darkTheme: CustomDarkTheme().themeData,
      themeMode: Get.find<ThemeController>().themeMode,
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
