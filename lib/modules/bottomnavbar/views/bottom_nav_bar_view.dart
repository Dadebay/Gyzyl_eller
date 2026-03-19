import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/chats/views/chats_view.dart';
import 'package:gyzyleller/shared/constants/list_constants.dart';
import 'package:gyzyleller/modules/all/views/all_view.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/modules/task/task_view.dart';
import 'package:gyzyleller/modules/settings_profile/views/settings_view.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

import 'package:upgrader/upgrader.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final HomeController homeController = Get.put(HomeController());
  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const AllView(),
      const TaskView(),
      const ChatsView(),
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
              ),
            ),
            body: pages[homeController.bottomNavBarSelectedIndex.value],
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: homeController.bottomNavBarSelectedIndex.value,
              onTap: (index) {
                if (homeController.isBottomNavBarEnabled.value) {
                  homeController.changePage(index);
                }
              },
              selectedIcons: ListConstants.selectedIcons,
              unselectedIcons: ListConstants.mainIcons,
              labels: [
                'bottom_nav_all'.tr,
                'bottom_nav_tasks_tab'.tr,
                'Çatlar',
                'bottom_nav_menu'.tr
              ],
              badges: [0, 0, chatController.unreadCount.value, 0],
            ),
          )),
    );
  }
}
