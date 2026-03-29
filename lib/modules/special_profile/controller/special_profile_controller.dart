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
        name: user['username'],
        imageUrl: user['image'] != null ? ApiConstants.imageURL + user['image'] : null,
      );
    }
  }

  void setProfileFromData(Map<String, dynamic> data) {
    profile.value = SpecialProfileModel.fromJson(data);
  }

  void toggleEditName(String? newName) {
    if (isEditingName.value && newName != null) {
      profile.value = profile.value.copyWith(name: newName);
    }
    isEditingName.value = !isEditingName.value;
  }

  void fetchProfileData() async {
    final ApiService apiService = ApiService();
    final response = await apiService.getRequest(ApiConstants.specialProfile);
    if (response != null && response['data'] != null) {
      profile.value = SpecialProfileModel.fromJson(response['data']);
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
              title: Text('select_by_camera'.tr, style: const TextStyle(fontSize: 18)),
              onTap: () { Get.back(); pickProfileImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.image, size: 30),
              ),
              title: Text('select_by_gallery'.tr, style: const TextStyle(fontSize: 18)),
              onTap: () { Get.back(); pickProfileImage(ImageSource.gallery); },
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
    bool isEdit = false,
  }) async {
    try {
      if (name.isEmpty) {
        Get.snackbar("Error", "Username is required");
        return;
      }

      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);

      final Map<String, dynamic> body = {
        "welayat_id": profile.value.welayatId ?? 2,
        "etrap_id": profile.value.etrapId ?? 37,
        "short_description": shortBio,
        "description": longBio,
        "username": name,
        "legalization_type": legalizationType,
      };

      final ApiService apiService = ApiService();
      dynamic response;
      
      if (images.isNotEmpty) {
        response = await apiService.postMultipartRequest(
          ApiConstants.specialProfileCreate,
          body,
          xFiles: images.map((e) => XFile(e.path)).toList(),
          fileField: 'files[]',
        );
      } else {
        response = await apiService.handleApiRequest(
          ApiConstants.specialProfileCreate,
          body: body,
          method: 'POST',
          requiresToken: true,
          isForm: false,
        );
      }

      Get.back();

      if (response != null) {
        CustomWidgets.showSnackBar('success_title'.tr, 'success_subtitle'.tr, ColorConstants.greenColor);
        fetchProfileData();
        if (isEdit) {
          Get.back();
        } else {
          Get.off(() => SpecialProfile());
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Failed to create profile: $e");
    }
  }
}
