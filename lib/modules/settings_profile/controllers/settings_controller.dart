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

  // Masters API'den gelen username ve image
  final RxString masterUsername = ''.obs;
  final RxString masterImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
    checkSpecialProfile();
    fetchBalance();
    fetchMasterProfileHeader();
  }

  Future<void> fetchMasterProfileHeader() async {
    try {
      if (!isLoggedIn) return;

      // 0. Reload user data from storage just in case it changed
      loadUser();

      // 1. Get Master ID from storage
      String? masterId = _authStorage.masterProfileId;

      // 2. If not in storage, fetch from /api/user/masters/profile
      if (masterId == null) {
        final profileResponse =
            await _apiService.getRequest(ApiConstants.specialProfile);
        if (profileResponse != null && profileResponse['data'] != null) {
          masterId = profileResponse['data']['id']?.toString();
          if (masterId != null) {
            _authStorage.saveMasterProfileId(masterId);
            hasSpecialProfile.value = true;
          }
        }
      }

      if (masterId == null) return;

      // 3. Fetch full master details from /api/get-master-by-id/{id}
      final response =
          await _apiService.getRequest(ApiConstants.getMasterById(masterId));
      if (response != null && response['data'] != null) {
        final data = response['data'];
        masterUsername.value = data['username']?.toString() ?? '';
        masterImage.value = data['image']?.toString() ?? '';

        // Optional: Prepend image URL if needed (already handled by the getter, but good to check)
        print('📡 [SettingsController] Master profile fetched: ${masterUsername.value}');
      }
    } catch (e) {
      print('❌ [SettingsController] fetchMasterProfileHeader error: $e');
    }
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
  }

  Future<void> checkSpecialProfile() async {
    if (!isLoggedIn) return;
    try {
      // Check saved master profile ID first
      final savedId = _authStorage.masterProfileId;
      if (savedId != null) {
        hasSpecialProfile.value = true;
        return;
      }
      final response =
          await _apiService.getRequest(ApiConstants.specialProfile);
      if (response != null && response['data'] != null) {
        hasSpecialProfile.value = true;
        final id = response['data']['id']?.toString();
        if (id != null) _authStorage.saveMasterProfileId(id);
      } else {
        hasSpecialProfile.value = false;
      }
    } catch (e) {
      hasSpecialProfile.value = false;
    }
  }

  Future<void> navigateToSpecialProfile() async {
    try {
      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);

      // Use saved master profile ID if available
      final savedId = _authStorage.masterProfileId;
      if (savedId != null) {
        print('📡 [SettingsController] Using saved masterId=$savedId');
        final detailResponse =
            await _apiService.getRequest(ApiConstants.getMasterById(savedId));
        Get.back();

        if (detailResponse != null && detailResponse['data'] != null) {
          hasSpecialProfile.value = true;
          final spCtrl = Get.isRegistered<SpecialProfileController>()
              ? Get.find<SpecialProfileController>()
              : Get.put(SpecialProfileController(), permanent: true);
          spCtrl.setProfileFromData(detailResponse['data']);
          Get.to(() => const SpecialProfile());
          return;
        }
        // Saved ID invalid — clear it and fall through
        _authStorage.clearMasterProfileId();
      } else {
        Get.back();
      }

      // Fallback: check via masters/profile endpoint
      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);
      final response =
          await _apiService.getRequest(ApiConstants.specialProfile);
      Get.back();

      if (response != null && response['data'] != null) {
        hasSpecialProfile.value = true;
        final masterId = response['data']['id']?.toString();
        if (masterId != null) {
          _authStorage.saveMasterProfileId(masterId);
        }

        Map<String, dynamic> fullData = response['data'];
        if (masterId != null) {
          final detailResponse = await _apiService
              .getRequest(ApiConstants.getMasterById(masterId));
          if (detailResponse != null && detailResponse['data'] != null) {
            fullData = detailResponse['data'];
          }
        }

        final spCtrl = Get.isRegistered<SpecialProfileController>()
            ? Get.find<SpecialProfileController>()
            : Get.put(SpecialProfileController(), permanent: true);
        spCtrl.setProfileFromData(fullData);
        Get.to(() => const SpecialProfile());
      } else {
        hasSpecialProfile.value = false;
        if (Get.isRegistered<SpecialProfileController>()) {
          Get.find<SpecialProfileController>().loadInitialProfileData();
        }
        Get.to(() => const SpecialProfileAdd());
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      print('❌ [SettingsController] navigateToSpecialProfile error: $e');
      Get.to(() => const SpecialProfileAdd());
    }
  }
}
