import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/login/controllers/auth_service.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscureText = true.obs;
  final isChecked = false.obs;

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
      CustomWidgets.showSnackBar(
        'error_title',
        'invalid_phone_number',
        ColorConstants.redColor,
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      CustomWidgets.showSnackBar(
        'error_title',
        'empty_password',
        ColorConstants.redColor,
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
