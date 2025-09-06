import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/login/controllers/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscureText = true.obs;

  @override
  void onClose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  Future<void> login() async {
    if (phoneNumberController.text.length != 8) {
      Get.snackbar(
        'Error',
        'Lütfen geçerli bir telefon numarası girin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Lütfen şifrenizi girin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authService.login(
        phone: phoneNumberController.text,
        password: passwordController.text,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
