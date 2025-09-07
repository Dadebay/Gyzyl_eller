import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/constants/list_constants.dart';
import 'package:gyzyleller/modules/all/views/all_view.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/home/views/home/home_view.dart';

import 'package:gyzyleller/modules/task/views/task_view.dart';
import 'package:gyzyleller/modules/user_profile/views/settings_view.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

import 'package:upgrader/upgrader.dart';

class BottomNavBar extends StatefulWidget {
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      HomeView(),
      AllView(),
      TaskView(),
      SettingsView(),
    ];

    return UpgradeAlert(
      upgrader: Upgrader(languageCode: 'ru'),
      dialogStyle: Platform.isAndroid
          ? UpgradeDialogStyle.material
          : UpgradeDialogStyle.cupertino,
      child: Obx(() => Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  homeController.bottomNavBarSelectedIndex.value == 3
                      ? kToolbarHeight
                      : 0),
              child: CustomAppBar(
                title: ListConstants
                    .pageNames[homeController.bottomNavBarSelectedIndex.value],
                showBackButton: false,
                centerTitle: false,
              ),
            ),
            body: pages[homeController.bottomNavBarSelectedIndex.value],
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: homeController.bottomNavBarSelectedIndex.value,
              onTap: (index) async {
                homeController.changePage(index);
              },
              selectedIcons: ListConstants.selectedIcons,
              unselectedIcons: ListConstants.mainIcons,
              labels: [
                'bottom_nav_my'.tr,
                'bottom_nav_all'.tr,
                'bottom_nav_tasks_tab'.tr,
                'bottom_nav_menu'.tr
              ],
            ),
          )),
    );
  }
}
