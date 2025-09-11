import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class OnboardingTexts extends StatelessWidget {
  const OnboardingTexts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'onboarding_welcome_title'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorConstants.fonts,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            'onboarding_welcome_description'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: ColorConstants.fonts,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
