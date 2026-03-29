// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingController controller;
  bool _isControllerInitialized = false;
  bool _isButtonEnabled = false;
  int _remainingSeconds = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startButtonTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isControllerInitialized) {
      controller = OnboardingController(
        context: context,
      );
      _isControllerInitialized = true;
    }
  }

  void _startButtonTimer() {
    setState(() {
      _isButtonEnabled = false;
      _remainingSeconds = 3;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _isButtonEnabled = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _handleContinue() {
    if (!_isButtonEnabled) return;

    if (controller.currentIndexNotifier.value == controller.pages.length - 1) {
      controller.skipOnboarding(context);
    } else {
      controller.nextPage();
      _startButtonTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: ''.tr,
      ),
      backgroundColor: ColorConstants.background,
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.pages.length,
                    onPageChanged: (index) {
                      controller.onPageChanged(index);
                    },
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0, vertical: 15.0),
                                child: Image.asset(
                                  page.image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              page.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.fonts,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: ColorConstants.fonts,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: controller.currentIndexNotifier,
                  builder: (context, currentIndex, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentIndex == index
                                ? ColorConstants.kPrimaryColor2
                                : ColorConstants.whiteColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Row(
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: controller.currentIndexNotifier,
                        builder: (context, currentIndex, _) {
                          if (currentIndex == 0) {
                            return const Expanded(
                              flex: 4,
                              child: SizedBox(),
                            );
                          }
                          return Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 48,
                              child: CustomElevatedButton(
                                onPressed: () {
                                  controller.pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  _startButtonTimer();
                                },
                                text: 'onboarding_skip_button'.tr,
                                backgroundColor: ColorConstants.secondary,
                                textColor: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 48,
                          child: CustomElevatedButton(
                            onPressed: _handleContinue,
                            text: _isButtonEnabled
                                ? 'continue_button'.tr
                                : '$_remainingSeconds',
                            backgroundColor: _isButtonEnabled
                                ? ColorConstants.kPrimaryColor2
                                : ColorConstants.kPrimaryColor2
                                    .withOpacity(0.6),
                            textColor: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
