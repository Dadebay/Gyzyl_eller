import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class FileUploadArea extends StatelessWidget {
  final SpecialProfileController controller;
  const FileUploadArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.pickImage(),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [6, 3],
        color: Colors.grey.shade400,
        strokeWidth: 1.5,
        child: Container(
          color: ColorConstants.whiteColor,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              SvgPicture.asset(IconConstants.uploadfoto),
              const SizedBox(height: 10),
              Text(
                'click_to_upload'.tr,
                style: TextStyle(color: ColorConstants.kPrimaryColor2, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                'PNG, JPG',
                style: TextStyle(color: ColorConstants.secondary, fontSize: 12),
              ),
              Obx(() => Text(
                    '${'max_file_size'.tr} ${controller.images.length}/8',
                    style: TextStyle(color: ColorConstants.secondary, fontSize: 12),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
