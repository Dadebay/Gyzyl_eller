import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_type/onboarding_type_view.dart';
import 'package:gyzyleller/modules/user_profile/controllers/language_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';

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
          Text(
            'language_selection_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorConstants.fonts,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'language_selection_instruction'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorConstants.fonts,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildLanguageItem(
            context,
            'Türkmençe',
            IconConstants.tmmflag,
            'tk',
            languageController,
          ),
          const SizedBox(height: 12),
          _buildLanguageItem(
            context,
            'Русский',
            IconConstants.ruuflag,
            'ru',
            languageController,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 175,
                height: 48,
                child: CustomElevatedButton(
                  onPressed: () {
                    Get.to(OnboardingTypeView());
                  },
                  text: "continue_button".tr,
                  backgroundColor: ColorConstants.kPrimaryColor2,
                  textColor: ColorConstants.whiteColor,
                  borderRadius: 12,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String title, String iconPath,
      String code, LanguageController languageController) {
    return Obx(
      () {
        bool isSelected = languageController.selectedLanguage.value == code;
        return InkWell(
          onTap: () {
            languageController.changeLanguage(code);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset(iconPath, width: 34, height: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check,
                      color: ColorConstants.kPrimaryColor2, size: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
