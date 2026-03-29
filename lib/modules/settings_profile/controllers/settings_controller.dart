import 'package:gyzyleller/modules/login/controllers/auth_service.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile_add.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';

class SettingsController extends GetxController {
  final AuthStorage _authStorage = AuthStorage();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final MyJobsService _jobsService = MyJobsService();

  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasSpecialProfile = false.obs;
  final RxDouble userBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
    checkSpecialProfile();
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      final balance = await _jobsService.fetchBalance();
      userBalance.value = balance;
    } catch (e) {
      print('Error fetching balance in settings: $e');
    }
  }

  void loadUser() {
    user.value = _authStorage.getUser();
  }

  String get username => user.value?['username'] ?? 'your_name'.tr;
  String get phone => user.value?['phone'] ?? '';
  String? get imageUrl {
    if (user.value != null && user.value!['image'] != null) {
      return ApiConstants.imageURL + user.value!['image'];
    }
    return null;
  }

  bool get isLoggedIn => user.value != null;

  Future<void> logout() async {
    await _authService.logout();
    loadUser();
    hasSpecialProfile.value = false;
  }

  Future<void> checkSpecialProfile() async {
    if (!isLoggedIn) return;
    try {
      final response =
          await _apiService.getRequest(ApiConstants.specialProfile);
      hasSpecialProfile.value = response != null && response['data'] != null;
    } catch (e) {
      hasSpecialProfile.value = false;
    }
  }

  Future<void> navigateToSpecialProfile() async {
    try {
      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);
      final response =
          await _apiService.getRequest(ApiConstants.specialProfile);
      Get.back();

      if (response != null && response['data'] != null) {
        hasSpecialProfile.value = true;
        if (Get.isRegistered<SpecialProfileController>()) {
          Get.find<SpecialProfileController>()
              .setProfileFromData(response['data']);
        }
        Get.to(() => SpecialProfile(), arguments: response['data']);
      } else {
        hasSpecialProfile.value = false;
        if (Get.isRegistered<SpecialProfileController>()) {
          Get.find<SpecialProfileController>().loadInitialProfileData();
        }
        Get.to(() => const SpecialProfileAdd());
      }
    } catch (e) {
      Get.back();

      Get.to(() => const SpecialProfileAdd());
    }
  }
}
