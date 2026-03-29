import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';

class ContinueButtonSection extends StatelessWidget {
  final VoidCallback onPressed;

  const ContinueButtonSection({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 175,
          height: 48,
          child: CustomElevatedButton(
            onPressed: onPressed,
            text: "continue_button".tr,
            backgroundColor: ColorConstants.kPrimaryColor2,
            textColor: ColorConstants.whiteColor,
            borderRadius: 12,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
