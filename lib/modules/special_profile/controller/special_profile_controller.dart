// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/core/models/special_profile_model.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/settings_controller.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/bottom_nav_bar_view.dart';
import 'package:gyzyleller/modules/bottomnavbar/bindings/home_binding.dart';
import 'package:hugeicons/hugeicons.dart';

class SpecialProfileController extends GetxController {
  final Rx<SpecialProfileModel> profile = SpecialProfileModel().obs;
  final RxList<File> images = <File>[].obs;
  final Rxn<File> selectedProfileImage = Rxn<File>(null);
  final RxBool isUploadingProfileImage = false.obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoadingReviews = false.obs;
  final RxBool isLoadingProfile = true.obs;

  final ImagePicker _picker = ImagePicker();
  final AuthStorage _authStorage = AuthStorage();
  final RxBool isChecked = true.obs;

  void _showLoadingDialog(String messageKey) {
    Get.dialog(
      barrierDismissible: false,
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: ColorConstants.kPrimaryColor2,
                        ),
                      ),
                      HugeIcon(
                        icon: messageKey.contains('edit')
                            ? HugeIcons.strokeRoundedUserEdit01
                            : HugeIcons.strokeRoundedUserAdd01,
                        color: ColorConstants.kPrimaryColor2,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  messageKey.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.fonts,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    print('🔍 [isMyProfile] currentUser=$currentUser');
    if (currentUser == null) {
      print('🔍 [isMyProfile] currentUser is NULL → false');
      return false;
    }
    final currentId = currentUser['id']?.toString();
    print('🔍 [isMyProfile] currentId=$currentId, profile.userId=${profile.value.userId}, profile.id=${profile.value.id}');
    if (currentId == null) {
      print('🔍 [isMyProfile] currentId is NULL → false');
      return false;
    }

    if (profile.value.userId != null) {
      final result = profile.value.userId == currentId;
      print('🔍 [isMyProfile] userId comparison: "${profile.value.userId}" == "$currentId" → $result');
      return result;
    }

    // Default to true if no profile ID (current user section)
    if (profile.value.id == null) {
      print('🔍 [isMyProfile] profile.id is null → true (default)');
      return true;
    }

    print('🔍 [isMyProfile] fallthrough → false');
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialProfileData();

    // Trigger full fetch if we're entering our own profile section
    if (Get.arguments == null) {
      refreshProfile();
    } else if (Get.arguments is Map<String, dynamic>) {
      profile.value = SpecialProfileModel.fromJson(Get.arguments);
      fetchReviews();
    }
  }

  void loadInitialProfileData() {
    final user = _authStorage.getUser();
    // Create a fresh model — clears any leftover specialist data (bio, experience, etc.)
    profile.value = SpecialProfileModel(
      id: user?['id']?.toString(),
      userId: user?['id']?.toString(),
      name: user?['username'],
      imageUrl: user?['image'] != null
          ? ApiConstants.imageURL + user!['image']
          : null,
    );
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

  /// Re-fetches the master profile using get-master-by-id for full data.
  Future<void> fetchProfileData() async {
    // Only show shimmer on initial load (when we have no real profile data yet)
    final bool isFirstLoad = profile.value.id == null &&
        (profile.value.shortBio == null || profile.value.shortBio!.isEmpty);
    if (isFirstLoad && !isLoadingProfile.value) {
      isLoadingProfile.value = true;
    }

    try {
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
    } catch (e) {
      print('❌ [SpecialProfileController] fetchProfileData error: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> fetchReviews() async {
    final userId = profile.value.userId;
    print('🔍 [fetchReviews] called with userId=$userId');
    if (userId == null || userId.isEmpty) {
      print('🔍 [fetchReviews] userId is null/empty, returning');
      return;
    }

    isLoadingReviews.value = true;
    try {
      final ApiService apiService = ApiService();
      final rawList = await apiService.getMasterReviews(userId);
      print('🔍 [fetchReviews] rawList.length=${rawList.length}');

      // Parse reviews first
      final parsedReviews = rawList
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Fetch replies for each review using separate endpoint
      for (var i = 0; i < parsedReviews.length; i++) {
        try {
          final replyList = await apiService.getReviewReplies(parsedReviews[i].id);
          print('🔍 [fetchReviews] review[${parsedReviews[i].id}] has ${replyList.length} replies from API');
          if (replyList.isNotEmpty) {
            final replies = replyList
                .map((r) => ReviewReply.fromJson(r as Map<String, dynamic>))
                .toList();
            // Create new ReviewModel with replies
            parsedReviews[i] = ReviewModel(
              id: parsedReviews[i].id,
              userId: parsedReviews[i].userId,
              jobId: parsedReviews[i].jobId,
              review: parsedReviews[i].review,
              rating: parsedReviews[i].rating,
              requestId: parsedReviews[i].requestId,
              createdAt: parsedReviews[i].createdAt,
              username: parsedReviews[i].username,
              image: parsedReviews[i].image,
              replies: replies,
            );
          }
        } catch (e) {
          print('⚠️ [fetchReviews] failed to fetch replies for review ${parsedReviews[i].id}: $e');
        }
      }

      reviews.value = parsedReviews;
      print('🔍 [fetchReviews] final reviews.length=${reviews.length}');
      for (var r in reviews) {
        print('🔍 [fetchReviews] review.id=${r.id}, replies.length=${r.replies.length}');
      }
    } catch (e) {
      print('❌ [SpecialProfileController] fetchReviews error: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<bool> replyToReview(String reviewId, String replyText) async {
    final String endpoint = 'api/user/master/reply-to-review/$reviewId';
    print('🔍 [replyToReview] ========================================');
    print('🔍 [replyToReview] STEP 1: reviewId=$reviewId, replyText=$replyText');
    print('🔍 [replyToReview] STEP 2: endpoint=$endpoint');
    try {
      Get.dialog(CustomWidgets.loader(), barrierDismissible: false);
      print('🔍 [replyToReview] STEP 3: loader dialog shown');

      final Map<String, dynamic> body = {
        "reply": replyText,
      };

      print('🔍 [replyToReview] STEP 4: calling handleApiRequest...');
      final ApiService apiService = ApiService();
      dynamic response;
      try {
        response = await apiService.handleApiRequest(
          endpoint,
          body: body,
          method: 'POST',
          requiresToken: true,
          isForm: false,
        );
      } catch (apiError) {
        print('❌ [replyToReview] STEP 4 FAILED: handleApiRequest threw: $apiError');
        if (Get.isDialogOpen == true) Get.back();
        _showConnectionSnackBar();
        return false;
      }

      print('🔍 [replyToReview] STEP 5: response type=${response.runtimeType}');
      print('🔍 [replyToReview] STEP 5: response=$response');

      if (Get.isDialogOpen == true) Get.back();
      print('🔍 [replyToReview] STEP 6: loader closed');

      final isSuccess = _isSuccessfulSaveResponse(response);
      print('🔍 [replyToReview] STEP 7: isSuccess=$isSuccess');

      if (isSuccess) {
        _showSuccessSnackBar('success_subtitle');
        print('🔍 [replyToReview] STEP 8: calling fetchReviews...');
        fetchReviews();
        print('🔍 [replyToReview] STEP 9: returning true ✅');
        print('🔍 [replyToReview] ========================================');
        return true;
      } else {
        print('🔍 [replyToReview] STEP 8: NOT successful, returning false');
        print('🔍 [replyToReview] ========================================');
        _showConnectionSnackBar();
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      print('❌ [replyToReview] OUTER CATCH Error: $e');
      print('❌ [replyToReview] ========================================');
      _showConnectionSnackBar();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    // Run both profile and review fetches concurrently for performance
    await Future.wait([
      fetchProfileData(),
      fetchReviews(),
    ]);

    // Refresh Settings Header if available
    if (Get.isRegistered<SettingsController>()) {
      await Get.find<SettingsController>().fetchMasterProfileHeader();
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

      _showLoadingDialog(
          isEdit ? 'edit_profile_loading' : 'create_profile_loading');

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
            if (meta['id'] != null) 'id': meta['id'],
            'path': _cleanFilePath(filePath),
            'filename': filename,
          });
        }
      }

      final List<int> deleteFiles = deleteFilesSet.toList();

      String? imageUrl;
      if (imageFile != null) {
        try {
          imageUrl = await ApiService().uploadFile(imageFile.path);
        } catch (e) {
          print(
              '❌ [saveMasterProfile] Profil fotoğrafı preload/upload hatası: $e');
        }
      }
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
        if (imageUrl != null) "image": imageUrl,
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

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final bool isSuccess = _isSuccessfulSaveResponse(response);

      if (isSuccess) {
        // 1. Optimistic Update: Update local profile state immediately
        // Use the server-uploaded image URL (not the local file path)
        String? optimisticImageUrl = profile.value.imageUrl;
        if (imageUrl != null) {
          optimisticImageUrl = imageUrl.startsWith('http')
              ? imageUrl
              : ApiConstants.imageURL + imageUrl;
        }

        profile.value = profile.value.copyWith(
          name: name,
          shortBio: shortBio,
          longBio: longBio,
          experience: experience,
          legalizationType: legalizationType,
          imageUrl: optimisticImageUrl,
        );

        // 2. Save master profile ID if returned
        if (response is Map<String, dynamic> &&
            response['data'] != null &&
            response['data']['id'] != null) {
          _authStorage.saveMasterProfileId(response['data']['id'].toString());
        }

        // 4. Update SettingsController and AllController state before navigation
        if (Get.isRegistered<SettingsController>()) {
          final sc = Get.find<SettingsController>();
          sc.hasSpecialProfile.value = true;
          sc.fetchBalance();
        }

        final allController = Get.isRegistered<AllController>()
            ? Get.find<AllController>()
            : Get.put(AllController(), permanent: true);
        allController.shouldShowFilterShowcase.value = true;

        // 5. Instant Navigation: Close the loading dialog and move to the target page
        if (Get.isDialogOpen == true) Get.back();

        if (isEdit) {
          Get.back();
        } else {
          // Navigate to Home (AllView) index 0
          final HomeController homeController = Get.isRegistered<HomeController>()
              ? Get.find<HomeController>()
              : Get.put(HomeController());
          homeController.changePage(0);
          Get.offAll(() => const BottomNavBar(), binding: HomeBinding());
        }

        // _showSuccessSnackBar('success_subtitle'); // REMOVED

        // 6. Background Refresh: Sync everything with the server
        refreshProfile();
      } else {
        if (Get.isDialogOpen == true) Get.back();
        _showConnectionSnackBar();
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      print('❌ [saveMasterProfile] Error: $e');
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

  String _cleanFilePath(String path) {
    // If it's a full URL, we need to extract the relative path
    final String baseUrl = ApiConstants.imageURL;
    if (path.startsWith(baseUrl)) {
      return path.substring(baseUrl.length);
    }
    return path;
  }

  String? _resolveServerFilePath(Map<String, dynamic> meta) {
    // If it's a new upload, 'url' contains the relative path returned by server
    // If it's an initial file, 'url' contains the full URL (prepended in the view)
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
