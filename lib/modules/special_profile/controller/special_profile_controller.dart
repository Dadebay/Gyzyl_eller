import 'dart:io';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile.dart';
import 'package:gyzyleller/core/models/special_profile_model.dart';

class SpecialProfileController extends GetxController {
  final Rx<SpecialProfileModel> profile = SpecialProfileModel().obs;
  final RxList<File> images = <File>[].obs;
  final Rxn<File> selectedProfileImage = Rxn<File>(null);

  final ImagePicker _picker = ImagePicker();
  final AuthStorage _authStorage = AuthStorage();
  final RxBool isEditingName = false.obs;
  final RxBool isChecked = false.obs;

  bool get isMyProfile {
    final currentUser = _authStorage.getUser();
    if (currentUser == null) return false;
    final currentId = currentUser['id']?.toString();
    if (currentId == null) return false;

    // Default to true if no profile ID (current user section)
    if (profile.value.id == null) return true;

    return profile.value.id == currentId;
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialProfileData();
    if (Get.arguments != null) {
      if (Get.arguments is Map<String, dynamic>) {
        profile.value = SpecialProfileModel.fromJson(Get.arguments);
      }
    }
  }

  void loadInitialProfileData() {
    final user = _authStorage.getUser();
    if (user != null) {
      profile.value = profile.value.copyWith(
        id: user['id']?.toString(),
        userId: user['id']?.toString(), // needed for review fetching
        name: user['username'],
        imageUrl: user['image'] != null
            ? ApiConstants.imageURL + user['image']
            : null,
      );
    }
  }

  /// Merges master-profile API data with the user info from local storage.
  ///
  /// When called with data from `get-master-by-id/{id}`, the response already
  /// includes username, image, rating, welayat/etrap names, etc.
  /// Falls back to local user storage for any missing fields.
  void setProfileFromData(Map<String, dynamic> data) {
    // 1. Parse all available API fields.
    final fromApi = SpecialProfileModel.fromJson(data);

    // 2. Fill in any missing fields from local user storage.
    final user = _authStorage.getUser();
    final name = (fromApi.name != null && fromApi.name!.isNotEmpty)
        ? fromApi.name
        : user?['username'] as String?;
    final imageUrl = (fromApi.imageUrl != null && fromApi.imageUrl!.isNotEmpty)
        ? (fromApi.imageUrl!.startsWith('http')
            ? fromApi.imageUrl
            : ApiConstants.imageURL + fromApi.imageUrl!)
        : (user?['image'] != null
            ? ApiConstants.imageURL + (user!['image'] as String)
            : null);
    final userId = fromApi.userId ?? user?['id']?.toString();

    print('🔑 [SpecialProfileController] setProfileFromData →\n'
        '   masterId=${fromApi.id}, userId=$userId\n'
        '   welayatId=${fromApi.welayatId}, etrapId=${fromApi.etrapId}\n'
        '   rating=${fromApi.rating}, reviewCount=${fromApi.reviewCount}\n'
        '   createdAt=${fromApi.createdAt}, files=${fromApi.serverImages.length}');

    profile.value = fromApi.copyWith(
      userId: userId,
      name: name,
      imageUrl: imageUrl,
    );
  }

  void toggleEditName(String? newName) {
    if (isEditingName.value && newName != null) {
      profile.value = profile.value.copyWith(name: newName);
    }
    isEditingName.value = !isEditingName.value;
  }

  /// Re-fetches the master profile using get-master-by-id for full data.
  Future<void> fetchProfileData() async {
    final ApiService apiService = ApiService();
    final response = await apiService.getRequest(ApiConstants.specialProfile);
    if (response != null && response['data'] != null) {
      final masterId = response['data']['id']?.toString();
      if (masterId != null) {
        final detailResponse =
            await apiService.getRequest(ApiConstants.getMasterById(masterId));
        if (detailResponse != null && detailResponse['data'] != null) {
          setProfileFromData(detailResponse['data'] as Map<String, dynamic>);
          return;
        }
      }
      setProfileFromData(response['data'] as Map<String, dynamic>);
    }
  }

  Future<void> pickWorkImage() async {
    if (images.length >= 8) {
      Get.snackbar("Limit Reached", "You can only add up to 8 images.");
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      images.add(File(image.path));
    }
  }

  void removeWorkImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedProfileImage.value = File(image.path);
      Get.snackbar("Success", "Profile image selected: ${image.name}");
    }
  }

  void showEditOptions() {
    Get.bottomSheet(
      Container(
        color: ColorConstants.background,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera, size: 35),
              title: Text('select_by_camera'.tr,
                  style: const TextStyle(fontSize: 18)),
              onTap: () {
                Get.back();
                pickProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.image, size: 30),
              ),
              title: Text('select_by_gallery'.tr,
                  style: const TextStyle(fontSize: 18)),
              onTap: () {
                Get.back();
                pickProfileImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveMasterProfile({
    required String name,
    required String shortBio,
    required String longBio,
    required String legalizationType,
    List<Map<String, dynamic>> fileMetadata = const [],
    bool isEdit = false,
  }) async {
    try {
      if (name.isEmpty) {
        Get.snackbar("Error", "Username is required");
        return;
      }

      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);

      final List<String> filesList = [];
      for (var meta in fileMetadata) {
        final String? url = meta['url'] as String?;
        if (url != null) filesList.add(url);
      }

      final Map<String, dynamic> body = {
        "welayat_id": profile.value.welayatId ?? 2,
        "etrap_id": profile.value.etrapId ?? 37,
        "short_description": shortBio,
        "description": longBio,
        "username": name,
        "legalization_type": legalizationType,
        if (filesList.isNotEmpty) "files": filesList,
      };

      print('------------------------------------------');
      print('📤 [saveMasterProfile] REQUEST BODY:');
      body.forEach((k, v) => print('  $k: $v'));
      print('------------------------------------------');

      final ApiService apiService = ApiService();
      final response = await apiService.handleApiRequest(
        ApiConstants.specialProfileCreate,
        body: body,
        method: 'POST',
        requiresToken: true,
        isForm: false,
      );

      print('------------------------------------------');
      print('📡 [saveMasterProfile] RESPONSE: $response');
      print('------------------------------------------');

      Get.back();

      final bool isSuccess =
          (response is int && response >= 200 && response < 300) ||
              response is Map<String, dynamic>;

      if (isSuccess) {
        // Save master profile ID if returned
        if (response is Map<String, dynamic> &&
            response['data'] != null &&
            response['data']['id'] != null) {
          _authStorage.saveMasterProfileId(response['data']['id'].toString());
        }
        CustomWidgets.showSnackBar('success_title'.tr, 'success_subtitle'.tr,
            ColorConstants.greenColor);
        await fetchProfileData();
        if (isEdit) {
          Get.back();
        } else {
          Get.off(() => const SpecialProfile());
        }
      } else {
        Get.snackbar("Error", "Failed to save profile");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Failed to create profile: $e");
    }
  }
}
