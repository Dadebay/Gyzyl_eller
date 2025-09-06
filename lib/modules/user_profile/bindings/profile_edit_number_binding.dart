import 'package:get/get.dart';
import 'package:gyzyleller/modules/user_profile/controllers/profile_edit_number_controller.dart';

class ProfileEditNumberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditNumberController>(
      () => ProfileEditNumberController(),
    );
  }
}