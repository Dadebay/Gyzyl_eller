import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/language_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/language_selection_tile.dart';
import 'package:hugeicons/hugeicons.dart';

class LanguagePage extends StatelessWidget {
  LanguagePage({super.key});
  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'language'.tr,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 24,
            color: ColorConstants.kPrimaryColor2,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: ColorConstants.background,
      body: Column(
        children: [
          const SizedBox(height: 12),
          const LanguageSelectionTile(
            title: 'Türkmençe',
            iconPath: IconConstants.tmflag,
            code: 'tk',
          ),
          const SizedBox(height: 12),
          const LanguageSelectionTile(
            title: 'Русский',
            iconPath: IconConstants.ruflag,
            code: 'ru',
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kPrimaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "save".tr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ColorConstants.whiteColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
