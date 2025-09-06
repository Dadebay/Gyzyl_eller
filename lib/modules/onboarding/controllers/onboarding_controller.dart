import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/bottom_nav_bar_view.dart';
import 'package:gyzyleller/shared/constants/image_constants.dart';

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentIndex = 0.obs;

  late final List<OnboardingPage> pages;

  final List<OnboardingPage> _taskOnboardingPages = [
    OnboardingPage(
      image: ImageConstants.onboarding1,
      title: 'onboarding_publish_task_title'.tr,
      description: 'onboarding_publish_task_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding2,
      title: 'onboarding_find_specialist_title'.tr,
      description: 'onboarding_find_specialist_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding3,
      title: 'onboarding_complete_task_title'.tr,
      description: 'onboarding_complete_task_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding4,
      title: 'onboarding_find_specialist_title'.tr,
      description: 'onboarding_find_specialist_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding5,
      title: 'onboarding_complete_task_title'.tr,
      description: 'onboarding_complete_task_description'.tr,
    ),
  ];

  final List<OnboardingPage> _executorOnboardingPages = [
    OnboardingPage(
      image: ImageConstants.onboarding11,
      title: 'onboarding_publish_task_title'.tr,
      description: 'onboarding_publish_task_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding22,
      title: 'onboarding_find_specialist_title'.tr,
      description: 'onboarding_find_specialist_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding33,
      title: 'onboarding_complete_task_title'.tr,
      description: 'onboarding_complete_task_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding44,
      title: 'onboarding_publish_task_title'.tr,
      description: 'onboarding_publish_task_description'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding55,
      title: 'onboarding_find_specialist_title'.tr,
      description: 'onboarding_find_specialist_description'.tr,
    ),
  ];

  OnboardingController({required bool isTaskOnboarding}) {
    pages = isTaskOnboarding ? _taskOnboardingPages : _executorOnboardingPages;
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      skipOnboarding();
    }
  }

  void skipOnboarding() {
    Get.offAll(() => BottomNavBar());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
