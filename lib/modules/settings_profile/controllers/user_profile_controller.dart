import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gyzyleller/shared/utils/image_compress_util.dart';

class UserProfilController extends GetxController {
  var isLoading = true.obs;
  var isProductsLoading = true.obs;

  var isDeleting = false.obs;
  var isUpdatingProfile = false.obs;
  var selectedImageFile = Rx<File?>(null);
  var uploadProgress = 0.0.obs;

  Future<void> onImageSelected(XFile? pickedFile) async {
    if (pickedFile != null) {
      final compressed = await compressToWebP(File(pickedFile.path));
      selectedImageFile.value = compressed;
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
        newLocale = const Locale('tk');
    }
    Get.updateLocale(newLocale);
    final storage = GetStorage();
    storage.write('langCode', languageCode);
  }
}
