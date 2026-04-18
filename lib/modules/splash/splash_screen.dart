import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gyzyleller/modules/bottomnavbar/bindings/home_binding.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/bottom_nav_bar_view.dart';
import 'package:gyzyleller/modules/onboarding/views/lang_view.dart';
import 'package:gyzyleller/shared/constants/image_constants.dart';
import 'package:gyzyleller/shared/no_internet_screen.dart';

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

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Internet barmy-ýok barla: DNS cache aldatmasyn diýip real TCP bağlantı synanyşylýar
    bool hasInternet = false;
    try {
      final socket = await Socket.connect(
        'ayterek.ajayyptilsimatlar.com',
        80,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      hasInternet = true;
    } catch (_) {
      hasInternet = false;
    }

    if (!mounted) return;

    if (!hasInternet) {
      Get.offAll(() => const NoInternetScreen());
      return;
    }

    final box = GetStorage();
    final bool isFirstLaunch = box.read('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await box.write('isFirstLaunch', false);
      Get.off(() => LanguagePageFirst());
    } else {
      Get.off(() => const BottomNavBar(), binding: HomeBinding());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        ImageConstants.splashBackground,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}
