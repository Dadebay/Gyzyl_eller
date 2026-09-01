// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _controller.forward();
    _firebaseToTopic();
    _checkOnboardingStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    // Wait for the animation to complete (3 seconds)
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    // Internet barmy-ýok barla: DNS cache aldatmasyn diýip real TCP bağlantı synanyşylýar
    bool hasInternet = false;
    try {
      final baseUri = Uri.parse(Api().urlSimple);
      final host = baseUri.host;
      final port = baseUri.hasPort ? baseUri.port : (baseUri.scheme == 'https' ? 443 : 80);
      final socket = await Socket.connect(
        host,
        port,
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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              ImageConstants.splashBackground,
              fit: BoxFit.cover,
            ),
          ),

          // Progress Bar and Percentage
          Positioned(
            left: 40,
            right: 40,
            bottom: 80,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final value = _animation.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Percentage Text
                    Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        color: ColorConstants.fonts,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar Container
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ColorConstants.fonts.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          // Active Progress Line
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    ColorConstants.kPrimaryColor,
                                    ColorConstants.blue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorConstants.kPrimaryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
