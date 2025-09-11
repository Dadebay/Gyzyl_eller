import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/page/bio_text_field.dart';
import 'package:gyzyleller/modules/special_profile/page/dropdown_field.dart';
import 'package:gyzyleller/modules/special_profile/page/file_upload_area.dart';
import 'package:gyzyleller/modules/special_profile/page/info_card.dart';
import 'package:gyzyleller/modules/special_profile/page/profile_avatar.dart';
import 'package:gyzyleller/modules/special_profile/page/selected_images.dart';

import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';
import 'special_profile.dart';

class SpecialProfileAdd extends StatelessWidget {
  SpecialProfileAdd({super.key});
  final SpecialProfileController controller =
      Get.put(SpecialProfileController());

  @override
  Widget build(BuildContext context) {
    final shortBioController =
        TextEditingController(text: controller.shortBio.value);
    final longBioController =
        TextEditingController(text: controller.longBio.value);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'specialist_profile_title'.tr,
        showBackButton: true,
        centerTitle: true,
        showElevation: false,
      ),
      backgroundColor: ColorConstants.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileAvatar(controller: controller),
            const SizedBox(height: 30),
            BioTextField(
              controller: shortBioController,
              hintText: 'short_bio_hint'.tr,
              onChanged: (value) => controller.shortBio.value = value,
            ),
            const SizedBox(height: 15),
            DropdownField(
              hintText: 'Welaýat',
              value: controller.province.value.isEmpty
                  ? null
                  : controller.province.value,
              items: ['Ahal', 'Balkan', 'Daşoguz', 'Lebap', 'Mary'],
              onChanged: (value) => controller.province.value = value ?? '',
            ),
            const SizedBox(height: 15),
            BioTextField(
              controller: longBioController,
              hintText: 'long_bio_hint'.tr,
              maxLines: 5,
              onChanged: (value) => controller.longBio.value = value,
            ),
            const SizedBox(height: 20),
            InfoCard(
              icon: Icons.access_time,
              text: 'read_the_rules'.tr,
              color: ColorConstants.whiteColor,
              textColor: ColorConstants.fonts,
            ),
            const SizedBox(height: 20),
            Text(
              'my_works_title'.tr,
              style: TextStyle(
                fontSize: 14,
                color: ColorConstants.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            FileUploadArea(controller: controller),
            const SizedBox(height: 10),
            SelectedImages(controller: controller),
            const SizedBox(height: 25),
            CustomElevatedButton(
              onPressed: () {
                Get.to(() => SpecialProfile());
              },
              text: 'create_account_button'.tr,
              backgroundColor: ColorConstants.kPrimaryColor2,
              textColor: Colors.white,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}
