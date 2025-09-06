import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class OnboardingScreen extends StatelessWidget {
  final bool isTaskOnboarding;
  const OnboardingScreen({super.key, required this.isTaskOnboarding});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller =
        Get.put(OnboardingController(isTaskOnboarding: isTaskOnboarding));

    return Scaffold(
      appBar: CustomAppBar(
        title: ''.tr,
        showBackButton: true,
        centerTitle: true,
        showElevation: false,
      ),
      backgroundColor: ColorConstants.background,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pages.length,
              onPageChanged: controller.onPageChanged,
              itemBuilder: (context, index) {
                final page = controller.pages[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(page.image),
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
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.currentIndex.value == index
                        ? ColorConstants.kPrimaryColor2
                        : ColorConstants.whiteColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.skipOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'onboarding_skip_button'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.kPrimaryColor2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'continue_button'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
