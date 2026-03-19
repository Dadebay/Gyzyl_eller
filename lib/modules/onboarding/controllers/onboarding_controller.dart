// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:gyzyleller/modules/bottomnavbar/views/bottom_nav_bar_view.dart';
import 'package:gyzyleller/shared/constants/image_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class OnboardingController {
  final PageController pageController = PageController();
  final VoidCallback? onComplete;
  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

  late final List<OnboardingPage> pages;

  final List<OnboardingPage> _executorOnboardingPages = [
    OnboardingPage(
      image: ImageConstants.onboarding13,
      title: 'title_onbor_13'.tr,
      description: 'desc_onbor_13'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding11,
      title: 'title_onbor_6'.tr,
      description: 'desc_onbor_6'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding22,
      title: 'title_onbor_7'.tr,
      description: 'desc_onbor_7'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding33,
      title: 'title_onbor_8'.tr,
      description: 'desc_onbor_8'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding44,
      title: 'title_onbor_9'.tr,
      description: 'desc_onbor_9'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding55,
      title: 'title_onbor_10'.tr,
      description: 'desc_onbor_10'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding66,
      title: 'title_onbor_11'.tr,
      description: 'desc_onbor_11'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding77,
      title: 'title_onbor_12'.tr,
      description: 'desc_onbor_12'.tr,
    ),
  ];

  final List<OnboardingPage> _executorOnboardingPagesRu = [
    OnboardingPage(
      image: ImageConstants.onboarding13_ru,
      title: 'title_onbor_13'.tr,
      description: 'desc_onbor_13'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding11_ru,
      title: 'title_onbor_6'.tr,
      description: 'desc_onbor_6'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding22_ru,
      title: 'title_onbor_7'.tr,
      description: 'desc_onbor_7'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding33_ru,
      title: 'title_onbor_8'.tr,
      description: 'desc_onbor_8'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding44_ru,
      title: 'title_onbor_9'.tr,
      description: 'desc_onbor_9'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding55_ru,
      title: 'title_onbor_10'.tr,
      description: 'desc_onbor_10'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding66_ru,
      title: 'title_onbor_11'.tr,
      description: 'desc_onbor_11'.tr,
    ),
    OnboardingPage(
      image: ImageConstants.onboarding77_ru,
      title: 'title_onbor_12'.tr,
      description: 'desc_onbor_12'.tr,
    ),
  ];

  OnboardingController({
    required BuildContext context,
    this.onComplete,
  }) {
    final locale = Localizations.localeOf(context);
    pages = locale.languageCode == 'ru'
        ? _executorOnboardingPagesRu
        : _executorOnboardingPages;
  }

  void onPageChanged(int index) {
    currentIndexNotifier.value = index;
  }

  void nextPage() {
    if (currentIndexNotifier.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding(BuildContext? context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    onComplete?.call();
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void dispose() {
    pageController.dispose();
    currentIndexNotifier.dispose();
  }
}
