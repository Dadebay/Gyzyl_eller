import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileEditNumberController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxBool isCodeInput = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with initial phone number if passed
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
      // First step: Phone number input
      print('Telefon Numarası: ${phoneController.text}');
      isCodeInput.value = true;
      phoneController.clear(); // Clear for code input
    } else {
      // Second step: Code input
      print('Girilen Kod: ${phoneController.text}');
      // Here you would typically verify the code
    }
  }
}