import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/language_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class LanguageSelectionTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final String code;
  final bool goBack;

  const LanguageSelectionTile({
    super.key,
    required this.title,
    required this.iconPath,
    required this.code,
    this.goBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController =
        Get.find<LanguageController>();
    return Obx(() {
      bool isSelected = languageController.selectedLanguage.value == code;
      return InkWell(
        onTap: () {
          languageController.changeLanguage(code);
          if (goBack) Get.back();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.asset(iconPath, width: 34, height: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              if (isSelected)
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedTick02,
                  color: ColorConstants.kPrimaryColor2,
                  size: 24,
                ),
            ],
          ),
        ),
      );
    });
  }
}
