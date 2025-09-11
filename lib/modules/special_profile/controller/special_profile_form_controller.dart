import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SpecialProfileFormController extends GetxController {
  final TextEditingController shortBioController = TextEditingController();
  final TextEditingController longBioController = TextEditingController();
  final RxnString selectedProvince = RxnString(null);
  final RxnString selectedLegalizationType = RxnString(null);
  final ImagePicker _picker = ImagePicker();
  final RxList<File> selectedImages = <File>[].obs;
  final RxBool termsAccepted = false.obs;

  @override
  void onClose() {
    shortBioController.dispose();
    longBioController.dispose();
    super.onClose();
  }

  final RxBool _isInitialDataLoaded = false.obs;

  void setInitialData({
    String? initialShortBio,
    String? initialLongBio,
    String? initialProvince,
    List<File>? initialImages,
  }) {
    if (_isInitialDataLoaded.isFalse) {
      if (initialShortBio != null) shortBioController.text = initialShortBio;
      if (initialLongBio != null) longBioController.text = initialLongBio;
      selectedProvince.value = initialProvince;
      if (initialImages != null) selectedImages.assignAll(initialImages);
      _isInitialDataLoaded.value = true;
    }
  }

  Future<void> pickImage() async {
    if (selectedImages.length >= 8) {
      // Optionally, show a message to the user
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImages.add(File(image.path));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void toggleTermsAccepted(bool? newValue) {
    termsAccepted.value = newValue ?? false;
  }

  bool validateForm() {
    if (shortBioController.text.isEmpty ||
        longBioController.text.isEmpty ||
        selectedProvince.value == null ||
        selectedImages.isEmpty) {
      Get.snackbar(
        'validation_error_title'.tr,
        'validation_error_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (!termsAccepted.value) {
      Get.snackbar(
        'terms_error_title'.tr,
        'terms_error_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }
}
