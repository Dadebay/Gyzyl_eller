import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/widgets/bio_text_field.dart';
import 'package:gyzyleller/modules/special_profile/widgets/file_upload_area.dart';
import 'package:gyzyleller/modules/special_profile/widgets/info_card.dart';
import 'package:gyzyleller/modules/special_profile/widgets/profile_avatar.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController workTejribeController = TextEditingController();

  String? _selectedLegalizationType;
  List<Map<String, dynamic>> _fileMetadata = [];

  static const List<String> _legalizationValues = [
    'entrepreneur',
    'individual',
    'private',
    'business_entity',
    'other',
  ];

  String get _langWeb => GetStorage().read('langCode') ?? 'tk';

  void _launchURL(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  }

  @override
  void initState() {
    super.initState();
    nameController.text = controller.profile.value.name ?? '';
    shortBioController.text = controller.profile.value.shortBio ?? '';
    longBioController.text = controller.profile.value.longBio ?? '';
    _selectedLegalizationType = controller.profile.value.legalizationType;
  }

  @override
  void dispose() {
    nameController.dispose();
    shortBioController.dispose();
    longBioController.dispose();
    workTejribeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'specialist_profile_title'.tr,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: ColorConstants.kPrimaryColor2,
            size: 26.0,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: ColorConstants.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileAvatar(
                controller: controller, nameController: nameController),
            const SizedBox(height: 15),
            BioTextField(
              controller: shortBioController,
              hintText: 'short_bio_hint'.tr,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            _buildLegalizationDropdown(),
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
            const SizedBox(height: 10),
            // ── Terms agreement ─────────────────────────────────────────
            Obx(
              () => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.isChecked.value =
                            !controller.isChecked.value;
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: controller.isChecked.value
                              ? ColorConstants.kPrimaryColor2
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: controller.isChecked.value
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'with_all_terms'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.5,
                              ),
                            ),
                            TextSpan(
                              text: 'agreement_text'.tr,
                              style: const TextStyle(
                                color: ColorConstants.blue,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _launchURL(
                                      '${Api().urlSimple}privacy-police/$_langWeb');
                                  controller.isChecked.value =
                                      !controller.isChecked.value;
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            FileUploadSection(
              onMetadataChanged: (metadata) {
                setState(() {
                  _fileMetadata = metadata;
                });
              },
            ),
            const SizedBox(height: 10),
            CustomElevatedButton(
              onPressed: () {
                if (!controller.isChecked.value) {
                  CustomWidgets.showSnackBar(
                    'error_title',
                    'please_agree_privacy',
                    ColorConstants.redColor,
                  );
                  return;
                }
                controller.saveMasterProfile(
                  name: nameController.text,
                  shortBio: shortBioController.text,
                  longBio: longBioController.text,
                  experience: workTejribeController.text,
                  legalizationType: _selectedLegalizationType ?? '',
                  fileMetadata: _fileMetadata,
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

  Widget _buildLegalizationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedLegalizationType,
            hint: Text(
              'legalization_type_hint'.tr,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: ColorConstants.kPrimaryColor2,
            ),
            dropdownColor: Colors.white,
            items: _legalizationValues.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value.tr,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLegalizationType = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
