import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/chats/controllers/notification_controller.dart';
import 'package:gyzyleller/modules/chats/views/chats_view.dart';
import 'package:gyzyleller/shared/constants/list_constants.dart';
import 'package:gyzyleller/modules/all/views/all_view.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/modules/task/task_view.dart';
import 'package:gyzyleller/modules/settings_profile/views/settings_view.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final HomeController homeController = Get.put(HomeController());
  final ChatController chatController =
      Get.put(ChatController(), permanent: true);
  final NotificationController notifController =
      Get.put(NotificationController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      debugPrint('_checkForUpdate Error: $e');
    }
  }

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
              labels: ["all_tab".tr, "tasks_tab".tr, "chat".tr, "menu_tab".tr],
              badges: [
                0,
                0,
                chatController.unreadCount.value,
                chatController.notifCount.value
              ],
            ),
          )),
    );
  }
}
