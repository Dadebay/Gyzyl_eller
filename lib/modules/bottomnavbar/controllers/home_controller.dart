import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/settings_controller.dart'; // Import SettingsController

class DisplaySubCategory {
  DisplaySubCategory();
}

class HomeController extends GetxController {
  var bottomNavBarSelectedIndex = 0.obs;
  var isBottomNavBarEnabled = true.obs;

  void changePage(int index) {
    bottomNavBarSelectedIndex.value = index;
  }

  void disableBottomNavBar() {
    isBottomNavBarEnabled.value = false;
  }

  void enableBottomNavBar() {
    isBottomNavBarEnabled.value = true;
  }

  var isLoadingNotifcations = true.obs;

  var notificationPage = 1.obs;
  var hasMoreNotifications = true.obs;
  var isLoadingMoreNotifications = false.obs;

  var displaySubCategories = <DisplaySubCategory>[].obs;

  var userName = ''.obs;
  var userPhotoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) => refreshData());
  }

  void refreshData() {
    final authStorage = AuthStorage();
    final userData = authStorage.getUser();
    if (userData != null) {
      userName.value = userData['username'] ?? '';
      userPhotoUrl.value = userData['image'] ?? '';
    } else {
      userName.value = '';
      userPhotoUrl.value = '';
    }

    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().loadUser();
    }
  }
}
