// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/login/controllers/login_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class LoginView extends GetView<LoginController> {
  // ignore: use_super_parameters
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'login_title'.tr,
      ),
      backgroundColor: ColorConstants.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Başlık ve açıklama kısmı, ikon ile birlikte
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConstants.whiteColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Icon(
                      Icons.lock_outline,
                      color: ColorConstants.kPrimaryColor2,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'login_instruction'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Telefon numarası kutusu
              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.phoneNumberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone,
                        color: ColorConstants.kPrimaryColor2, size: 22),
                    labelText: 'phone_number_label'.tr,
                    prefixText: '+993 ',
                    prefixStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 10.0),
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Şifre kutusu
              Obx(() => Container(
                    decoration: BoxDecoration(
                      color: ColorConstants.whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.passwordController,
                      obscureText: controller.obscureText.value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline,
                            color: ColorConstants.kPrimaryColor2, size: 22),
                        labelText: 'password_input_label'.tr,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0, horizontal: 10.0),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureText.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: ColorConstants.kPrimaryColor2,
                            size: 22,
                          ),
                          onPressed: controller.toggleObscureText,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 18),
              // Şartlar kutusu
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 1.15,
                        child: Checkbox(
                          value: controller.isChecked.value,
                          onChanged: (bool? newValue) {
                            controller.isChecked.value = newValue ?? false;
                          },
                          activeColor: ColorConstants.kPrimaryColor2,
                          side: const BorderSide(
                            color: ColorConstants.kPrimaryColor2,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'with_all_terms'.tr,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.5,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: 'agreement_text'.tr,
                                style: const TextStyle(
                                  color: ColorConstants.kPrimaryColor2,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Giriş butonu
              Obx(() => SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.kPrimaryColor2,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                        shadowColor:
                            ColorConstants.kPrimaryColor2.withOpacity(0.18),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'continue_button'.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
