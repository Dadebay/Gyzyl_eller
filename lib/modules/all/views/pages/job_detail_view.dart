// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/modules/special_profile/widgets/review_tile.dart';
// ignore_for_file: deprecated_member_use, unused_element
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/utils/all_view_tag_resolver.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/modules/all/controllers/job_detail_controller.dart';
import 'package:gyzyleller/modules/all/views/pages/info_row.dart';
import 'package:gyzyleller/modules/all/views/pages/new_tag.dart';
import 'package:gyzyleller/core/models/my_tasks_status.dart';
import 'package:gyzyleller/modules/all/views/pages/small_info.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/dialogs/dialogs_utils.dart';
import 'package:gyzyleller/modules/all/views/pages/job_request_bottom_sheet.dart';
import 'package:gyzyleller/shared/widgets/full_screen_image_gallery.dart';
import 'package:gyzyleller/modules/all/views/pages/account_summary_bar.dart';
import 'package:gyzyleller/modules/settings_profile/views/wallet_view.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/modules/login/views/login_view.dart';
import 'package:gyzyleller/modules/login/bindings/login_binding.dart';
import 'package:dio/dio.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:gyzyleller/shared/widgets/custom_flutter_map.dart';
import 'package:gyzyleller/shared/widgets/services_map_screen.dart';
import 'package:gyzyleller/core/models/location_model.dart';
import 'package:gyzyleller/modules/chats/views/chat_detail_view.dart';

class JobDetailView extends StatelessWidget {
  // DEBUG: job.answers listesini konsola yazdır

  const JobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final JobDetailController controller = Get.put(JobDetailController());

    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        elevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 26,
            color: ColorConstants.kPrimaryColor2,
          ),
        ),
        centerTitle: true,
        title: Text(
          "ginis".tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => controller.canDelete.value
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  offset: const Offset(-12, 40),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    maxWidth: 48,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      height: 25,
                      padding: const EdgeInsets.only(
                          left: 12.5, right: 5, top: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            IconConstants.trash,
                            width: 22,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete' && controller.job.value != null) {
                      final bool isProposal = controller.fromTaskView.value &&
                          controller.taskTabIndex.value == 0;
                      final deleted = await DialogUtils().showDeleteJobDialog(
                          context, controller.job.value!.id,
                          isRequest: isProposal);
                      if (deleted == true) {
                        Get.back();
                      }
                    }
                  },
                )
              : const SizedBox.shrink()),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        print(
            '🔴 [OBX] isLoading=${controller.isLoading.value}, error="${controller.error.value}", job=${controller.job.value?.id}');
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: ColorConstants.blue,
              backgroundColor: ColorConstants.background,
              strokeWidth: 4.0,
            ),
          );
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedJobSearch,
                    size: 84,
                    color: ColorConstants.greyColor,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'error'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.kPrimaryColor2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      dynamic args = Get.arguments;
                      int? id;
                      if (args is int) {
                        id = args;
                      } else if (args is Map && args.containsKey('id')) {
                        id = args['id'];
                      }
                      if (id != null) controller.fetchJobDetail(id);
                    },
                    child: Text(
                      'try_again'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final job = controller.job.value;
        if (job == null) return Center(child: Text("no_data_found".tr));

        // Eğer review/comment varsa göster, yoksa job.review alanını kullan
        Widget? reviewCard;
        Widget? reviewApproveBox;
        final reviewAnswer = job.answers.firstWhereOrNull(
          (a) => a.type == 'review' || a.type == 'comment',
        );

        String? reviewText = reviewAnswer?.value ?? job.review;
        int rating = reviewAnswer?.rating ?? job.reviewRating ?? 0;

        print('🔍 [OFFER_BOX] reviewText: "$reviewText"');
        print('🔍 [OFFER_BOX] job.priceComment raw: "${job.priceComment}"');
        print('🔍 [OFFER_BOX] job.commentComment raw: "${job.commentComment}"');
        print('🔍 [OFFER_BOX] job.selectedUserId: ${job.selectedUserId}');
        print(
            '🔍 [OFFER_BOX] job.finished: ${job.finished}, job.status: ${job.status}');

        if ((reviewText != null && reviewText.isNotEmpty) || rating > 0) {
          reviewText ??= '';
          final int? myUserId = AuthStorage().getUserId();
          final bool isSelectedUser = myUserId != null &&
              job.selectedUserId != null &&
              myUserId == job.selectedUserId;

          print(
              '🔍 [JobDetailView] isSelectedUser (for reply box): $isSelectedUser');
          print(
              '🔍 [JobDetailView] controller.isSelectedMaster: ${controller.isSelectedMaster}');
          print(
              '🔍 [JobDetailView] myUserId: $myUserId, job.selectedUserId: ${job.selectedUserId}');

          if (isSelectedUser) {
            final String offerPrice = (job.priceComment == null ||
                    job.priceComment!.trim().isEmpty ||
                    job.priceComment!.trim() == 'null' ||
                    job.priceComment!.trim() == '0')
                ? ''
                : job.priceComment!.trim();
            final String offerComment = (job.commentComment == null ||
                    job.commentComment!.trim().isEmpty ||
                    job.commentComment!.trim() == 'null')
                ? ''
                : job.commentComment!.trim();

            print(
                '🔍 [OFFER_BOX] isSelectedUser=true → offerPrice: "$offerPrice", offerComment: "$offerComment"');

            reviewApproveBox = Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const HugeIcon(
                          icon: HugeIcons.strokeRoundedTick03,
                          color: Color(0xFF4BB543),
                          size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'review_approved'.tr,
                          style: const TextStyle(
                            color: Color(0xFF1B2B50),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          final reviewModel = ReviewModel(
            id: job.reviewId?.toString() ?? '',
            userId: job.userId?.toString() ?? '',
            jobId: job.id.toString(),
            review: reviewText,
            rating: rating,
            requestId: job.requestId?.toString() ?? '',
            createdAt: DateTime.tryParse(job.createdAt) ?? DateTime.now(),
            username: job.username,
            image: job.image,
            replies: job.reviewReplies,
          );

          final String? currentUserId = AuthStorage().getUserId()?.toString();
          final bool canEditOwnReview = AuthStorage().isLoggedIn &&
              currentUserId != null &&
              currentUserId == reviewModel.userId;

          reviewCard = ReviewTile(
            review: reviewModel,
            isOwner: controller.isSelectedMaster,
            hideReplyEdit: false,
            onEditReview: canEditOwnReview
                ? (id, text) => controller.editReview(id, text)
                : null,
            onReply: controller.isSelectedMaster
                ? (reviewId, replyText) =>
                    controller.replyToReview(reviewId, replyText)
                : null,
          );
        }

        final List<String> images = [];
        if (job.images.isNotEmpty) {
          for (final img in job.images) {
            images.add(_resolveMediaUrl(img));
          }
        }

        for (final answer in job.answers) {
          if ((answer.type == 'image' || answer.type == 'file') &&
              answer.value != null &&
              answer.value!.isNotEmpty) {
            images.add(_resolveMediaUrl(answer.value!));
          }
        }

        if (images.isNotEmpty) {
          print('📸 [JOB_DETAIL] Total Images Loaded: ${images.length}');
          for (int i = 0; i < images.length; i++) {
            print('📸 [JOB_DETAIL] Image[$i]: ${images[i]}');
          }
        }

        final position = controller.parsePosition(job.position);
        final jobStatusEnum = MyTasksStatus.fromApiValue(job.status);
        final args = Get.arguments;
        final bool fromAllView = args is Map && args['fromAllView'] == true;
        final bool fromTaskView = args is Map && args['fromTaskView'] == true;
        final int taskTabIndex =
            args is Map ? ((args['taskTabIndex'] as int?) ?? 0) : 0;
        final AllViewTagResolver tagResolver = AllViewTagResolver();
        AllViewTagData? detailTag;
        if (fromAllView) {
          detailTag =
              tagResolver.resolve(job, isLoggedIn: controller.isLoggedIn.value);
        } else if (fromTaskView) {
          if (taskTabIndex == 0) {
            detailTag = _TaskRequestedDetailTagResolver().resolve(job);
          } else {
            detailTag = _TaskProcessingDetailTagResolver().resolve(job);
          }
        }

        String displayCreatedAt = job.createdAt;
        try {
          final dateTime = DateTime.parse(job.createdAt);
          displayCreatedAt = DateFormat('dd.MM.yyyy').format(dateTime);
        } catch (_) {}

        return SmartRefresher(
          header: const MaterialClassicHeader(
            color: ColorConstants.blue,
            backgroundColor: ColorConstants.background,
          ),
          controller: controller.refreshController,
          enablePullDown: true,
          enablePullUp: false,
          onRefresh: () async {
            await controller.fetchJobDetail(controller.job.value!.id);
            controller.refreshController.refreshCompleted();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0, bottom: 20.0),
            children: [
              _buildDateCard(displayCreatedAt),
              const SizedBox(height: 16),
              Text(
                'isin_gys'.tr,
                style: const TextStyle(
                    color: ColorConstants.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                job.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (job.desc.isNotEmpty)
                _buildInfoCard(
                  title: "additional_info_label".tr,
                  content: job.desc,
                  isAdditional: true,
                  isExpandable: true,
                  controller: controller,
                ),
              const SizedBox(height: 16),
              ..._buildGroupedAnswers(job),
              const SizedBox(height: 8),
              if (images.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "file_img".tr,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.blue),
                    ),
                    const SizedBox(height: 12),
                    _buildImageGallery(
                      images,
                      controller.currentPage.value,
                      controller,
                      context,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (job.files.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ...job.files.map((file) => _buildFileCard(file)),
                    const SizedBox(height: 16),
                  ],
                ),
              if (job.position != null &&
                  job.position!.isNotEmpty &&
                  job.position != "0.0, 0.0" &&
                  job.position != "(0.0, 0.0)") ...[
                const SizedBox(height: 14),
                _buildMapPreview(job, position, context),
                const SizedBox(height: 14),
              ],
              Text(
                'bash_mag'.tr,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.blue),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  bool shouldHideTag = detailTag?.hideTag ?? false;
                  if (detailTag?.label == 'status_viewed'.tr) {
                    shouldHideTag = true;
                  }
                  print('[JOB_DETAIL][TAG] status: ${job.status}');
                  print('[JOB_DETAIL][TAG] label: ${detailTag?.label}');
                  print('[JOB_DETAIL][TAG] hideTag: $shouldHideTag');
                  return NewTag(
                    status: job.status,
                    hideTag: shouldHideTag,
                    customLabel: detailTag?.label,
                    customTextColor: detailTag?.textColor,
                    customBgColor: detailTag?.bgColor,
                    customIcon: detailTag?.icon,
                  );
                },
              ),
              if (jobStatusEnum == MyTasksStatus.retEdilen) ...[
                const SizedBox(height: 12),
                if (job.rejectedReason != null &&
                    job.rejectedReason!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          job.rejectedReason!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              job.status == 3 &&
                      AuthStorage().isLoggedIn == true &&
                      job.userId.toString() ==
                          AuthStorage().masterProfileId.toString()
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                              child: Text('executor_selected_info'.tr,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: ColorConstants.fonts,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              _buildOtherInfoSection(context, job),
              const SizedBox(height: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final currentJob = controller.job.value;
                    if (currentJob == null) return const SizedBox.shrink();

                    // Hide offer button if this job belongs to the logged-in user
                    final int? myUserId = AuthStorage().getUserId();
                    print('🔍 [OFFER_BTN] job.userId = ${currentJob.userId}');
                    print('🔍 [OFFER_BTN] myUserId   = $myUserId');
                    print(
                        '🔍 [OFFER_BTN] eşitmi?    = ${currentJob.userId == myUserId}');
                    if (myUserId != null &&
                        currentJob.userId != null &&
                        currentJob.userId == myUserId) {
                      return const SizedBox.shrink();
                    }

                    final bool hasOffer = controller.isOfferSent.value ||
                        currentJob.requestId != null;

                    final String priceVal = controller.isOfferSent.value
                        ? controller.sentPrice.value
                        : (currentJob.priceComment?.isNotEmpty == true
                            ? currentJob.priceComment!
                            : controller.sentPrice.value);
                    final String commentVal = controller.isOfferSent.value
                        ? controller.sentComment.value
                        : (currentJob.commentComment?.isNotEmpty == true
                            ? currentJob.commentComment!
                            : controller.sentComment.value);

                    final bool showOfferSuccessCard = hasOffer &&
                        priceVal.trim().isNotEmpty &&
                        priceVal.trim() != 'null' &&
                        priceVal.trim() != '0' &&
                        commentVal.trim().isNotEmpty &&
                        commentVal.trim() != 'null';

                    // Hide offer button/actions if job is finished or status == tamamlanan (4) or expired (7)
                    // Also hide if status == 3 (selected) AND finished == true (task_status_done_no_rating)
                    // Also hide if status == 3 (worker selected) AND coming from all_view - status_worker_selected
                    final bool fromAllView = Get.arguments is Map &&
                        (Get.arguments as Map)['fromAllView'] == true;

                    final bool isStatusRestricted = currentJob.finished ||
                        currentJob.status == 4 ||
                        currentJob.status == 7 ||
                        (currentJob.status == 3 && fromAllView) ||
                        (currentJob.status == 3 && currentJob.finished == true);

                    // If no offer was made and status is restricted, show nothing
                    if (!showOfferSuccessCard && isStatusRestricted) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _buildCommissionInfo(controller),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              );
                            },
                            child: showOfferSuccessCard
                                ? Column(
                                    key: const ValueKey('offer_sent'),
                                    children: [
                                      _buildOfferSuccessBox(
                                        price: priceVal,
                                        comment: commentVal,
                                      ),
                                      const SizedBox(height: 16),
                                      if (!isStatusRestricted) ...[
                                        if (currentJob.selected ||
                                            currentJob.chatId != null ||
                                            controller.chatIdFromApi.value !=
                                                null) ...[
                                          _buildActionButtons(
                                              context, currentJob),
                                          const SizedBox(height: 16),
                                        ],
                                        if (currentJob.selected) ...[
                                          if (controller
                                              .isCompleteRequestSent.value)
                                            const SizedBox.shrink()
                                          else
                                            SizedBox(
                                              width: double.infinity,
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: controller
                                                        .isCompletingJob.value
                                                    ? null
                                                    : () async {
                                                        final result =
                                                            await DialogUtils()
                                                                .showCompleteJobDialog(
                                                                    context);
                                                        if (result == true) {
                                                          controller
                                                              .markJobDoneByMasterWithRequestId();
                                                        }
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      ColorConstants
                                                          .kPrimaryColor2,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: controller
                                                        .isCompletingJob.value
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : Text(
                                                        'complete_job'.tr,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          const SizedBox(height: 16),
                                        ],
                                      ],
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('make_offer'),
                                    children: [
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!controller.isLoggedIn.value) {
                                              Get.to(() => const LoginView(),
                                                  binding: LoginBinding());
                                              return;
                                            }
                                            _checkMasterAndExecute(
                                                context, "make_offer".tr, () {
                                              controller.showingTemplates
                                                  .value = false;
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) =>
                                                    const JobRequestBottomSheet(),
                                              );
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ColorConstants.kPrimaryColor2,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            "make_offer".tr,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ]);
                  }),
                  const SizedBox(height: 10),
                  if (reviewApproveBox != null) ...[
                    reviewApproveBox,
                  ],
                  if (reviewCard != null) ...[
                    reviewCard,
                  ],
                  const SizedBox(height: 20),
                  Obx(() => controller.isLoggedIn.value
                      ? AccountSummaryBar(
                          balanceText:
                              '${"wallet".tr}: ${controller.userBalance.value.toStringAsFixed(0)} TMT',
                          onPressed: () => Get.to(() => const WalletView()),
                          onBalanceTap: () => Get.to(() => const WalletView()),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCommissionInfo(JobDetailController controller) {
    return Obx(() {
      final isSelected = controller.job.value?.selected == true ||
          controller.job.value?.status == 3;
      final fee = controller.calculatedFee.value > 0
          ? controller.calculatedFee.value
          : controller.persistedFee.value;

      if (isSelected || fee == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: ColorConstants.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              color: ColorConstants.secondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'offer_fee_info'.trParams({'fee': fee.toStringAsFixed(0)}),
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorConstants.secondary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context, JobModel job) {
    final controller = Get.find<JobDetailController>();
    final String? chatId =
        job.chatId?.toString() ?? controller.chatIdFromApi.value?.toString();
    final bool hasChat = chatId != null;
    final bool hasPhone = job.phone != null && job.phone!.isNotEmpty;

    return Row(
      children: [
        if (hasPhone)
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(job.phone),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCall,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'call_button'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kSecondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        if (hasPhone && hasChat) const SizedBox(width: 12),
        if (hasChat)
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToChat(job),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedBubbleChat,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'chat_button'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _navigateToChat(JobModel job) {
    final JobDetailController controller = Get.find<JobDetailController>();
    final String? chatId =
        job.chatId?.toString() ?? controller.chatIdFromApi.value?.toString();

    if (chatId == null) {
      print('❌ [JobDetail] chatId is null, cannot navigate to chat');
      return;
    }

    print('🚀 [JobDetail] Navigating to Chat: $chatId');

    final String productImage = job.images.isNotEmpty ? job.images.first : '';
    final LatLng pos = controller.parsePosition(job.position);

    Get.to(
      () => ChatDetailView(
        chatId: chatId,
        userId: (job.userId ?? 0).toString(),
        userName: job.username,
        userPicture: job.image ?? '',
        productId: job.id.toString(),
        productImage: productImage,
        productPrice: (job.minPrice == 0 && job.maxPrice == 0)
            ? "not_priced".tr
            : "${job.minPrice} - ${job.maxPrice} TMT",
        productTitle: job.name,
        productStatus: job.status.toString(),
        lastSeen: '',
        blocked: false,
        notification: false, // Changed to false as this is a real chat session
        postLat: pos.latitude.toString(),
        postLng: pos.longitude.toString(),
      ),
    )?.then((_) {
      // Refresh chats when coming back, similar to ChatsView
      controller.fetchJobDetail(job.id);
    });
  }

  void _checkMasterAndExecute(
      BuildContext context, String actionTitle, VoidCallback onExecute) {
    if (AuthStorage().masterProfileId == null) {
      DialogUtils().showFillProfileDialog(context, actionTitle);
    } else {
      onExecute();
    }
  }

  Widget _buildOfferSuccessBox(
      {required String price, required String comment}) {
    final controller = Get.find<JobDetailController>();
    return Column(children: [
      Obx(() {
        final fee = controller.calculatedFee.value > 0
            ? controller.calculatedFee.value
            : controller.persistedFee.value;
        if (fee == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: ColorConstants.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'offer_fee_info'.trParams({'fee': fee.toStringAsFixed(0)}),
                  style: const TextStyle(
                    fontSize: 15,
                    color: ColorConstants.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "your_offer_is".trParams({'price': price}),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorConstants.fonts,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.access_time,
                    size: 20, color: ColorConstants.fonts),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    comment,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConstants.fonts,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildDateCard(String dateStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(IconConstants.calendar),
          const SizedBox(width: 5),
          Text(
            dateStr,
            style: const TextStyle(
                color: ColorConstants.fonts,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    bool isAdditional = false,
    bool isExpandable = false,
    required JobDetailController controller,
  }) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorConstants.fonts,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (isExpandable)
            Obx(() {
              final isExpanded = controller.isDescExpanded.value;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final span = TextSpan(
                    text: content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ColorConstants.fonts,
                    ),
                  );
                  final tp = TextPainter(
                    text: span,
                    maxLines: 3,
                    textDirection: ui.TextDirection.ltr,
                  );
                  tp.layout(maxWidth: constraints.maxWidth);

                  if (tp.didExceedMaxLines) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: isExpanded
                                    ? content
                                    : "${content.substring(0, tp.getPositionForOffset(Offset(constraints.maxWidth, tp.height)).offset - 12)}...",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: ColorConstants.fonts,
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.isDescExpanded.toggle(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      isExpanded ? "hide".tr : "show_more".tr,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: ColorConstants.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text(
                      content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: ColorConstants.fonts,
                      ),
                    );
                  }
                },
              );
            })
          else
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: ColorConstants.fonts,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(
    List<String> images,
    int currentPage,
    JobDetailController controller,
    BuildContext context,
  ) {
    int pageCount = (images.length / 2).ceil();

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: pageCount,
            onPageChanged: (index) {
              controller.currentPage.value = index;
            },
            itemBuilder: (context, pageIndex) {
              final int firstIndex = pageIndex * 2;
              final int secondIndex = firstIndex + 1;

              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
                          onLongPress: () =>
                              _showDownloadOption(context, images[firstIndex]),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageGallery(
                                    images: images,
                                    initialIndex: firstIndex,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: images[firstIndex],
                              child: CachedNetworkImage(
                                imageUrl: images[firstIndex],
                                fit: BoxFit.cover,
                                height: 120,
                                placeholder: (context, url) =>
                                    _buildImageShimmer(),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (secondIndex < images.length)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GestureDetector(
                            onLongPress: () => _showDownloadOption(
                                context, images[secondIndex]),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FullScreenImageGallery(
                                      images: images,
                                      initialIndex: secondIndex,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: images[secondIndex],
                                child: CachedNetworkImage(
                                  imageUrl: images[secondIndex],
                                  fit: BoxFit.cover,
                                  height: 120,
                                  placeholder: (context, url) =>
                                      _buildImageShimmer(),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              );
            },
          ),
        ),
        if (pageCount > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? ColorConstants.kPrimaryColor2
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildMapPreview(JobModel job, LatLng position, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesMapScreen(
              location: Location(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
              placeName: job.name,
              catName: job.categoryName,
              welayat: job.welayat,
              etrap: job.etrap,
            ),
          ),
        );
      },
      child: CustomFlutterMap(
        aspectRatio: 360 / 200,
        width: double.infinity,
        radius: 12,
        center: position,
        markerSize: 40,
        zoom: 15.0,
        locations: [position],
        markerIcons: const [Icons.location_on],
        markerColors: const [Colors.red],
        interactive: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServicesMapScreen(
                location: Location(
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
                placeName: job.name,
                catName: job.categoryName,
                welayat: job.welayat,
                etrap: job.etrap,
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildGroupedAnswers(JobModel job) {
    if (job.answers.isEmpty) return [];

    final List<Widget> innerWidgets = [];
    int? currentFormId;

    for (var answer in job.answers) {
      if (answer.formId != null &&
          answer.formId != currentFormId &&
          answer.formName != null) {
        if (innerWidgets.isNotEmpty) {
          innerWidgets.add(const SizedBox(height: 12));
        }
        innerWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              answer.formName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorConstants.blue,
                fontFamily: 'Gil',
                fontSize: 16,
              ),
            ),
          ),
        );
      }
      currentFormId = answer.formId;

      final answerWidget = _buildSingleAnswer(answer, job, Get.context!);
      if (answerWidget != null) {
        innerWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: answerWidget,
          ),
        );
      }
    }

    if (innerWidgets.isEmpty) return [];

    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConstants.whiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: innerWidgets,
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget? _buildSingleAnswer(
      JobAnswer answer, JobModel job, BuildContext context) {
    final hasMap = (answer.lat != null && answer.lng != null) ||
        (answer.type == 'map' &&
            answer.value != null &&
            answer.value!.isNotEmpty);
    final content = _getAnswerContent(answer);

    if (content.isEmpty && !hasMap) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.isNotEmpty) _buildAnswerRow(answer.question, content),
        if (hasMap) ...[
          const SizedBox(height: 8),
          _buildAnswerMap(answer, job, context),
        ],
      ],
    );
  }

  Widget _buildAnswerMap(JobAnswer answer, JobModel job, BuildContext context) {
    final JobDetailController controller = Get.find<JobDetailController>();
    final mapPos = controller.parsePosition(answer.value ??
        ((answer.lat != null && answer.lng != null)
            ? "(${answer.lng},${answer.lat})"
            : ""));

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CustomFlutterMap(
        aspectRatio: 360 / 180,
        width: double.infinity,
        center: mapPos,
        markerSize: 30,
        zoom: 14.0,
        locations: [mapPos],
        markerIcons: const [Icons.location_on],
        markerColors: const [Colors.red],
        interactive: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServicesMapScreen(
                location: Location(
                  latitude: mapPos.latitude,
                  longitude: mapPos.longitude,
                ),
                placeName: job.name,
                catName: answer.value ?? answer.question,
                welayat: job.welayat,
                etrap: job.etrap,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerRow(String question, String answer) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            height: 1.4,
            fontFamily: 'Gilroy'),
        children: [
          TextSpan(
            text: "$question: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: answer),
        ],
      ),
    );
  }

  String _resolveLocationId(int? id) {
    if (id == null) return '';
    try {
      if (Get.isRegistered<AllController>()) {
        final allLocations = Get.find<AllController>().allLocations;
        for (var w in allLocations) {
          if (w.id == id) return w.name;
          for (var e in w.etraps) {
            if (e.id == id) {
              return w.name == e.name ? w.name : "${w.name} / ${e.name}";
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error resolving locationId $id: $e');
    }
    return '';
  }

  String _getAnswerContent(JobAnswer answer) {
    final List<String> parts = [];

    // 1. Add Options (Selections)
    if (answer.options != null && answer.options!.isNotEmpty) {
      final optionsString = answer.options!
          .map((o) => o.optionName.trim())
          .where((s) => s.isNotEmpty)
          .join(', ');
      if (optionsString.isNotEmpty) parts.add(optionsString);
    }

    // 2. Add Date and Time
    if (answer.date != null && answer.date!.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(answer.date!);
        final datePart =
            _formatSingleDateTime(dateTime, explicitTime: answer.time);
        if (datePart.trim().isNotEmpty) parts.add(datePart.trim());
      } catch (_) {
        if (answer.date!.trim().isNotEmpty) parts.add(answer.date!.trim());
        if (answer.time != null && answer.time!.isNotEmpty) {
          final timePart = answer.time!.split(':').take(2).join(':');
          if (timePart.trim().isNotEmpty) parts.add(timePart.trim());
        }
      }
    } else if (answer.time != null && answer.time!.isNotEmpty) {
      final timePart = answer.time!.split(':').take(2).join(':');
      if (timePart.trim().isNotEmpty) parts.add(timePart.trim());
    }

    String locName = '';
    if (answer.locationId != null) {
      locName = _resolveLocationId(answer.locationId);
      if (locName.isNotEmpty) {
        // Split resolved location name (which might be "Prov / Dist") into parts for better deduplication
        parts.addAll(locName
            .split(RegExp(r'[/,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty));
      }
    }

    // 3. Add Raw Value
    if (answer.value != null) {
      final raw = answer.value!.trim();
      final lowerRaw = raw.toLowerCase();

      // Skip internal placeholder flags
      if (raw.isNotEmpty && lowerRaw != 'true' && lowerRaw != 'false') {
        // Skip if it looks like coordinates and we already have a map or lat/lng
        final bool isCoord = _isCoordinateString(raw);
        final bool hasMapData = answer.lat != null || answer.type == 'map';

        if (!(isCoord && hasMapData)) {
          // Split by common separators to avoid duplication with options or other fields
          final rawParts = raw.split(RegExp(r'[/,;]'));
          for (var p in rawParts) {
            final trimmed = p.trim();
            if (trimmed.isNotEmpty) {
              parts.add(trimmed);
            }
          }
        }
      }
    }

    // Deduplicate and join
    final uniqueParts = <String>[];
    for (var p in parts) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;

      // Check if this part is already represented (either exactly or as part of another string)
      bool alreadyPresent = false;
      for (var existing in uniqueParts) {
        if (existing.toLowerCase() == trimmed.toLowerCase() ||
            existing.toLowerCase().contains(trimmed.toLowerCase())) {
          alreadyPresent = true;
          break;
        }
        // Also check reverse: if trimmed contains existing, replace existing
        if (trimmed.toLowerCase().contains(existing.toLowerCase())) {
          // Keep the longer/more specific version?
          // Actually, just let it be for now, toSet() or simple check is usually enough
        }
      }

      if (!alreadyPresent) {
        uniqueParts.add(trimmed);
      }
    }

    return uniqueParts.join(', ');
  }

  String _formatSingleDateTime(DateTime date, {String? explicitTime}) {
    final d = date.toLocal();

    final bool hasExplicitTime = explicitTime != null &&
        explicitTime.isNotEmpty &&
        explicitTime != 'null' &&
        explicitTime != '00:00:00';

    final bool hasTimeFromDate = d.hour != 0 || d.minute != 0;

    if (!hasExplicitTime && !hasTimeFromDate) {
      return '${DateFormat('dd.MM.yyyy').format(d)} ${'In calt wagytda'.tr}';
    }

    final weekday = 'weekday_${d.weekday}'.tr;
    final month = 'month_${d.month}'.tr;
    final dayPart = '$weekday, ${d.day.toString().padLeft(2, '0')} $month';

    return dayPart; // ← sadece bu satır değişti (time kaldırıldı)
  }

  String _formatDateStatus(BuildContext context, JobModel job) {
    if (job.whenToDo == 'during_the_week') {
      if (job.startDate != null &&
          job.startDate!.isNotEmpty &&
          job.startDate != 'null' &&
          job.endDate != null &&
          job.endDate!.isNotEmpty &&
          job.endDate != 'null') {
        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      }
      return job.whenToDo.tr;
    }

    if (job.whenToDo == 'date_today' || job.whenToDo == 'date_tomorrow') {
      if (job.startDate != null &&
          job.startDate!.isNotEmpty &&
          job.startDate != 'null') {
        try {
          final taskDate = DateTime.parse(job.startDate!);
          return "${job.whenToDo.tr} (${_formatSingleDateTime(taskDate)})";
        } catch (_) {}
      }
      return job.whenToDo.tr;
    }

    // Skip generic startDate handling for special_date tasks to avoid showing date_today incorrectly
    if (job.whenToDo != 'special_date' &&
        job.startDate != null &&
        job.startDate!.isNotEmpty &&
        job.startDate != 'null') {
      try {
        final taskDate = DateTime.parse(job.startDate!);
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));

        if (taskDate.year == now.year &&
            taskDate.month == now.month &&
            taskDate.day == now.day) {
          return "${"date_today".tr} (${_formatSingleDateTime(taskDate)})";
        }

        if (taskDate.year == tomorrow.year &&
            taskDate.month == tomorrow.month &&
            taskDate.day == tomorrow.day) {
          return "${"date_tomorrow".tr} (${_formatSingleDateTime(taskDate)})";
        }

        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      } catch (_) {}
    }

    if (job.whenToDo == 'urgent' || job.whenToDo.isEmpty) {
      return 'urgent_label'.tr;
    }

    if (job.whenToDo == 'special_date') {
      // Try to get date from answers first
      for (final answer in job.answers) {
        if (answer.date != null && answer.date!.isNotEmpty) {
          final range = _formatDateRange(answer.date, null);
          if (range.isNotEmpty) return range;
        }
      }
      // If no answer date, fallback to job's start and end dates
      if (job.startDate != null &&
          job.startDate!.isNotEmpty &&
          job.startDate != 'null') {
        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      }
      return 'i_will_choose_date'.tr;
    }

    return job.whenToDo.tr;
  }

  String _formatDateRange(String? start, String? end) {
    if ((start == null || start == 'null') && (end == null || end == 'null')) {
      return '';
    }
    if (start != null &&
        start != 'null' &&
        (end == null || end == 'null' || start == end)) {
      try {
        final date = DateTime.parse(start);
        return _formatSingleDateTime(date);
      } catch (_) {
        return start;
      }
    }
    try {
      final startDate = DateTime.parse(start!);
      final endDate = DateTime.parse(end!);
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        return _formatSingleDateTime(startDate);
      }
      // Different days: plain dd.MM.yyyy - dd.MM.yyyy (no weekday)
      final fmt = DateFormat('dd.MM.yyyy');
      return '${fmt.format(startDate)} - ${fmt.format(endDate)}';
    } catch (_) {
      return "${start ?? ''} - ${end ?? ''}";
    }
  }

  Widget _buildFileCard(JobFileModel file) {
    debugPrint('📄 [job_detail] FILE PATH: "${file.file}"');
    String fileName = file.file.split('/').last;
    final String fullUrl = _resolveMediaUrl(file.file);

    return InkWell(
      onTap: () async {
        await _openInExternalBrowser(fullUrl);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorConstants.whiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file,
                size: 32, color: ColorConstants.kPrimaryColor2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await _downloadFile(fullUrl);
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.download_rounded,
                    color: ColorConstants.kPrimaryColor2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageShimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.25, end: 0.45),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          height: 120,
          color: Colors.grey[400]!.withOpacity(value),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildOtherInfoSection(BuildContext context, JobModel job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: ColorConstants.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(
                icon: IconConstants.calendar,
                text: _formatDateStatus(context, job),
                suffix: 'job_date_label'.tr,
              ),
              const SizedBox(height: 10),
              InfoRow(
                icon: IconConstants.grid,
                text: job.categoryName,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SmallInfo(
                    icon: IconConstants.payment,
                    text: (job.minPrice == 0 && job.maxPrice == 0)
                        ? "not_priced".tr
                        : "${job.minPrice} TMT - ${job.maxPrice} TMT",
                  ),
                  const SizedBox(width: 16),
                  SmallInfo(
                    icon: IconConstants.builder,
                    text: "${job.responsesCount ?? 0}",
                    color:
                        job.requestId != null ? ColorConstants.secondary : null,
                  ),
                  const SizedBox(width: 16),
                  SmallInfo(
                    icon: IconConstants.eye,
                    text: "${job.viewCount ?? 0}",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoRow(
                icon: IconConstants.locationHouse,
                text: job.welayat == job.etrap
                    ? "${job.welayat}${job.address.isNotEmpty ? ', ${job.address}' : ''}"
                    : "${job.welayat}, ${job.etrap}${job.address.isNotEmpty ? ', ${job.address}' : ''}",
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.numbers,
                    size: 16,
                    color: ColorConstants.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text("№ ${job.id}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1.5, color: ColorConstants.whiteColor),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadImage(String url) async {
    try {
      print('📥 [JOB_DETAIL] Starting Download Image URL: $url');

      if (Platform.isAndroid) {
        await Permission.photos.request();
        await Permission.storage.request();
      } else if (Platform.isIOS) {
        if (!(await Permission.photos.request().isGranted)) {
          _showDownloadSnackBar(isSuccess: false);
          return;
        }
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
        print('✅ [JOB_DETAIL] Image Downloaded Successfully: $url');
        _showDownloadSnackBar(isSuccess: true);
      } else {
        print('❌ [JOB_DETAIL] Image Download Failed: $url');
        _showDownloadSnackBar(isSuccess: false);
      }
    } catch (e) {
      print('❌ [JOB_DETAIL] Download Error for URL: $url - Error: $e');
      debugPrint("Download error: $e");
      _showDownloadSnackBar(isSuccess: false);
    }
  }

  void _showDownloadSnackBar({required bool isSuccess, String? message}) {
    final String text = message ??
        (isSuccess
            ? "${'download'.tr} ${'success_title'.tr}"
            : "${'error_title'.tr}: ${'download'.tr}");

    Get.closeAllSnackbars();
    Get.snackbar(
      '',
      text,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.green.withOpacity(0.85) : Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      borderRadius: 12,
      titleText: const SizedBox.shrink(),
    );
  }

  Future<void> _openInExternalBrowser(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  Future<void> _downloadFile(String url) async {
    final lowerUrl = url.toLowerCase();
    final isImage = lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.endsWith('.gif');

    if (isImage) {
      await _downloadImage(url);
      return;
    }

    try {
      String fileName = Uri.parse(url).pathSegments.isNotEmpty
          ? Uri.parse(url).pathSegments.last
          : 'file_${DateTime.now().millisecondsSinceEpoch}';
      if (fileName.trim().isEmpty) {
        fileName = 'file_${DateTime.now().millisecondsSinceEpoch}';
      }
      fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      Directory saveDir;

      if (Platform.isAndroid) {
        final bool granted =
            await Permission.manageExternalStorage.request().isGranted ||
                await Permission.storage.request().isGranted;

        if (granted) {
          saveDir = Directory('/storage/emulated/0/Download/Gyzyleller');
        } else {
          saveDir = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        saveDir = await getApplicationDocumentsDirectory();
      } else {
        saveDir = await getTemporaryDirectory();
      }

      await saveDir.create(recursive: true);
      final String savePath = p.join(saveDir.path, fileName);

      await Dio().download(url, savePath);
      _showDownloadSnackBar(isSuccess: true);
    } catch (_) {
      _showDownloadSnackBar(isSuccess: false);
    }
  }

  String _resolveMediaUrl(String path) {
    String normalized = path.trim();
    if (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    final result = normalized.startsWith('http')
        ? normalized
        : "${Api().urlImage}$normalized";
    print('📸 [JOB_DETAIL] Resolved URL: $result');
    return result;
  }

  void _showDownloadOption(BuildContext context, String url) {
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
                        _downloadImage(url);
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: Text(
                        'download'.tr,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ));
  }

  bool _isCoordinateString(String s) {
    final clean = s.replaceAll('(', '').replaceAll(')', '').trim();
    final parts = clean.split(',');
    if (parts.length != 2) return false;
    try {
      double.parse(parts[0].trim());
      double.parse(parts[1].trim());
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _DetailTagData {
  final bool hideTag;
  final String label;
  final Color textColor;
  final Color bgColor;
  final Widget icon;

  const _DetailTagData({
    this.hideTag = false,
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.icon,
  });
}

// Resolver moved to core/utils/all_view_tag_resolver.dart

// ─── Task view — Sol tab (Tekliplerimde) detail resolver ────────────────────
class _TaskRequestedDetailTagResolver {
  final AuthStorage _auth = AuthStorage();

  AllViewTagData resolve(JobModel job) {
    if (job.status == 5) {
      return AllViewTagData(
        label: 'task_status_cancelled'.tr,
        textColor: Colors.white,
        bgColor: ColorConstants.kPrimaryColor2,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCancel01,
          size: 14,
          color: Colors.white,
        ),
      );
    }

    if (job.status == 7) {
      return AllViewTagData(
        label: 'status_expired'.tr,
        textColor: Colors.white,
        bgColor: ColorConstants.kPrimaryColor2,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedTimer02,
          size: 14,
          color: Colors.white,
        ),
      );
    }

    if (job.status == 4) {
      return AllViewTagData(
        label: 'status_done'.tr,
        textColor: const Color(0xFF616161),
        bgColor: const Color(0xFFF0F0F0),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkBadge04,
          size: 14,
          color: Color(0xFF616161),
        ),
      );
    }

    if (job.status == 3) {
      final user = _auth.getUser();
      final myId = int.tryParse((user?['id'] ?? '').toString());
      final isOtherSelected = myId != null &&
          job.selectedUserId != null &&
          job.selectedUserId != myId;
      if (isOtherSelected) {
        return AllViewTagData(
          label: 'task_status_other_selected'.tr,
          textColor: const Color(0xFF165500),
          bgColor: const Color.fromARGB(255, 120, 229, 118),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedUserCheck01,
            size: 14,
            color: Color(0xFF165500),
          ),
        );
      } else {
        // Biz saýlandyk (Ýerine ýetiriji biz)
        if (job.finished == true) {
          return AllViewTagData(
            label: 'task_status_done_no_rating'.tr,
            textColor: const Color(0xFF616161),
            bgColor: const Color(0xFFF0F0F0),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle03,
              size: 14,
              color: Color(0xFF616161),
            ),
          );
        } else {
          return AllViewTagData(
            label: 'task_status_working'.tr,
            textColor: Colors.black,
            bgColor: const Color.fromARGB(255, 120, 229, 118),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedWorkAlert,
              size: 14,
              color: Colors.black,
            ),
          );
        }
      }
    }

    if (job.finished == true) {
      return AllViewTagData(
        label: 'status_done'.tr,
        textColor: const Color(0xFF616161),
        bgColor: const Color(0xFFF0F0F0),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkBadge04,
          size: 14,
          color: Color(0xFF616161),
        ),
      );
    }

    if (job.hasSeen) {
      return AllViewTagData(
        label: 'status_viewedd'.tr,
        textColor: const Color(0xFF165500),
        bgColor: const Color.fromARGB(255, 120, 229, 118),
        icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedEye,
            size: 14,
            color: Color(0xFF165500)),
      );
    }

    return const AllViewTagData(
      hideTag: true,
      label: '',
      textColor: Colors.transparent,
      bgColor: Colors.transparent,
      icon: SizedBox.shrink(),
    );
  }
}

// ─── Task view — Sag tab (Işlerimde) detail resolver ────────────────────────
class _TaskProcessingDetailTagResolver {
  AllViewTagData resolve(JobModel job) {
    if (job.selected == true && job.finished == false) {
      return AllViewTagData(
        label: 'task_status_working'.tr,
        textColor: Colors.black,
        bgColor: const Color.fromARGB(255, 120, 229, 118),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedWorkAlert,
          size: 14,
          color: Colors.black,
        ),
      );
    }

    if (job.status == 3 && job.selected == true && job.finished == true) {
      return AllViewTagData(
        label: 'task_status_done_no_rating'.tr,
        textColor: const Color(0xFF616161),
        bgColor: const Color(0xFFF0F0F0),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkCircle03,
          size: 14,
          color: Color(0xFF616161),
        ),
      );
    }

    if (job.status == 4) {
      return AllViewTagData(
        label: 'status_done'.tr,
        textColor: const Color(0xFF616161),
        bgColor: const Color(0xFFF0F0F0),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkBadge04,
          size: 14,
          color: Color(0xFF616161),
        ),
      );
    }

    return const AllViewTagData(
      hideTag: true,
      label: '',
      textColor: Colors.transparent,
      bgColor: Colors.transparent,
      icon: SizedBox.shrink(),
    );
  }
}
