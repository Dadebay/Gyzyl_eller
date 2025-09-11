import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/init/translation_service.dart';

class UserProfilController extends GetxController {
  var isLoading = true.obs;
  var isProductsLoading = true.obs;

  var isDeleting = false.obs;
  var isUpdatingProfile = false.obs;
  var selectedImageFile = Rx<File?>(null);
  var uploadProgress = 0.0.obs;

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
