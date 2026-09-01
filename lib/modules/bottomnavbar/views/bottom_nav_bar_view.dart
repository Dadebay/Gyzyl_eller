// ignore_for_file: unused_field

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/job_notification_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/chats/controllers/notification_controller.dart';
import 'package:gyzyleller/modules/chats/views/chats_view.dart';
import 'package:gyzyleller/shared/constants/list_constants.dart';
import 'package:gyzyleller/modules/all/views/all_view.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/modules/task/task_view.dart';
import 'package:gyzyleller/modules/task/controllers/task_controller.dart';
import 'package:gyzyleller/modules/settings_profile/views/settings_view.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
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
  final JobNotificationController jobNotifController =
      Get.put(JobNotificationController(), permanent: true);

  final List<Widget> _pages = [
    const AllView(),
    const TaskView(),
    const ChatsView(),
    SettingsView(),
  ];

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
                    .pageTitleKeys[
                        homeController.bottomNavBarSelectedIndex.value]
                    .tr,
              ),
            ),
            body: IndexedStack(
              index: homeController.bottomNavBarSelectedIndex.value,
              children: _pages,
            ),
            bottomNavigationBar: Obx(
              () => CustomBottomNavBar(
                currentIndex: homeController.bottomNavBarSelectedIndex.value,
                onTap: (index) {
                  if (homeController.isBottomNavBarEnabled.value) {
                    final previousIndex =
                        homeController.bottomNavBarSelectedIndex.value;
                    homeController.changePage(index);

                    final bool isLoggedIn = AuthStorage().isLoggedIn;

                    final jobNotif = isLoggedIn &&
                            Get.isRegistered<JobNotificationController>()
                        ? Get.find<JobNotificationController>()
                        : null;

                    // Switch TO tab 0 (AllView): update badge from local AllController jobs.
                    // API sayaçlarını gereksiz yere tekrar çekmeyelim; updateAllTabCount() jobs tabanlıdır.
                    if (index == 0) {
                      if (jobNotif != null) {
                        jobNotif.ignoreLocalAllTabCount.value = false;
                        jobNotif.updateAllTabCount();
                      }

                      // Pull-to-refresh indicator'ı da görünür yapmak için
                      // refreshController.requestRefresh() çağırmalıyız.
                      if (Get.isRegistered<AllController>()) {
                        final all = Get.find<AllController>();
                        all.refreshController.requestRefresh();
                        all.fetchJobs(isRefresh: true);
                      } else {
                        final all = Get.put(AllController(), permanent: true);
                        all.refreshController.requestRefresh();
                        all.fetchJobs(isRefresh: true);
                      }
                    }

                    // (index==1 için refresh akışı aşağıda tek noktadan yönetiliyor)

                    // Switch AWAY from tab 0: clear tab 0 badge
                    if (previousIndex == 0 && index != 0 && jobNotif != null) {
                      jobNotif.clearAllTabNotifications();
                    }

                    // Switch AWAY from tab 1: immediately zero the badge,
                    // then async-clear on the API side
                    if (previousIndex == 1 && index != 1 && jobNotif != null) {
                      jobNotif.tasksTabCount.value = 0;
                      jobNotif.clearTasksTabNotifications();
                      return; // skip updateTasksTabCount — badge is already 0
                    }

                    // Switch TO tab 1 (Tasks): önce local split ile badge'i hemen göster,
                    // sonra server sayaçlarını yenile.
                    if (index == 1) {
                      if (jobNotif != null) {
                        jobNotif.updateTasksTabCount();
                        jobNotif.fetchNotificationCounters();
                      }

                      if (Get.isRegistered<TaskController>()) {
                        Get.find<TaskController>()
                            .refreshAllTabsWithIndicator();
                      } else {
                        Get.put(TaskController()).refreshAllTabsWithIndicator();
                      }

                      return;
                    }

                    // Chats/Settings/diğer tablarda da badge'lerin güncel kalması için
                    // hem server sayaçlarını yenileyelim hem de local split hesaplayalım.
                    // Ayrıca AllView (index==0) IndexedStack'de canlı olduğu için
                    // local badge hesaplayabilmek adına AllController.jobs'u da tazeleyelim.
                    if (jobNotif != null && index != 0) {
                      jobNotif.fetchNotificationCounters();
                      jobNotif.updateAllTabCount();
                      jobNotif.updateTasksTabCount();

                      if (Get.isRegistered<AllController>()) {
                        Get.find<AllController>().fetchJobs(isRefresh: true);
                      } else {
                        Get.put(AllController(), permanent: true)
                            .fetchJobs(isRefresh: true);
                      }
                    }
                  }
                },
                icons: ListConstants.mainIcons,
                selectedIcons: ListConstants.selectedIcons,
                labels: [
                  "all_tab".tr,
                  "tasks_tab".tr,
                  "chat".tr,
                  "menu_tab".tr
                ],
                badges: [
                  jobNotifController.allTabCount.value,
                  jobNotifController.tasksTabCount.value,
                  chatController.unreadCount.value,
                  chatController.notifCount.value
                ],
              ),
            ),
          )),
    );
  }
}
