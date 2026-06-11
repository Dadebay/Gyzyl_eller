// ignore_for_file: empty_catches, unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/models/saved_request_model.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/core/controllers/balance_controller.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/job_notification_controller.dart';
import 'package:gyzyleller/shared/dialogs/dialogs_utils.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/task/controllers/task_controller.dart';

class CoefficientModel {
  final double coefficient;
  final int minPrice;
  final int maxPrice;

  CoefficientModel({
    required this.coefficient,
    required this.minPrice,
    required this.maxPrice,
  });

  factory CoefficientModel.fromJson(Map<String, dynamic> json) {
    return CoefficientModel(
      coefficient: double.tryParse(json['coefficient'].toString()) ?? 1.0,
      minPrice: int.tryParse(json['min_price'].toString()) ?? 0,
      maxPrice: int.tryParse(json['max_price'].toString()) ?? 9999999,
    );
  }
}

class JobDetailController extends GetxController {
  final RefreshController refreshController = RefreshController();
  Future<void> markJobDoneByMasterWithRequestId() async {
    if (job.value == null || isCompletingJob.value) return;

    isCompletingJob.value = true;

    try {
      final int? requestId = job.value!.requestId;
      final int idToSend = requestId ?? job.value!.id;

      final ok = await _jobsService.markJobDoneByMaster(idToSend);

      if (ok) {
        isCompleteRequestSent.value = true;

        // Optimistic update: mark job as finished locally for instant UI transition
        if (job.value != null) {
          job.value = job.value!.copyWith(finished: true);
        }

        // Background refresh to sync with server
        fetchJobDetail(job.value!.id);
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
  final RxBool commentHasError = false.obs;

  final RxBool isOfferSent = false.obs;
  final RxString sentPrice = ''.obs;
  final RxString sentComment = ''.obs;

  final RxBool isCompletingJob = false.obs;
  final RxBool isCompleteRequestSent = false.obs;

  final BalanceController _balanceController = Get.find<BalanceController>();
  RxDouble get userBalance => _balanceController.balance;
  final RxBool isLoggedIn = false.obs;

  // Template specific state
  final RxBool showingTemplates = false.obs;
  final RxBool showSuccessBanner = false.obs;
  final RxList<SavedRequestModel> templates = <SavedRequestModel>[].obs;
  final RxBool isLoadingTemplates = false.obs;
  final RxBool isSavingTemplate = false.obs;
  final RxnInt chatIdFromApi = RxnInt();
  final RxBool fromTaskView = false.obs;
  final RxInt taskTabIndex = 0.obs;
  final RxInt basePercent = 10.obs;

  final RxList<CoefficientModel> coefficients = <CoefficientModel>[].obs;
  final RxDouble calculatedFee = 0.0.obs;
  final RxDouble persistedFee = 0.0.obs;
  int? jobId;
  bool initialShowDelete = false;

  @override
  void onInit() {
    super.onInit();

    final dynamic args = Get.arguments;
    if (args is int) {
      jobId = args;
    } else if (args is Map<String, dynamic>) {
      jobId = args['id'];
      canDelete.value = args['canDelete'] ?? false;
      initialShowDelete = args['showDelete'] ?? canDelete.value;
      if (args.containsKey('chatId')) {
        chatIdFromApi.value = int.tryParse(args['chatId'].toString());
      }
      fromTaskView.value = args['fromTaskView'] ?? false;
      taskTabIndex.value = args['taskTabIndex'] ?? 0;
    }

    // Load persisted fee from local storage
    if (jobId != null) {
      try {
        final savedFee = GetStorage().read('job_fee_$jobId');
        if (savedFee != null) {
          persistedFee.value = double.tryParse(savedFee.toString()) ?? 0.0;
        }
      } catch (e) {}
    }

    // Use microtask to avoid "setState() or markNeedsBuild() called during build" errors
    // which can happen if these synchronous updates trigger Obx widgets in the current build frame.
    Future.microtask(() {
      isLoggedIn.value = AuthStorage().isLoggedIn;
      fetchBalance();
      fetchTemplates();
      fetchCoefficients();

      if (jobId != null) {
        fetchJobDetail(jobId!);
      } else {
        isLoading.value = false;
        error.value = 'Job ID is missing';
      }
    });

    pageController.addListener(_updateCurrentPage);
    commentController.addListener(() {
      currentCommentText.value = commentController.text;
      if (commentHasError.value && commentController.text.trim().isNotEmpty) {
        commentHasError.value = false;
      }
    });

    priceController.addListener(calculateDynamicFee);
  }

  void calculateDynamicFee() {
    print(
        '💰 [calculateDynamicFee] basePercent is currently: ${basePercent.value}');

    final String text;
    if (isOfferSent.value && sentPrice.value.isNotEmpty) {
      text = sentPrice.value.trim();
      print('💰 [calculateDynamicFee] Offer sent! Using sentPrice: "$text"');
    } else {
      text = priceController.text.trim();
      print('💰 [calculateDynamicFee] text typed: "$text"');
    }

    if (text.isEmpty) {
      calculatedFee.value = 0.0;
      print('💰 [calculateDynamicFee] Empty text -> fee 0');
      return;
    }

    final price = double.tryParse(text);
    if (price == null) {
      calculatedFee.value = 0.0;
      print('💰 [_calculateDynamicFee] Invalid price -> fee 0');
      return;
    }

    // Find the right coefficient
    CoefficientModel? matchedCoef;
    for (final coef in coefficients) {
      if (price >= coef.minPrice && price <= coef.maxPrice) {
        matchedCoef = coef;
        break;
      }
    }

    final coefValue = matchedCoef?.coefficient ?? 1.0;
    print(
        '💰 [_calculateDynamicFee] matchedCoef: $matchedCoef, coefValue: $coefValue');
    print('💰 [_calculateDynamicFee] basePercent: ${basePercent.value}');

    // Calculate fee: fee = price * (basePercent * coefficient) / 100
    final double result = (price * (basePercent.value * coefValue)) / 100.0;
    calculatedFee.value = result;

    if (result > 0) {
      persistedFee.value = result;
      // Local recording
      try {
        GetStorage().write('job_fee_$jobId', result);
      } catch (e) {}
    }
  }

  Future<void> fetchCoefficients() async {
    try {
      final response =
          await ApiService().getRequest('api/base-price-coefficients');
      if (response != null && response['success'] == true) {
        final List data = response['data'];
        coefficients.value = data.map((e) {
          try {
            return CoefficientModel.fromJson(e as Map<String, dynamic>);
          } catch (err) {
            return CoefficientModel(
                coefficient: 1.0, minPrice: 0, maxPrice: 9999999);
          }
        }).toList();
        calculateDynamicFee();
      } else {}
    } catch (e, stacktrace) {
      print(stacktrace);
    }
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
    // Only show full-page loading on initial fetch
    final bool isInitialLoad = job.value == null;
    if (isInitialLoad) {
      isLoading.value = true;
    }
    error.value = '';

    try {
      final response = await _jobsService.getJobDetail(jobId);
      job.value = response.job;
      basePercent.value = response.basePercent;
      final bool isTaskView = fromTaskView.value;
      if (isTaskView) {
        final int? myId = AuthStorage().getUserId();
        final bool isOtherSelected = job.value?.status == 3 &&
            job.value?.selectedUserId != null &&
            myId != null &&
            job.value?.selectedUserId != myId;
            
        final bool isExpired = job.value?.status == 7;

        if (initialShowDelete && (job.value?.finished == true ||
            job.value?.status != 3 ||
            isOtherSelected || isExpired)) {
          canDelete.value = true;
        } else {
          canDelete.value = false;
        }
      }

      if (job.value?.selected == true || job.value?.requestId != null) {
        print(
            '📡 [JobDetailController] Fetching request details for jobId: $jobId');
        _fetchRequestDetails(jobId);
      }

      if (job.value?.reviewId != null) {
        _fetchReviewReplies(job.value!.reviewId!);
      }

      print(
          '📡 [JobDetailController] Review Rating: ${job.value?.reviewRating}');

      // Refresh user balance when job detail is loaded/refreshed
      fetchBalance();

      if (isInitialLoad) isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      if (isInitialLoad) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _fetchRequestDetails(int jobId) async {
    try {
      final response = await _jobsService.getMyRequestOnJob(jobId);
      if (response != null) {
        if (response['chat_id'] != null) {
          chatIdFromApi.value = int.tryParse(response['chat_id'].toString());
          if (job.value != null && chatIdFromApi.value != null) {
            job.value = job.value!.copyWith(chatId: chatIdFromApi.value);
          }
        }
        if (response['price'] != null) {
          sentPrice.value = response['price'].toString();
        }
        if (response['id'] != null) {
          isOfferSent.value = true;
        }
        // recalculate fee using the updated state
        calculateDynamicFee();
      }
    } catch (e) {
      print('Error fetching request details: $e');
    }
  }

  Future<void> _fetchReviewReplies(int reviewId) async {
    try {
      print(
          '📡 [JobDetailController] Fetching replies for reviewId: $reviewId');
      final ApiService apiService = ApiService();
      final List<dynamic> replyList =
          await apiService.getReviewReplies(reviewId.toString());
      print(
          '📡 [JobDetailController] Received ${replyList.length} replies for review: $reviewId');

      if (job.value != null) {
        final replies = replyList
            .map((r) => ReviewReply.fromJson(r as Map<String, dynamic>))
            .toList();
        job.value = job.value!.copyWith(reviewReplies: replies);
        print(
            '📡 [JobDetailController] Updated job.reviewReplies. New length: ${job.value!.reviewReplies.length}');
      }
    } catch (e) {
      print('⚠️ [JobDetailController] Error fetching review replies: $e');
    }
  }

  Future<void> markJobDoneByMaster() async {
    if (job.value == null || isCompletingJob.value) return;

    isCompletingJob.value = true;

    try {
      final ok = await _jobsService.markJobDoneByMaster(job.value!.id);

      if (ok) {
        isCompleteRequestSent.value = true;

        // Optimistic update: mark job as finished locally
        if (job.value != null) {
          job.value = job.value!.copyWith(finished: true);
        }

        // Background refresh
        fetchJobDetail(job.value!.id);

        // Clear notifications for this job
        if (Get.isRegistered<JobNotificationController>()) {
          Get.find<JobNotificationController>()
              .clearNotificationsByJob(job.value!.id.toString());
        }
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
    await _balanceController.fetchBalance();
    isLoggedIn.value = AuthStorage().isLoggedIn;
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
      commentHasError.value = true;
      return;
    }

    if (comment.length > 1000) {
      CustomWidgets.showSnackBar(
          'error_title'.tr, 'comment_too_long'.tr, ColorConstants.redColor);
      return;
    }

    // Sunucu nginx client_max_body_size limiti nedeniyle buyuk Kiril icerigi reddediyor.
    // Kiril harfleri UTF-8'de 2 byte yer kaplar (Latin = 1 byte).
    if (utf8.encode(comment).length > 900) {
      CustomWidgets.showSnackBar(
          'error_title'.tr, 'comment_too_large'.tr, ColorConstants.redColor);
      return;
    }

    // Calculate the required fee for this offer
    CoefficientModel? matchedCoef;
    for (final coef in coefficients) {
      if (price >= coef.minPrice && price <= coef.maxPrice) {
        matchedCoef = coef;
        break;
      }
    }

    final coefValue = matchedCoef?.coefficient ?? 1.0;
    final requiredFee = (price * (basePercent.value * coefValue)) / 100.0;
    final currentBalance = userBalance.value;

    // Close bottom sheet first
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 200));

    // Capture controller references BEFORE any navigation so the closure always
    // has a valid reference even if GetX re-creates them during Get.offAll/login.
    final HomeController? capturedHome =
        Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    final TaskController? capturedTask =
        Get.isRegistered<TaskController>() ? Get.find<TaskController>() : null;

    // Show dialog and wait for user confirmation
    DialogUtils().showInsufficientOfferBalanceDialog(
      Get.context!,
      requiredFee: requiredFee,
      onOk: () async {
        // Submit the request — only navigate on success
        final success = await _submitValidatedJobRequest(price, comment);
        if (!success) return;

        // ── Step 1: Pop ALL routes back to BottomNavBar ─────────────────────
        Get.until((route) => route.isFirst);

        // ── Step 2: Switch tab — use captured ref first, fall back to Get.find.
        // Use addPostFrameCallback so changePage always runs after the current
        // frame completes (route animations included), regardless of device speed.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          final home = capturedHome ??
              (Get.isRegistered<HomeController>()
                  ? Get.find<HomeController>()
                  : null);
          if (home != null) {
            home.changePage(1);
            print('✅ [Offer] Switched to TaskView (tab 1)');
          } else {
            print('❌ [Offer] HomeController not found — tab switch skipped');
          }

          // ── Step 3: Force-refresh the my_offers list ─────────────────────
          Future.delayed(const Duration(milliseconds: 300), () {
            final task = capturedTask ??
                (Get.isRegistered<TaskController>()
                    ? Get.find<TaskController>()
                    : null);
            task?.fetchRequestedJobs(isRefresh: true);
            print('✅ [Offer] Tekliplerim list refreshed');
          });
        });
      },
    );
  }

  Future<bool> _submitValidatedJobRequest(double price, String comment) async {
    if (job.value == null || isSubmittingRequest.value) return false;

    isSubmittingRequest.value = true;
    Get.dialog(CustomWidgets.loader(), barrierDismissible: false);

    try {
      print('=== [OFFER SUBMISSION DIAGNOSTICS - CONTROLLER] ===');
      print('Job ID: ${job.value!.id}');
      print('Price: $price');
      print('Comment: $comment');
      print('Auth Token: ${AuthStorage().token}');
      print('API URL: ${MyJobsService().getSendJobRequestUrl(job.value!.id)}');
      print('==================================================');

      await _jobsService.sendJobRequest(
        job.value!.id,
        price: price,
        comment: comment,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Delay fetching balance to allow backend to process the transaction
      await Future.delayed(const Duration(seconds: 1));
      fetchBalance();
      if (Get.isRegistered<JobNotificationController>()) {
        Get.find<JobNotificationController>().fetchNotificationCounters();
      }

      isOfferSent.value = true;
      sentPrice.value = priceController.text;
      sentComment.value = commentController.text;

      priceController.clear();
      commentController.clear();

      fetchJobDetail(job.value!.id);

      // Clear notifications for this job since the user has interacted with it
      if (Get.isRegistered<JobNotificationController>()) {
        Get.find<JobNotificationController>()
            .clearNotificationsByJob(job.value!.id.toString());
      }

      return true;
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      final errorMsg =
          e.toString().toLowerCase().contains('connection reset') ||
                  e.toString().toLowerCase().contains('connection closed')
              ? 'offer_too_large'.tr
              : 'offer_not_sent'.tr;
      CustomWidgets.showSnackBar(
          'error_title'.tr, errorMsg, ColorConstants.redColor);
      return false;
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
    final text = template.comment;
    commentController.text =
        text.length > 1000 ? text.substring(0, 1000) : text;
    showingTemplates.value = false;
  }

  Future<void> deleteTemplate(int index) async {
    if (index >= 0 && index < templates.length) {
      final template = templates[index];
      try {
        await _jobsService.deleteSavedRequest(template.id);
        templates.removeAt(index);
      } catch (e) {
        CustomWidgets.showSnackBar('error_title'.tr, 'template_not_deleted'.tr,
            ColorConstants.redColor);
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

  bool get isSelectedMaster {
    final user = AuthStorage().getUser();
    final currentUserId = int.tryParse(user?['id']?.toString() ?? '');
    return job.value?.selectedUserId != null &&
        job.value?.selectedUserId == currentUserId;
  }

  Future<bool> replyToReview(String reviewId, String replyText) async {
    try {
      final response = await _jobsService.replyToReview(reviewId, replyText);

      final isSuccess = _isSuccessfulSaveResponse(response);

      if (isSuccess) {
        // Fetch updated replies after a short delay
        Future.delayed(const Duration(milliseconds: 400), () {
          _fetchReviewReplies(int.tryParse(reviewId) ?? 0);
        });
        // Reply yapılınca type_id=5 bildirimi karşı tarafa gider;
        // kendi sayacını güncelle (başka job'lardan gelen type_id=5 olabilir)
        if (Get.isRegistered<JobNotificationController>()) {
          print('🔔 [replyToReview] reply başarılı → fetchNotificationCounters');
          Get.find<JobNotificationController>().fetchNotificationCounters();
        }
        return true;
      } else {
        CustomWidgets.showSnackBar(
          'error_title'.tr,
          'connection_error'.tr,
          ColorConstants.redColor,
        );
        return false;
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
        'error_title'.tr,
        'connection_error'.tr,
        ColorConstants.redColor,
      );
      return false;
    }
  }

  Future<bool> editReview(String reviewId, String reviewText) async {
    try {
      final response = await _jobsService.editReview(reviewId, reviewText);

      final isSuccess = _isSuccessfulSaveResponse(response);

      if (isSuccess) {
        CustomWidgets.showSnackBar(
          'success_title'.tr,
          'success_subtitle'.tr,
          ColorConstants.greenColor,
        );
        // Small delay to let the dialog close smoothly
        Future.delayed(const Duration(milliseconds: 400), () {
          fetchJobDetail(int.tryParse(job.value?.id.toString() ?? '') ?? 0);
        });
        // Edit yapılınca da sayacı güncelle
        if (Get.isRegistered<JobNotificationController>()) {
          print('🔔 [editReview] edit başarılı → fetchNotificationCounters');
          Get.find<JobNotificationController>().fetchNotificationCounters();
        }
        return true;
      } else {
        CustomWidgets.showSnackBar(
          'error_title'.tr,
          'connection_error'.tr,
          ColorConstants.redColor,
        );
        return false;
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
        'error_title'.tr,
        'connection_error'.tr,
        ColorConstants.redColor,
      );
      return false;
    }
  }

  bool _isSuccessfulSaveResponse(dynamic response) {
    if (response is bool) return response;
    if (response is String) {
      final normalized = response.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == 'success' ||
          normalized == '200' ||
          normalized == '201';
    }
    if (response is int) return response >= 200 && response < 300;
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

      final bool hasDataPayload = response['data'] != null;

      return successTrue || has2xxStatus || hasDataPayload;
    }
    return false;
  }
}
