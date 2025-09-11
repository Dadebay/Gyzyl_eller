import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gyzyleller/shared/constants/image_constants.dart';

class JobDetailController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  // Example job data (ideally from a model or API)
  final RxString jobDate = '27 awgust 2023, 16:31'.obs;
  final RxString jobShortTitle = 'Aşhanadaky smesitel akýar'.obs;
  final RxString jobAdditionalInfoTitle = 'Goşmaça maglumatlar:'.obs;
  final RxString jobAdditionalInfoContent = 'Lorem Ipsum is simply dummy text the printing and typesetting industry.'.obs;
  final RxString jobNeededTitle = 'Näme iş gerek?'.obs;
  final RxString jobNeededContent = 'Smesitel akýar'.obs;
  final RxList<String> jobFiles = <String>['Dünmaly dokument.docx', 'Dokument.xlsx'].obs;
  final RxList<String> jobImages = <String>[
    ImageConstants.image,
    ImageConstants.image,
    ImageConstants.image,
    ImageConstants.image,
  ].obs;

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(_updateCurrentPage);
  }

  void _updateCurrentPage() {
    if (pageController.page != null) {
      currentPage.value = pageController.page!.round();
    }
  }

  int get pageCount => (jobImages.length / 2).ceil();

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
