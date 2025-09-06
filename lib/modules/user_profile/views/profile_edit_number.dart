import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/user_profile/controllers/profile_edit_number_controller.dart';

class PhoneNumberInputScreen extends GetView<ProfileEditNumberController> {
  const PhoneNumberInputScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.red),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Belgini çalyşmak',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(() => Text(
                  controller.isCodeInput.value
                      ? 'Telefon belgiňize gelen kody giriziň'
                      : 'Täze çalyşmak isleýän nomeriňizi belläň we tassyklayjy kody alyň',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                )),
            SizedBox(height: 30),
            Obx(() => _buildInputField(
                  controller: controller.phoneController,
                  label:
                      controller.isCodeInput.value ? 'Kod' : 'Telefon belgiňiz',
                  readOnly: false,
                  keyboardType: controller.isCodeInput.value
                      ? TextInputType.number
                      : TextInputType.phone,
                  prefixText: controller.isCodeInput.value ? null : null,
                )),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: controller.continueButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kPrimaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Dowam et',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            readOnly: readOnly,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
