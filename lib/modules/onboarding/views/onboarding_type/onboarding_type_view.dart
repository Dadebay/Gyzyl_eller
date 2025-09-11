import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/onboarding/controllers/onboarding_type_controller.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_type/page/continue_button_section.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_type/page/intro_option_tile.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_type/page/onboarding_texts.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

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
            const OnboardingTexts(),
            const SizedBox(height: 45),
            Obx(
              () => IntroOptionTile(
                title: 'onboarding_how_to_create_task'.tr,
                svgAssetPath: IconConstants.personwork2,
                isSelected: controller.isCreateTaskSelected.value,
                onTap: () => controller.toggleSelection(true),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => IntroOptionTile(
                title: 'onboarding_how_to_be_executor'.tr,
                svgAssetPath: IconConstants.personwork,
                isSelected: !controller.isCreateTaskSelected.value,
                onTap: () => controller.toggleSelection(false),
              ),
            ),
            const Spacer(),
            ContinueButtonSection(
              onPressed: controller.navigateToOnboarding,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
