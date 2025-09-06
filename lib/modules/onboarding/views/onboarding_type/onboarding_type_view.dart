import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/modules/onboarding/controllers/onboarding_type_controller.dart';

class OnboardingTypeView extends StatelessWidget {
  const OnboardingTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final IntroController controller = Get.put(IntroController());

    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: '',
        showBackButton: true,
        centerTitle: true,
        showElevation: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
            const SizedBox(height: 45),
            Obx(
              () => _buildIntroOption(
                context,
                'onboarding_how_to_create_task'.tr,
                IconConstants.personwork2,
                controller.isCreateTaskSelected.value,
                () {
                  controller.toggleSelection(true);
                },
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildIntroOption(
                context,
                'onboarding_how_to_be_executor'.tr,
                IconConstants.personwork,
                !controller.isCreateTaskSelected.value,
                () {
                  controller.toggleSelection(false);
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 175,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.navigateToOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.kPrimaryColor2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "continue_button".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        color: ColorConstants.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroOption(BuildContext context, String title,
      String svgAssetPath, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              svgAssetPath,
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    color: ColorConstants.fonts,
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check,
                  color: ColorConstants.kPrimaryColor2, size: 24),
          ],
        ),
      ),
    );
  }
}
