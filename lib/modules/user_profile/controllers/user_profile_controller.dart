import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/modules/user_profile/model/user_model.dart';
import 'package:gyzyleller/modules/user_profile/services/user_profile_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/init/translation_service.dart';

class UserProfilController extends GetxController {
  final UserProfileService _userService = UserProfileService();
  var user = Rx<UserModel?>(null);
  var isLoading = true.obs;
  var isProductsLoading = true.obs;

  var isDeleting = false.obs;
  var isUpdatingProfile = false.obs;
  var selectedImageFile = Rx<File?>(null);
  var uploadProgress = 0.0.obs;
  Future<void> updateUserProfile(String name) async {
    if (user.value == null) return;
    isUpdatingProfile.value = true;
    uploadProgress.value = 0.0;

    try {
      final updatedUser = await _userService.updateUserProfile(
        imageFile: selectedImageFile.value,
        onSendProgress: (sent, total) {
          if (total != -1) {
            uploadProgress.value = sent / total;
          }
        },
      );

      if (updatedUser != null) {
        user.value = updatedUser;
        selectedImageFile.value = null;
        Get.back();
        // ...
      }
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // YENİ METOT: Resim seçildiğinde çağrılacak
  void onImageSelected(XFile? pickedFile) {
    if (pickedFile != null) {
      selectedImageFile.value = File(pickedFile.path);
    }
  }

  void switchLang(String languageCode) {
    Locale newLocale;
    switch (languageCode) {
      case 'tr':
        newLocale = const Locale('tr');
        break;
      case 'en':
        newLocale = const Locale('en');
        break;
      case 'ru':
        newLocale = const Locale('ru');
        break;
      default:
        newLocale = TranslationService.fallbackLocale;
    }
    Get.updateLocale(newLocale);
    final storage = GetStorage();
    storage.write('langCode', languageCode);
  }
}
