import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:gyzyleller/shared/constants/list_constants.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/language_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class AboutView extends StatelessWidget {
  AboutView({super.key});
  final LanguageController languageController = Get.put(LanguageController());
  final HomeController homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Ulgam barada".tr,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            '   Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.'
                .tr,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
      backgroundColor: ColorConstants.background,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: homeController.bottomNavBarSelectedIndex.value,
        onTap: (index) async {
          homeController.changePage(index);
        },
        selectedIcons: ListConstants.selectedIcons,
        icons: ListConstants.mainIcons,
         labels: ["all_tab".tr, "tasks_tab".tr, "chat".tr, "menu_tab".tr],
      ),
    );
  }
}
