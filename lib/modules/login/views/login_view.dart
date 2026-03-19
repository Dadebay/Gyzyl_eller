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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    'login_instruction'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'phone_number_label'.tr,
                      prefixText: '+993 ',
                      prefixStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.passwordController,
                        obscureText: controller.obscureText.value,
                        decoration: InputDecoration(
                          labelText: 'password_input_label'.tr,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 12.0),
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
                const SizedBox(height: 20),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.2,
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
                                    fontSize: 14,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: 'agreement_text'.tr,
                                  style: const TextStyle(
                                    color: ColorConstants.kPrimaryColor2,
                                    decoration: TextDecoration.underline,
                                    fontSize: 14,
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
                const SizedBox(height: 30),
                Obx(() => ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.kPrimaryColor2,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'continue_button'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    )),
              ],
            ),
          ),
        ));
  }
}
