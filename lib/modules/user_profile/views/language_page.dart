import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // Added Get import
import 'package:gyzyleller/core/constants/icon_constants.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/user_profile/controllers/language_controller.dart';

import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/core/constants/list_constants.dart';

class LanguagePage extends StatelessWidget {
  // Changed to StatelessWidget
  LanguagePage({super.key});
  final LanguageController languageController = Get.put(LanguageController());
  final HomeController homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstants.kPrimaryColor2,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'language'.tr,
          style: const TextStyle(
            color: ColorConstants.fonts,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildLanguageItem(
            context,
            'Türkmençe',
            IconConstants.tmflag,
            'tk',
            languageController,
          ),
          const SizedBox(height: 12),
          _buildLanguageItem(
            context,
            'Русский',
            IconConstants.ruflag,
            'ru',
            languageController,
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: homeController.bottomNavBarSelectedIndex.value,
        onTap: (index) async {
          homeController.changePage(index);
        },
        selectedIcons: ListConstants.selectedIcons,
        unselectedIcons: ListConstants.mainIcons,
        labels: ["Meniňki", "Hemmesi", "Yumuşlar", "Menýu"],
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String title, String iconPath,
      String code, LanguageController languageController) {
    return Obx(
      // Use Obx for reactivity
      () {
        bool isSelected = languageController.selectedLanguage.value == code;
        return InkWell(
          onTap: () {
            languageController.changeLanguage(code); // Call changeLanguage
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
                SvgPicture.asset(iconPath, width: 28, height: 28),
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
      },
    );
  }
}
