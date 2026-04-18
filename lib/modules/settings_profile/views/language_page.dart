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
      body: const Column(
        children: [
          SizedBox(height: 12),
          LanguageSelectionTile(
            title: 'Türkmençe',
            iconPath: IconConstants.tmflag,
            code: 'tk',
            goBack: true,
          ),
          SizedBox(height: 12),
          LanguageSelectionTile(
            title: 'Русский',
            iconPath: IconConstants.ruflag,
            code: 'ru',
            goBack: true,
          ),

          //   ),
          // )
        ],
      ),
    );
  }
}
