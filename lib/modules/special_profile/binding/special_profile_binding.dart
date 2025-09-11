import 'package:get/get.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_form_controller.dart';

class SpecialProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpecialProfileController>(() => SpecialProfileController());
    Get.lazyPut<SpecialProfileFormController>(
        () => SpecialProfileFormController());
  }
}
