import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileEditNumberController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxBool isCodeInput = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is String) {
      phoneController.text = Get.arguments as String;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void continueButtonPressed() {
    if (!isCodeInput.value) {
      print('Telefon Numarası: ${phoneController.text}');
      isCodeInput.value = true;
      phoneController.clear();
    } else {
      print('Girilen Kod: ${phoneController.text}');
    }
  }
}
