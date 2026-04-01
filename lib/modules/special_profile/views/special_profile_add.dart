import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/widgets/bio_text_field.dart';
import 'package:gyzyleller/modules/special_profile/widgets/file_upload_area.dart';
import 'package:gyzyleller/modules/special_profile/widgets/info_card.dart';
import 'package:gyzyleller/modules/special_profile/widgets/profile_avatar.dart';
import 'package:gyzyleller/modules/special_profile/widgets/selected_images.dart';
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
  final TextEditingController legalizationTypeController =
      TextEditingController();
  final TextEditingController workTejribeController = TextEditingController();

  bool _isTermsAgreed = false;

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
    legalizationTypeController.text =
        controller.profile.value.legalizationType ?? '';
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
            ProfileAvatar(
                controller: controller, nameController: nameController),
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
            // ── Terms agreement ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTermsAgreed = !_isTermsAgreed;
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _isTermsAgreed
                            ? ColorConstants.kPrimaryColor2
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ColorConstants.greyColor,
                          width: 1.5,
                        ),
                      ),
                      child: _isTermsAgreed
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
                                setState(() {
                                  _isTermsAgreed = !_isTermsAgreed;
                                });
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomElevatedButton(
              onPressed: () {
                if (!_isTermsAgreed) {
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
