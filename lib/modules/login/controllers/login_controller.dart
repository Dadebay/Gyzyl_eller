import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/modules/login/controllers/auth_service.dart';

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

  final remainingSeconds = 0.obs;
  final storage = GetStorage();
  Timer? lockoutTimer;

  @override
  void onInit() {
    super.onInit();
    checkLockoutState();
  }

  @override
  void onClose() {
    lockoutTimer?.cancel();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void checkLockoutState() {
    final lockoutEndTimeStr = storage.read<String>('lockout_end_time');
    if (lockoutEndTimeStr != null) {
      final lockoutEndTime = DateTime.tryParse(lockoutEndTimeStr);
      if (lockoutEndTime != null) {
        final diff = lockoutEndTime.difference(DateTime.now());
        if (diff.inSeconds > 0) {
          startLockout(diff.inSeconds);
        } else {
          clearLockout();
        }
      }
    }
  }

  void startLockout(int seconds) {
    remainingSeconds.value = seconds;
    lockoutTimer?.cancel();
    lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 1) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        clearLockout();
      }
    });
  }

  void clearLockout() {
    remainingSeconds.value = 0;
    lockoutTimer?.cancel();
    storage.remove('lockout_end_time');
    storage.write('failed_login_attempts', 0);
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
    if (remainingSeconds.value > 0) return;

    submitted.value = true;
    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    try {
      isLoading.value = true;
      final success = await _authService.login(
        phone: phoneNumberController.text,
        password: passwordController.text,
      );
      if (success) {
        storage.write('failed_login_attempts', 0);
      } else {
        final attempts = (storage.read<int>('failed_login_attempts') ?? 0) + 1;
        storage.write('failed_login_attempts', attempts);
        if (attempts >= 3) {
          final endTime = DateTime.now().add(const Duration(minutes: 1));
          storage.write('lockout_end_time', endTime.toIso8601String());
          startLockout(60);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
