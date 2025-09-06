import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorConstants.kPrimaryColor2,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Içeri gir',
            style: TextStyle(
              color: ColorConstants.fonts,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: ColorConstants.background,
          elevation: 0,
        ),
        backgroundColor: ColorConstants.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    'Ulgama girmek we kod almak üçin telefon belginizi giriziň',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: controller.phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon belgiňiz',
                      prefixText: '+993 ',
                      prefixStyle: TextStyle(fontSize: 16, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
                      labelStyle: TextStyle(color: Colors.grey),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: controller.passwordController,
                        obscureText: controller.obscureText.value,
                        decoration: InputDecoration(
                          labelText: 'Açar söz',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                          labelStyle: const TextStyle(color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureText.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: controller.toggleObscureText,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (bool? newValue) {},
                      activeColor: ColorConstants.kPrimaryColor2,
                    ),
                    Text(
                      'Ähli şertleri bilen ',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('Yalasygyny tıklandı!');
                      },
                      child: Text(
                        'yalasygyny',
                        style: TextStyle(
                          color: ColorConstants.kPrimaryColor2,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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
                          : const Text(
                              'Dowam et',
                              style: TextStyle(
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
