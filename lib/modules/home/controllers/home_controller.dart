import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/modules/user_profile/controllers/settings_controller.dart'; // Import SettingsController

class DisplaySubCategory {
  DisplaySubCategory();
}

class HomeController extends GetxController {
  var bottomNavBarSelectedIndex = 0.obs;
  void changePage(int index) {
    bottomNavBarSelectedIndex.value = index;
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
    refreshData();
  }

  void refreshData() {
    print("HomeView data refreshed!");
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
