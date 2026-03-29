// ignore_for_file: empty_catches

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/models/saved_request_model.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class JobDetailController extends GetxController {
  Future<void> markJobDoneByMasterWithRequestId() async {
    if (job.value == null || isCompletingJob.value) return;

    isCompletingJob.value = true;

    try {
      final int? requestId = job.value!.requestId;
      final int idToSend = requestId ?? job.value!.id;

      final ok = await _jobsService.markJobDoneByMaster(idToSend);

      if (ok) {
        isCompleteRequestSent.value = true;
        CustomWidgets.showSnackBar(
          'Dogry',
          'Ýumuş üstünlikli tamamlandy',
          ColorConstants.greenColor,
        );
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        CustomWidgets.showSnackBar(
          'Ýalňyşlyk',
          'Ýumuş tamamlanmady',
          ColorConstants.redColor,
        );
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
        'Ýalňyşlyk',
        'Ýumuş tamamlanmady',
        ColorConstants.redColor,
      );
    } finally {
      isCompletingJob.value = false;
    }
  }

  final MyJobsService _jobsService = MyJobsService();

  final Rxn<JobModel> job = Rxn<JobModel>();
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxBool isDescExpanded = false.obs;
  final RxBool canDelete = false.obs;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final RxString currentCommentText = ''.obs;
  final RxBool isSubmittingRequest = false.obs;

  final RxBool isOfferSent = false.obs;
  final RxString sentPrice = ''.obs;
  final RxString sentComment = ''.obs;

  final RxBool isCompletingJob = false.obs;
  final RxBool isCompleteRequestSent = false.obs;

  final RxDouble userBalance = 0.0.obs;
  final RxBool isLoggedIn = false.obs;

  // Template specific state
  final RxBool showingTemplates = false.obs;
  final RxBool showSuccessBanner = false.obs;
  final RxList<SavedRequestModel> templates = <SavedRequestModel>[].obs;
  final RxBool isLoadingTemplates = false.obs;
  final RxBool isSavingTemplate = false.obs;

  @override
  void onInit() {
    super.onInit();

    isLoggedIn.value = AuthStorage().isLoggedIn;
    fetchBalance();
    fetchTemplates();

    final dynamic args = Get.arguments;
    int? jobId;

    if (args is int) {
      jobId = args;
    } else if (args is Map<String, dynamic>) {
      jobId = args['id'];
      canDelete.value = args['canDelete'] ?? false;
    }

    if (jobId != null) {
      fetchJobDetail(jobId);
    } else {
      isLoading.value = false;
      error.value = 'Job ID is missing';
    }

    pageController.addListener(_updateCurrentPage);
    commentController.addListener(() {
      currentCommentText.value = commentController.text;
    });
  }

  void _updateCurrentPage() {
    if (pageController.page != null) {
      currentPage.value = pageController.page!.round();
    }
  }

  void closeOfferSuccess() {
    isOfferSent.value = false;
    sentPrice.value = '';
    sentComment.value = '';
  }

  Future<void> fetchJobDetail(int jobId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _jobsService.getJobDetail(jobId);
      job.value = response.job;
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> markJobDoneByMaster() async {
    if (job.value == null || isCompletingJob.value) return;

    isCompletingJob.value = true;

    try {
      final ok = await _jobsService.markJobDoneByMaster(job.value!.id);

      if (ok) {
        isCompleteRequestSent.value = true;
        CustomWidgets.showSnackBar(
          'Dogry',
          'Ýumuş üstünlikli tamamlandy',
          ColorConstants.kPrimaryColor2,
        );
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        CustomWidgets.showSnackBar(
          'Ýalňyşlyk',
          'Ýumuş tamamlanmady',
          ColorConstants.redColor,
        );
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
        'Ýalňyşlyk',
        'Ýumuş tamamlanmady: $e',
        ColorConstants.redColor,
      );
    } finally {
      isCompletingJob.value = false;
    }
  }

  Future<void> fetchBalance() async {
    try {
      final balance = await _jobsService.fetchBalance();
      userBalance.value = balance;
      isLoggedIn.value = AuthStorage().isLoggedIn;
    } catch (e) {}
  }

  Future<void> fetchTemplates() async {
    isLoadingTemplates.value = true;
    try {
      final fetched = await _jobsService.getSavedRequests();
      templates.assignAll(fetched);
    } catch (e) {
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  LatLng parsePosition(String? pos) {
    if (pos == null || pos.isEmpty) return const LatLng(37.96, 58.33);

    final cleanPos = pos.replaceAll('(', '').replaceAll(')', '');
    final coords = cleanPos.split(',');
    if (coords.length == 2) {
      try {
        double val1 = double.parse(coords[0].trim());
        double val2 = double.parse(coords[1].trim());

        if (val1 > 50 && val2 < 40) {
          return LatLng(val2, val1);
        } else if (val2 > 50 && val1 < 40) {
          return LatLng(val1, val2);
        } else {
          return LatLng(val1, val2);
        }
      } catch (_) {}
    }
    return const LatLng(37.96, 58.33);
  }

  Future<void> submitJobRequest(BuildContext context) async {
    if (job.value == null) return;

    double? price = double.tryParse(priceController.text.trim());
    String comment = commentController.text.trim();

    if (price == null || price <= 0) {
      CustomWidgets.showSnackBar(
          'error_title'.tr, 'enter_valid_price'.tr, ColorConstants.redColor);
      return;
    }

    if (comment.isEmpty) {
      CustomWidgets.showSnackBar(
          'error_title'.tr, 'enter_description'.tr, ColorConstants.redColor);
      return;
    }

    isSubmittingRequest.value = true;
    Get.dialog(CustomWidgets.loader(), barrierDismissible: false);

    try {
      await _jobsService.sendJobRequest(
        job.value!.id,
        price: price,
        comment: comment,
      );

      Get.back();
      Get.back();
      fetchBalance();

      isOfferSent.value = true;
      sentPrice.value = priceController.text;
      sentComment.value = commentController.text;

      priceController.clear();
      commentController.clear();

      fetchJobDetail(job.value!.id);

      // Create a chat for this job
      // await _createChatForJob(job.value!.id, comment);
    } catch (e) {
      Get.back();
      CustomWidgets.showSnackBar(
          'error_title'.tr, '${'offer_not_sent'.tr}: $e', ColorConstants.redColor);
    } finally {
      isSubmittingRequest.value = false;
    }
  }

  Future<void> saveTemplate() async {
    String comment = currentCommentText.value.trim();
    if (comment.isEmpty || isSavingTemplate.value) return;

    isSavingTemplate.value = true;
    try {
      await _jobsService.createSavedRequest(comment);
      fetchTemplates(); // Refetch to get the correct ID from backend
      showSuccessBanner.value = true;
    } catch (e) {
      CustomWidgets.showSnackBar(
          'error_title'.tr, 'template_not_saved'.tr, ColorConstants.redColor);
    } finally {
      isSavingTemplate.value = false;
    }
  }

  void selectTemplate(SavedRequestModel template) {
    commentController.text = template.comment;
    showingTemplates.value = false;
  }

  Future<void> deleteTemplate(int index) async {
    if (index >= 0 && index < templates.length) {
      final template = templates[index];
      try {
        await _jobsService.deleteSavedRequest(template.id);
        templates.removeAt(index);
      } catch (e) {
        CustomWidgets.showSnackBar(
            'error_title'.tr, 'template_not_deleted'.tr, ColorConstants.redColor);
      }
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    priceController.dispose();
    commentController.dispose();
    super.onClose();
  }

  Future<void> downloadFile(String url) async {
    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
        await Permission.photos.request();
      } else if (Platform.isIOS) {
        if (!(await Permission.photos.request().isGranted)) return;
      }

      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final result = await SaverGallery.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "gyzyleller_${DateTime.now().millisecondsSinceEpoch}.jpg",
        androidRelativePath: "Pictures/Gyzyleller",
        androidExistNotSave: false,
      );

      if (result.isSuccess) {
        CustomWidgets.showSnackBar(
            'OK', 'Faýl ýüklenildi', ColorConstants.greenColor);
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
          'Ýalňyşlyk', 'Faýl ýüklenilmedi', ColorConstants.redColor);
    }
  }

  void showDownloadOption(BuildContext context, String url) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kPrimaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  downloadFile(url);
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Ýükle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
