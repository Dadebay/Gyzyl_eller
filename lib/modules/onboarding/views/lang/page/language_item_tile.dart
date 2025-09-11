import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/user_profile/controllers/language_controller.dart';

class LanguageItemTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final String code;
  final LanguageController languageController;

  const LanguageItemTile({
    super.key,
    required this.title,
    required this.iconPath,
    required this.code,
    required this.languageController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = languageController.selectedLanguage.value == code;
      return InkWell(
        onTap: () {
          languageController.changeLanguage(code);
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
                const Icon(Icons.check,
                    color: ColorConstants.kPrimaryColor2, size: 24),
            ],
          ),
        ),
      );
    });
  }
}
