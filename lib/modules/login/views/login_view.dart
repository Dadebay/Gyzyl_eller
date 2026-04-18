// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/login/controllers/login_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginView extends GetView<LoginController> {
  // ignore: use_super_parameters
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'login_title'.tr,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 24,
            color: ColorConstants.kPrimaryColor2,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: ColorConstants.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                Column(
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      'login_instruction'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Telefon numarası kutusu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: TextFormField(
                        controller: controller.phoneNumberController,
                        keyboardType: TextInputType.phone,
                        maxLength: 8,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        validator: controller.validatePhone,
                        decoration: InputDecoration(
                          prefixIcon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedCall,
                              color: ColorConstants.kPrimaryColor2,
                              size: 22),
                          labelText: 'phone_number_label'.tr,
                          prefixText: '+993 ',
                          prefixStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18.0, horizontal: 10.0),
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          hintStyle: const TextStyle(color: Colors.grey),
                          errorStyle: const TextStyle(height: 0, fontSize: 0),
                        ),
                      ),
                    ),
                    Obx(() {
                      final err = controller.phoneError.value;
                      if (err.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(left: 14, top: 6),
                        child: Text(err,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 18),
                // Şifre kutusu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          child: TextFormField(
                            controller: controller.passwordController,
                            obscureText: controller.obscureText.value,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            validator: controller.validatePassword,
                            decoration: InputDecoration(
                              prefixIcon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedLockPassword,
                                  color: ColorConstants.kPrimaryColor2,
                                  size: 22),
                              labelText: 'password_input_label'.tr,
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18.0, horizontal: 10.0),
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              errorStyle:
                                  const TextStyle(height: 0, fontSize: 0),
                              suffixIcon: IconButton(
                                icon: HugeIcon(
                                  icon: controller.obscureText.value
                                      ? HugeIcons.strokeRoundedViewOffSlash
                                      : HugeIcons.strokeRoundedView,
                                  color: ColorConstants.kPrimaryColor2,
                                  size: 22,
                                ),
                                onPressed: controller.toggleObscureText,
                              ),
                            ),
                          ),
                        )),
                    Obx(() {
                      final err = controller.passwordError.value;
                      if (err.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(left: 14, top: 6),
                        child: Text(err,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 18),
                // Şartlar kutusu
                // Obx(
                //   () => Container(
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 12, vertical: 10),
                //     child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         GestureDetector(
                //           onTap: () {
                //             controller.isChecked.value =
                //                 !controller.isChecked.value;
                //           },
                //           behavior: HitTestBehavior.translucent,
                //           child: Container(
                //             width: 38, // Increased size for easier tap
                //             height: 38,
                //             alignment: Alignment.center,
                //             child: Container(
                //               width: 26,
                //               height: 26,
                //               decoration: BoxDecoration(
                //                 color: controller.isChecked.value
                //                     ? ColorConstants.kPrimaryColor2
                //                     : Colors.white,
                //                 borderRadius: BorderRadius.circular(8),
                //                 border: Border.all(
                //                   color: Colors.white,
                //                   width: 1.5,
                //                 ),
                //               ),
                //               child: controller.isChecked.value
                //                   ? const HugeIcon(
                //                       icon: HugeIcons.strokeRoundedTick02,
                //                       size: 18,
                //                       color: Colors.white)
                //                   : null,
                //             ),
                //           ),
                //         ),
                //         const SizedBox(width: 10),
                //         Expanded(
                //           child: RichText(
                //             text: TextSpan(
                //               children: [
                //                 TextSpan(
                //                   text: 'with_all_terms'.tr,
                //                   style: const TextStyle(
                //                     color: Colors.black,
                //                     fontWeight: FontWeight.w400,
                //                     fontSize: 14.5,
                //                   ),
                //                 ),
                //                 TextSpan(
                //                   text: 'agreement_text'.tr,
                //                   style: const TextStyle(
                //                     color: ColorConstants.blue,
                //                     fontSize: 14.5,
                //                     fontWeight: FontWeight.w400,
                //                     decoration: TextDecoration.underline,
                //                   ),
                //                   recognizer: TapGestureRecognizer()
                //                     ..onTap = () {
                //                       _launchURL(
                //                           '${Api().urlSimple}privacy-police/$_langWeb');
                //                       controller.isChecked.value =
                //                           !controller.isChecked.value;
                //                     },
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 32),
                // Giriş butonu
                Obx(() => SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
      ),
    );
  }
}
