import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SpecialProfileController extends GetxController {
  final RxString name = ''.obs;
  final RxnString imageUrl = RxnString(null);
  final RxString shortBio = ''.obs;
  final RxString longBio = ''.obs;
  final RxString province = ''.obs;
  final RxList<File> images = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  void setProfileData({
    required String name,
    String? imageUrl,
    required String shortBio,
    required String longBio,
    required String province,
    required List<File> images,
  }) {
    this.name.value = name;
    this.imageUrl.value = imageUrl;
    this.shortBio.value = shortBio;
    this.longBio.value = longBio;
    this.province.value = province;
    this.images.assignAll(images);
  }

  Future<void> pickImage() async {
    if (images.length >= 8) {
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      images.add(File(image.path));
    }
  }
}
