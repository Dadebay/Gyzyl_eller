import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:gyzyleller/core/constants/list_constants.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/user_profile/controllers/language_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class AboutView extends StatelessWidget {
  final LanguageController languageController = Get.put(LanguageController());
  final HomeController homeController = Get.find<HomeController>();
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: "About Us".tr, showElevation: true, showBackButton: true),
      backgroundColor: ColorConstants.background,
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
}
