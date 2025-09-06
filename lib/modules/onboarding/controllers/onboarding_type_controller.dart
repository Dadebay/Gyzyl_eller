import 'package:get/get.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding/onboarding_view.dart';

class IntroController extends GetxController {
  var isCreateTaskSelected = true.obs;

  void toggleSelection(bool value) {
    isCreateTaskSelected.value = value;
  }

  void navigateToOnboarding() {
    Get.to(
        () => OnboardingScreen(isTaskOnboarding: isCreateTaskSelected.value));
  }
}
