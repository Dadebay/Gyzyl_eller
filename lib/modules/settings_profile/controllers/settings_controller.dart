// ignore_for_file: avoid_print

import 'package:gyzyleller/modules/login/controllers/auth_service.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile_add.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/core/controllers/balance_controller.dart';

class SettingsController extends GetxController {
  final AuthStorage _authStorage = AuthStorage();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasSpecialProfile = false.obs;
  final BalanceController _balanceController = Get.find<BalanceController>();
  RxDouble get userBalance => _balanceController.balance;

  // Masters API'den gelen username ve image
  final RxString masterUsername = ''.obs;
  final RxString masterImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    loadUser();
    if (isLoggedIn) {
      await fetchMasterProfileHeader();
      await fetchBalance();
    }
  }

  Future<void> fetchMasterProfileHeader() async {
    try {
      if (!isLoggedIn) {
        hasSpecialProfile.value = false;
        return;
      }

      // 0. Reload user data from storage just in case it changed
      loadUser();

      // 1. Check saved master profile ID first
      String? masterId = _authStorage.masterProfileId;

      // 2. If not in storage, fetch from /api/user/masters/profile
      if (masterId == null) {
        final profileResponse =
            await _apiService.getRequest(ApiConstants.specialProfile);
        if (profileResponse != null && profileResponse['data'] != null) {
          masterId = profileResponse['data']['id']?.toString();
          if (masterId != null) {
            _authStorage.saveMasterProfileId(masterId);
          }
        }
      }

      if (masterId != null) {
        hasSpecialProfile.value = true;
        // 3. Fetch full master details from /api/get-master-by-id/{id}
        final response =
            await _apiService.getRequest(ApiConstants.getMasterById(masterId));
        if (response != null && response['data'] != null) {
          final data = response['data'];
          masterUsername.value = data['username']?.toString() ?? '';
          masterImage.value = data['image']?.toString() ?? '';

          print(
              '📡 [SettingsController] Master profile fetched: ${masterUsername.value}');
        }
      } else {
        hasSpecialProfile.value = false;
      }
    } catch (e) {
      print('❌ [SettingsController] fetchMasterProfileHeader error: $e');
      hasSpecialProfile.value = false;
    }
  }

  Future<void> fetchBalance() async {
    await _balanceController.fetchBalance();
  }

  void loadUser() {
    user.value = _authStorage.getUser();
  }

  String get username => masterUsername.value.isNotEmpty
      ? masterUsername.value
      : (user.value?['username'] ?? 'your_name'.tr);
  String get phone => user.value?['phone'] ?? '';
  String? get imageUrl {
    if (masterImage.value.isNotEmpty) {
      return ApiConstants.imageURL + masterImage.value;
    }
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
    masterImage.value = '';
    masterUsername.value = '';
  }

  void clearMasterProfile() {
    hasSpecialProfile.value = false;
    masterImage.value = '';
    masterUsername.value = '';
    loadUser();
  }

  void navigateToSpecialProfile() {
    if (hasSpecialProfile.value) {
      Get.to(() => const SpecialProfile());
    } else {
      Get.to(() => const SpecialProfileAdd());
    }
  }
}
