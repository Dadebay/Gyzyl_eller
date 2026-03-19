import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/onboarding/views/lang/continue_button_section.dart';
import 'package:gyzyleller/modules/onboarding/views/lang/language_texts.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_view.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/language_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/language_selection_tile.dart';

class LanguagePageFirst extends StatelessWidget {
  LanguagePageFirst({super.key});

  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: ''.tr,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LanguageTexts(),
          const SizedBox(height: 12),
          const LanguageSelectionTile(
            title: 'Türkmençe',
            iconPath: IconConstants.tmmflag,
            code: 'tk',
          ),
          const SizedBox(height: 12),
          const LanguageSelectionTile(
            title: 'Русский',
            iconPath: IconConstants.ruuflag,
            code: 'ru',
          ),
          const Spacer(),
          ContinueButtonSection(
            onPressed: () {
              Get.to(() => const OnboardingScreen());
            },
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
