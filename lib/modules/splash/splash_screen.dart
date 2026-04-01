import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/bottomnavbar/bindings/home_binding.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/bottom_nav_bar_view.dart';

import 'package:gyzyleller/modules/onboarding/views/lang_view.dart';
import 'package:gyzyleller/shared/constants/image_constants.dart';

const String kMasterTopicRu = 'MASTER_TOPIC_RU';
const String kMasterTopicTk = 'MASTER_TOPIC_TK';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _firebaseToTopic();
    _checkOnboardingStatus();
  }

  Future<void> _firebaseToTopic() async {
    final box = GetStorage();
    final lang = box.read('langCode') ?? 'tk';
    if (lang == 'ru') {
      await FirebaseMessaging.instance.subscribeToTopic(kMasterTopicRu);
      await FirebaseMessaging.instance.unsubscribeFromTopic(kMasterTopicTk);
    } else {
      await FirebaseMessaging.instance.subscribeToTopic(kMasterTopicTk);
      await FirebaseMessaging.instance.unsubscribeFromTopic(kMasterTopicRu);
    }
  }

  final HomeController controller = Get.put(HomeController());

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return;
      }
    } catch (_) {
      return;
    }

    final box = GetStorage();
    bool isFirstLaunch = box.read('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      print('👋 First launch detected. Navigating to onboarding...');
      // Mark as seen immediately so it doesn't show again on next launch
      await box.write('isFirstLaunch', false);
      Get.off(() => LanguagePageFirst());
    } else {
      print('🏠 Onboarding already seen. Navigating to Home...');
      Get.off(() => const BottomNavBar(), binding: HomeBinding());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteColor,
      body: Center(
        child: Image.asset(
          ImageConstants.logoSplash,
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
