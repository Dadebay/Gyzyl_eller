import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/login/controllers/auth_service.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final obscureText = true.obs;
  final isChecked = false.obs;
  // tracks whether user attempted submit (to enable live re-validation)
  final submitted = false.obs;
  final phoneError = ''.obs;
  final passwordError = ''.obs;

  @override
  void onClose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  String? validatePhone(String? value) {
    String? error;
    if (value == null || value.isEmpty) {
      error = 'field_required'.tr;
    } else if (value.length != 8) {
      error = 'invalid_phone_number'.tr;
    } else {
      final prefix = value.substring(0, 2);
      const validPrefixes = ['61', '62', '63', '64', '65', '71'];
      if (!validPrefixes.contains(prefix)) {
        error = 'wrong_phone_prefix'.tr;
      }
    }
    if (submitted.value) {
      phoneError.value = error ?? '';
    }
    return error;
  }

  String? validatePassword(String? value) {
    String? error;
    if (value == null || value.isEmpty) {
      error = 'field_required'.tr;
    } else if (value.length < 8) {
      error = 'password_min_8'.tr;
    }
    if (submitted.value) {
      passwordError.value = error ?? '';
    }
    return error;
  }

  Future<void> login() async {
    submitted.value = true;
    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

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
