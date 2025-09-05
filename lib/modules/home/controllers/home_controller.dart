// lib/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';

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
}
