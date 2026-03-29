import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class LanguageTexts extends StatelessWidget {
  const LanguageTexts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'language_selection_title'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorConstants.fonts,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          'language_selection_instruction'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColorConstants.fonts,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
