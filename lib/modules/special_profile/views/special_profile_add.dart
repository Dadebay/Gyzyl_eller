import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/widgets/bio_text_field.dart';
import 'package:gyzyleller/modules/special_profile/widgets/file_upload_area.dart';
import 'package:gyzyleller/modules/special_profile/widgets/info_card.dart';
import 'package:gyzyleller/modules/special_profile/widgets/profile_avatar.dart';
import 'package:gyzyleller/modules/special_profile/widgets/selected_images.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';

class SpecialProfileAdd extends StatefulWidget {
  const SpecialProfileAdd({super.key});

  @override
  State<SpecialProfileAdd> createState() => _SpecialProfileAddState();
}

class _SpecialProfileAddState extends State<SpecialProfileAdd> {
  final SpecialProfileController controller =
      Get.put(SpecialProfileController(), permanent: true);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortBioController = TextEditingController();
  final TextEditingController longBioController = TextEditingController();
  final TextEditingController legalizationTypeController = TextEditingController();
  final TextEditingController workTejribeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = controller.profile.value.name ?? '';
    shortBioController.text = controller.profile.value.shortBio ?? '';
    longBioController.text = controller.profile.value.longBio ?? '';
    legalizationTypeController.text = controller.profile.value.legalizationType ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    shortBioController.dispose();
    longBioController.dispose();
    legalizationTypeController.dispose();
    workTejribeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'specialist_profile_title'.tr,
      ),
      backgroundColor: ColorConstants.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileAvatar(controller: controller, nameController: nameController),
            const SizedBox(height: 15),
            BioTextField(
              controller: shortBioController,
              hintText: 'short_bio_hint'.tr,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            BioTextField(
              controller: legalizationTypeController,
              hintText: 'legalization_type_hint'.tr,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            BioTextField(
              controller: longBioController,
              hintText: 'long_bio_hint'.tr,
              maxLines: 5,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            BioTextField(
              controller: workTejribeController,
              hintText: 'work_tejribe'.tr,
              onChanged: (String value) {},
            ),
            const SizedBox(height: 15),
            InfoCard(
              icon: Icons.access_time,
              text: 'read_the_rules'.tr,
              color: ColorConstants.whiteColor,
              textColor: ColorConstants.fonts,
            ),
            const SizedBox(height: 15),
            Text(
              'my_works_title'.tr,
              style: const TextStyle(
                fontSize: 14,
                color: ColorConstants.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const FileUploadSection(),
            const SizedBox(height: 10),
            SelectedImages(controller: controller),
            const SizedBox(height: 25),
            CustomElevatedButton(
              onPressed: () {
                controller.saveMasterProfile(
                  name: nameController.text,
                  shortBio: shortBioController.text,
                  longBio: longBioController.text,
                  legalizationType: legalizationTypeController.text,
                );
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
