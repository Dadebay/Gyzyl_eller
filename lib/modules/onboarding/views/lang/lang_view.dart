import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/onboarding/views/lang/page/language_item_tile.dart';
import 'package:gyzyleller/modules/onboarding/views/lang/page/language_texts.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_type/onboarding_type_view.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_type/page/continue_button_section.dart';
import 'package:gyzyleller/modules/user_profile/controllers/language_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class LanguagePageFirst extends StatelessWidget {
  LanguagePageFirst({super.key});

  final LanguageController languageController = Get.put(LanguageController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: ''.tr,
        showBackButton: false,
        centerTitle: true,
        showElevation: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LanguageTexts(),
          // Dil seçenekleri
          LanguageItemTile(
            title: 'Türkmençe',
            iconPath: IconConstants.tmmflag,
            code: 'tk',
            languageController: languageController,
          ),
          const SizedBox(height: 12),
          LanguageItemTile(
            title: 'Русский',
            iconPath: IconConstants.ruuflag,
            code: 'ru',
            languageController: languageController,
          ),
          const Spacer(),
          ContinueButtonSection(
            onPressed: () {
              Get.to(() => const OnboardingTypeView());
            },
          ),
        ],
      ),
    );
  }
}
