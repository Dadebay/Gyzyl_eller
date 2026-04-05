import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile.dart';
import 'package:gyzyleller/core/models/special_profile_model.dart';

class SpecialProfileController extends GetxController {
  final Rx<SpecialProfileModel> profile = SpecialProfileModel().obs;
  final RxList<File> images = <File>[].obs;
  final Rxn<File> selectedProfileImage = Rxn<File>(null);
  final RxBool isUploadingProfileImage = false.obs;

  final ImagePicker _picker = ImagePicker();
  final AuthStorage _authStorage = AuthStorage();
  final RxBool isEditingName = false.obs;
  final RxBool isChecked = false.obs;

  void _showSuccessSnackBar(String messageKey) {
    CustomWidgets.showSnackBar(
      'success_title',
      messageKey,
      ColorConstants.greenColor,
    );
  }

  void _showConnectionSnackBar() {
    CustomWidgets.showSnackBar(
      'error_title',
      'connection_error',
      ColorConstants.redColor,
    );
  }

  void _showErrorSnackBar(String messageKey) {
    CustomWidgets.showSnackBar(
      'error_title',
      messageKey,
      ColorConstants.redColor,
    );
  }

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

  void setProfileFromData(Map<String, dynamic> data) {
    final fromApi = SpecialProfileModel.fromJson(data);

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
      _showErrorSnackBar('special_profile_images_limit');
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
      // uploadProfileImageAndUsername çağrılmıyor, sadece kaydet ile birlikte gönderilecek
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

  Future<void> uploadProfileImageAndUsername() async {
    final String lang = GetStorage().read('langCode') ?? 'tk';
    final String endpoint = 'api/user/$lang/change-profile-image';

    try {
      if (selectedProfileImage.value == null) {
        print('⚠️ [uploadProfileImageAndUsername] No image selected');
        return;
      }

      isUploadingProfileImage.value = true;

      final String fullUrl = '${ApiConstants.baseUrl}$endpoint';
      final token = _authStorage.token;

      final request = http.MultipartRequest('POST', Uri.parse(fullUrl));
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          selectedProfileImage.value!.path,
        ),
      );

      final streamedResponse = await request.send();
      final int statusCode = streamedResponse.statusCode;
      final String responseBody = await streamedResponse.stream.bytesToString();

      dynamic response;
      try {
        response = responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
      } catch (_) {
        response = responseBody;
      }

      if (statusCode >= 200 && statusCode < 300) {
        final user = _authStorage.getUser();
        if (user != null) {
          if (response is Map<String, dynamic> &&
              response['data'] is Map<String, dynamic>) {
            final dynamic image = response['data']['image'];
            if (image != null) {
              user['image'] = image.toString();
            }
          }

          _authStorage.saveUser(user);
        }

        String? imageUrl = profile.value.imageUrl;
        if (selectedProfileImage.value != null) {
          imageUrl = selectedProfileImage.value!.path;
        }

        if (response is Map<String, dynamic> &&
            response['data'] is Map<String, dynamic>) {
          final dynamic image = response['data']['image'];
          if (image != null && image.toString().isNotEmpty) {
            final String imagePath = image.toString();
            imageUrl = imagePath.startsWith('http')
                ? imagePath
                : ApiConstants.imageURL + imagePath;
          }
        }

        profile.value = profile.value.copyWith(
          imageUrl: imageUrl,
        );

        selectedProfileImage.value = null;
      } else {
        print('❌ [uploadProfileImageAndUsername] Upload failed');
        _showConnectionSnackBar();
      }
    } catch (e) {
      print('❌ [uploadProfileImageAndUsername] error: $e');
      _showConnectionSnackBar();
    } finally {
      isUploadingProfileImage.value = false;
    }
  }

  Future<void> saveMasterProfile({
    required String name,
    required String shortBio,
    required String longBio,
    required String legalizationType,
    String? experience,
    List<Map<String, dynamic>> fileMetadata = const [],
    List<int> deleteFileIds = const [],
    bool isEdit = false,
    File? imageFile,
  }) async {
    try {
      if (name.isEmpty) {
        _showErrorSnackBar('special_profile_username_required');
        return;
      }

      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);

      final List<Map<String, dynamic>> files = [];
      final Set<int> deleteFilesSet = {...deleteFileIds};

      for (var meta in fileMetadata) {
        final String? filePath = _resolveServerFilePath(meta);

        final dynamic deleteFlag = meta['deleted'];
        if (deleteFlag == true && meta['id'] != null) {
          final int? parsedId = int.tryParse(meta['id'].toString());
          if (parsedId != null) deleteFilesSet.add(parsedId);
          continue;
        }

        if (filePath != null && filePath.isNotEmpty) {
          final String filename =
              (meta['filename'] ?? meta['name'] ?? _extractFileName(filePath))
                  .toString();
          files.add({
            'path': filePath,
            'filename': filename,
          });
        }
      }

      final List<int> deleteFiles = deleteFilesSet.toList();

      final Map<String, dynamic> body = {
        "welayat_id": profile.value.welayatId ?? 2,
        "etrap_id": profile.value.etrapId ?? 37,
        "short_description": shortBio,
        "description": longBio,
        "username": name,
        if (experience != null && experience.isNotEmpty)
          "experience": experience,
        "legalization_type": legalizationType,
        if (files.isNotEmpty) "files": files,
        if (isEdit || deleteFiles.isNotEmpty) "delete_files": deleteFiles,
        if (imageFile != null) "image": imageFile.path,
      };

      // Body içeriğini ekrana yazdır
      print('🟢 [saveMasterProfile] Gonderilen body:');
      print(body);

      final ApiService apiService = ApiService();
      final response = await apiService.handleApiRequest(
        ApiConstants.specialProfileCreate,
        body: body,
        method: 'POST',
        requiresToken: true,
        isForm: false,
      );

      Get.back();

      final bool isSuccess = _isSuccessfulSaveResponse(response);

      if (isSuccess) {
        // Save master profile ID if returned
        if (response is Map<String, dynamic> &&
            response['data'] != null &&
            response['data']['id'] != null) {
          _authStorage.saveMasterProfileId(response['data']['id'].toString());
        }
        await fetchProfileData();
        if (isEdit) {
          Get.back();
        } else {
          Get.off(() => const SpecialProfile());
        }
        _showSuccessSnackBar('success_subtitle');
      } else {
        _showConnectionSnackBar();
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _showConnectionSnackBar();
    }
  }

  Future<bool> deleteMasterProfile() async {
    try {
      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);

      const String endpoint = 'api/user/masters/delete';
      final Map<String, dynamic> body = {};

      final response = await ApiService().handleApiRequest(
        endpoint,
        body: body,
        method: 'POST',
        requiresToken: true,
        isForm: false,
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final bool isSuccess = _isSuccessfulSaveResponse(response);
      if (!isSuccess) {
        if (response is Map<String, dynamic> &&
            response['message'] != null &&
            response['message'].toString().trim().isNotEmpty) {
          _showConnectionSnackBar();
        } else {
          _showConnectionSnackBar();
        }

        return false;
      }

      _authStorage.clearMasterProfileId();
      images.clear();
      selectedProfileImage.value = null;
      loadInitialProfileData();

      _showSuccessSnackBar('success_subtitle');

      return true;
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      _showConnectionSnackBar();

      return false;
    }
  }

  String _extractFileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isNotEmpty ? parts.last : path;
  }

  String? _resolveServerFilePath(Map<String, dynamic> meta) {
    final String? url = meta['url']?.toString().trim();
    if (url != null && url.isNotEmpty) return url;

    final String? path = meta['path']?.toString().trim();
    if (path == null || path.isEmpty) return null;

    final normalized = path.replaceAll('\\', '/').toLowerCase();
    final bool looksLikeServerPath = normalized.startsWith('http') ||
        normalized.startsWith('local/uploads/') ||
        normalized.startsWith('uploads/');

    return looksLikeServerPath ? path : null;
  }

  bool _isSuccessfulSaveResponse(dynamic response) {
    if (response is bool) {
      return response;
    }

    if (response is String) {
      final normalized = response.trim().toLowerCase();
      return normalized == 'true' || normalized == 'success';
    }

    if (response is int) {
      return response >= 200 && response < 300;
    }

    if (response is Map<String, dynamic>) {
      final dynamic success = response['success'];
      final dynamic status = response['status'];
      final dynamic code = response['code'];

      final bool successTrue = success == true ||
          success?.toString().toLowerCase() == 'true' ||
          success?.toString().toLowerCase() == 'success';

      final int? statusCode = int.tryParse(status?.toString() ?? '');
      final int? codeValue = int.tryParse(code?.toString() ?? '');
      final bool has2xxStatus =
          (statusCode != null && statusCode >= 200 && statusCode < 300) ||
              (codeValue != null && codeValue >= 200 && codeValue < 300);

      // For legacy API shapes where explicit status/success keys are absent,
      // data payload still indicates a successful save.
      final bool hasDataPayload = response['data'] != null;

      return successTrue || has2xxStatus || hasDataPayload;
    }

    return false;
  }
}
