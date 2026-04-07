// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:hugeicons/hugeicons.dart';
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
import 'package:gyzyleller/modules/settings_profile/views/wallet_view.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile_add.dart';
import 'package:dio/dio.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:gyzyleller/shared/widgets/custom_flutter_map.dart';
import 'package:gyzyleller/shared/widgets/services_map_screen.dart';
import 'package:gyzyleller/core/models/location_model.dart';

class JobDetailView extends StatelessWidget {
  const JobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final JobDetailController controller = Get.put(JobDetailController());
    final RefreshController refreshController = RefreshController();

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
                  offset: const Offset(-13, 35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      height: 25,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'delete'.tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SvgPicture.asset(
                            IconConstants.trash,
                            width: 16,
                            height: 16,
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
                      final deleted = await DialogUtils().showDeleteJobDialog(context, controller.job.value!.id);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.error.value),
                const SizedBox(height: 16),
                ElevatedButton(
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
                  child: Text('try_again'.tr),
                ),
              ],
            ),
          );
        }

        final job = controller.job.value;
        if (job == null) return Center(child: Text("no_data_found".tr));

        final List<String> images = [];
        if (job.images.isNotEmpty) {
          for (final img in job.images) {
            images.add(_resolveMediaUrl(img));
          }
        }

        for (final answer in job.answers) {
          if ((answer.type == 'image' || answer.type == 'file') && answer.value != null && answer.value!.isNotEmpty) {
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

        String displayCreatedAt = job.createdAt;
        try {
          final dateTime = DateTime.parse(job.createdAt);
          final month = 'month_${dateTime.month}'.tr;
          displayCreatedAt = "${dateTime.day} $month ${dateTime.year}, ${DateFormat('HH:mm').format(dateTime)}";
        } catch (_) {}

        return SmartRefresher(
          header: const MaterialClassicHeader(
            color: ColorConstants.blue,
            backgroundColor: ColorConstants.background,
          ),
          controller: refreshController,
          enablePullDown: true,
          enablePullUp: false,
          onRefresh: () async {
            await controller.fetchJobDetail(controller.job.value!.id);
            refreshController.refreshCompleted();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 20.0),
            children: [
              _buildDateCard(displayCreatedAt),
              const SizedBox(height: 16),
              Text(
                'isin_gys'.tr,
                style: const TextStyle(color: ColorConstants.blue, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                job.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorConstants.blue),
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
              if (job.position != null && job.position!.isNotEmpty && job.position != "0.0, 0.0" && job.position != "(0.0, 0.0)") ...[
                const SizedBox(height: 14),
                _buildMapPreview(job, position, context),
                const SizedBox(height: 14),
              ],
              Text(
                'bash_mag'.tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorConstants.blue),
              ),
              const SizedBox(height: 14),
              NewTag(status: job.status),
              const SizedBox(height: 16),
              if (jobStatusEnum == MyTasksStatus.retEdilen) ...[
                Text(
                  'duzgun'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorConstants.kPrimaryColor2),
                ),
                const SizedBox(height: 12),
              ],
              _buildOtherInfoSection(context, job),
              const SizedBox(height: 15),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(builder: (context) {
                    if (job.finished) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 24, color: Colors.black),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "job_completed_rating_pending".tr,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (controller.isOfferSent.value || job.requestId != null) {
                      return Column(
                        children: [
                          if (controller.isOfferSent.value)
                            _buildOfferSuccessBox(
                              price: controller.sentPrice.value,
                              comment: controller.sentComment.value,
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: ColorConstants.whiteColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: ColorConstants.blackColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    "offer_sent".tr,
                                    style: const TextStyle(
                                      color: ColorConstants.blackColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: ElevatedButton.icon(
                          //         onPressed: () {
                          //           final phone = job.phone;
                          //           if (phone != null && phone.isNotEmpty) {
                          //             launchUrl(
                          //                 Uri(scheme: 'tel', path: phone));
                          //           }
                          //         },
                          //         icon: const Icon(Icons.call,
                          //             color: Colors.white, size: 20),
                          //         label: Text(
                          //           "jan".tr,
                          //           style: const TextStyle(
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          //         style: ElevatedButton.styleFrom(
                          //           backgroundColor:
                          //               ColorConstants.kPrimaryColor2,
                          //           padding: const EdgeInsets.symmetric(
                          //               vertical: 12),
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //           elevation: 0,
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     Expanded(
                          //       child: ElevatedButton.icon(
                          //         onPressed: () {
                          //           if (job.userId != null) {
                          //             Get.to(
                          //               () => ChatDetailView(
                          //                 chatId: '',
                          //                 userId: job.userId.toString(),
                          //                 userName: job.username,
                          //                 userPicture: job.image != null &&
                          //                         job.image!.isNotEmpty
                          //                     ? (job.image!.startsWith('http')
                          //                         ? job.image!
                          //                         : '${Api().urlImage}${job.image}')
                          //                     : '',
                          //                 productId: job.id.toString(),
                          //                 productImage: '',
                          //                 productPrice:
                          //                     '${job.minPrice} - ${job.maxPrice} TMT',
                          //                 productTitle: job.name,
                          //                 productStatus: job.status.toString(),
                          //                 lastSeen: '',
                          //                 blocked: false,
                          //                 notification: true,
                          //               ),
                          //             );
                          //           }
                          //         },
                          //         icon: const Icon(Icons.chat_bubble,
                          //             color: Colors.white, size: 20),
                          //         label: Text(
                          //           "yazmak".tr,
                          //           style: const TextStyle(
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          //         style: ElevatedButton.styleFrom(
                          //           backgroundColor: ColorConstants.blue,
                          //           padding: const EdgeInsets.symmetric(
                          //               vertical: 12),
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //           elevation: 0,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 16),
                          if (job.selected)
                            if (controller.isCompleteRequestSent.value)
                              const SizedBox.shrink()
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: controller.isCompletingJob.value
                                      ? null
                                      : () async {
                                          final result = await DialogUtils().showCompleteJobDialog(context);
                                          if (result == true) {
                                            controller.markJobDoneByMasterWithRequestId();
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorConstants.kPrimaryColor2,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isCompletingJob.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'complete_job'.tr,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                          if (job.selected) const SizedBox(height: 16),
                        ],
                      );
                    }
                    if (!controller.isLoggedIn.value) {
                      return const SizedBox.shrink();
                    }
                    return // Teklip etmek button
                        SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _checkMasterAndExecute(context, "make_offer".tr, () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const JobRequestBottomSheet(),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.kPrimaryColor2,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                    );
                  }),
                  const SizedBox(height: 20),
                  Obx(() => controller.isLoggedIn.value
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.to(() => const WalletView()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.blue,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Get.to(() => const WalletView()),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(IconConstants.hasabym, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${"wallet".tr}: ${controller.userBalance.value.toStringAsFixed(0)} TMT",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: ColorConstants.kPrimaryColor2,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(IconConstants.arrowOutward, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        "ginis".tr,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
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

  void _checkMasterAndExecute(BuildContext context, String actionTitle, VoidCallback onExecute) {
    if (AuthStorage().masterProfileId == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              actionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(IconConstants.personwork, height: 70),
                const SizedBox(height: 16),
                const Text(
                  'Teklipleri ugratmak we ýumuşlary almak üçin Siz hünärmenlik profiliňizi doldurmaly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ÝAPMAK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.to(() => const SpecialProfileAdd());
                },
                child: const Text('DOLDURMAK', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    } else {
      onExecute();
    }
  }

  Widget _buildOfferSuccessBox({required String price, required String comment}) {
    return Container(
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
              const Icon(Icons.access_time, size: 20, color: ColorConstants.fonts),
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
    );
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
            style: const TextStyle(color: ColorConstants.fonts, fontSize: 13, fontWeight: FontWeight.w500),
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
                                text: isExpanded ? content : "${content.substring(0, tp.getPositionForOffset(Offset(constraints.maxWidth, tp.height)).offset - 12)}...",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: ColorConstants.fonts,
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () => controller.isDescExpanded.toggle(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      isExpanded ? "hide".tr : "show_more".tr,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: ColorConstants.blue,
                                        fontWeight: FontWeight.w400,
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
                          onLongPress: () => _showDownloadOption(context, images[firstIndex]),
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
                                placeholder: (context, url) => _buildImageShimmer(),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
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
                            onLongPress: () => _showDownloadOption(context, images[secondIndex]),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImageGallery(
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
                                  placeholder: (context, url) => _buildImageShimmer(),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
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
                  color: currentPage == index ? ColorConstants.kPrimaryColor2 : Colors.grey[400],
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
      if (answer.formId != null && answer.formId != currentFormId && answer.formName != null) {
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

  Widget? _buildSingleAnswer(JobAnswer answer, JobModel job, BuildContext context) {
    final hasMap = (answer.lat != null && answer.lng != null) || (answer.type == 'map' && answer.value != null && answer.value!.isNotEmpty);
    final content = _getAnswerContent(answer, excludeLocationInfo: hasMap);

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
    final mapPos = controller.parsePosition(answer.value ?? ((answer.lat != null && answer.lng != null) ? "(${answer.lng},${answer.lat})" : ""));

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
        style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.4),
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

  String _getAnswerContent(JobAnswer answer, {bool excludeLocationInfo = false}) {
    final List<String> parts = [];

    // 1. Add Options (Selections)
    if (answer.options != null && answer.options!.isNotEmpty) {
      parts.add(answer.options!.map((o) => o.optionName).join(', '));
    }

    // 2. Add Date and Time
    if (answer.date != null && answer.date!.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(answer.date!);
        String datePart = DateFormat('dd.MM.yyyy').format(dateTime);
        if (answer.time != null && answer.time!.isNotEmpty) {
          datePart += " ${answer.time!.split(':').take(2).join(':')}";
        }
        parts.add(datePart);
      } catch (_) {
        parts.add(answer.date!);
        if (answer.time != null && answer.time!.isNotEmpty) {
          parts.add(answer.time!.split(':').take(2).join(':'));
        }
      }
    } else if (answer.time != null && answer.time!.isNotEmpty) {
      parts.add(answer.time!.split(':').take(2).join(':'));
    }

    if (!excludeLocationInfo) {
      // 3. Add Raw Value
      if (answer.value != null && answer.value!.isNotEmpty && !parts.any((p) => p.contains(answer.value!))) {
        parts.add(answer.value!);
      }
    }

    return parts.join(' / ');
  }

  String _formatDateStatus(BuildContext context, JobModel job) {
    if (job.whenToDo == 'date_today' || job.whenToDo == 'date_tomorrow') {
      if (job.startDate != null && job.startDate!.isNotEmpty) {
        try {
          final taskDate = DateTime.parse(job.startDate!);
          final dateFormat = DateFormat('EEEE, dd MMMM', Localizations.localeOf(context).toString());
          final timeStr = DateFormat('HH:mm').format(taskDate);
          return "${job.whenToDo.tr} (${dateFormat.format(taskDate)}) $timeStr";
        } catch (_) {}
      }
      return job.whenToDo.tr;
    }

    if (job.startDate != null && job.startDate!.isNotEmpty) {
      try {
        final taskDate = DateTime.parse(job.startDate!);
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final dateFormat = DateFormat('EEEE, dd MMMM', Localizations.localeOf(context).toString());

        if (taskDate.year == now.year && taskDate.month == now.month && taskDate.day == now.day) {
          return "${"date_today".tr} (${dateFormat.format(now)}) ${DateFormat('HH:mm').format(taskDate)}";
        }

        if (taskDate.year == tomorrow.year && taskDate.month == tomorrow.month && taskDate.day == tomorrow.day) {
          return "${"date_tomorrow".tr} (${dateFormat.format(tomorrow)}) ${DateFormat('HH:mm').format(taskDate)}";
        }

        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      } catch (_) {}
    }

    if (job.whenToDo == 'urgent' || job.whenToDo.isEmpty) {
      return 'Iň çalt wagtda'.tr;
    }

    if (job.whenToDo == 'special_date') {
      return 'i_will_choose_date'.tr;
    }

    return job.whenToDo.tr;
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null && end == null) return '';
    if (start != null && (end == null || start == end)) {
      try {
        final date = DateTime.parse(start);
        return DateFormat('dd.MM.yyyy HH:mm').format(date);
      } catch (_) {
        return start;
      }
    }
    try {
      final startDate = DateTime.parse(start!);
      final endDate = DateTime.parse(end!);
      final formatter = DateFormat('dd.MM.yyyy');
      if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day) {
        return "${DateFormat('dd.MM.yyyy HH:mm').format(startDate)} - ${DateFormat('HH:mm').format(endDate)}";
      }
      return "${formatter.format(startDate)} - ${formatter.format(endDate)}";
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
            const Icon(Icons.insert_drive_file, size: 32, color: ColorConstants.kPrimaryColor2),
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
                child: Icon(Icons.download_rounded, color: ColorConstants.kPrimaryColor2),
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
                    text: (job.minPrice == 0 && job.maxPrice == 0) ? "not_priced".tr : "${job.minPrice} TMT - ${job.maxPrice} TMT",
                  ),
                  const SizedBox(width: 16),
                  SmallInfo(
                    icon: IconConstants.builder,
                    text: "${job.responsesCount ?? 0}",
                    color: job.requestId != null ? Colors.red : null,
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
                text: "${job.welayat}, ${job.etrap}${job.address.isNotEmpty ? ', ${job.address}' : ''}",
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
    final String text = message ?? (isSuccess ? "${'download'.tr} ${'success_title'.tr}" : "${'error_title'.tr}: ${'download'.tr}");

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
    final isImage = lowerUrl.endsWith('.jpg') || lowerUrl.endsWith('.jpeg') || lowerUrl.endsWith('.png') || lowerUrl.endsWith('.webp') || lowerUrl.endsWith('.gif');

    if (isImage) {
      await _downloadImage(url);
      return;
    }

    try {
      String fileName = Uri.parse(url).pathSegments.isNotEmpty ? Uri.parse(url).pathSegments.last : 'file_${DateTime.now().millisecondsSinceEpoch}';
      if (fileName.trim().isEmpty) {
        fileName = 'file_${DateTime.now().millisecondsSinceEpoch}';
      }
      fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      Directory saveDir;

      if (Platform.isAndroid) {
        final bool granted = await Permission.manageExternalStorage.request().isGranted || await Permission.storage.request().isGranted;

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
    final result = normalized.startsWith('http') ? normalized : "${Api().urlImage}$normalized";
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
