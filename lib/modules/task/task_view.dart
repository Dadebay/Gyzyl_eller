// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card_services.dart';
import 'package:gyzyleller/modules/all/views/pages/all_order_by_sheet.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/job_notification_controller.dart';
import 'package:gyzyleller/modules/task/controllers/task_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TaskController controller = Get.put(TaskController());
  final Set<int> _clearedNotificationJobIds = <int>{};

  void _clearNotificationForOpenedJob(int jobId) {
    if (_clearedNotificationJobIds.contains(jobId)) return;
    if (!Get.isRegistered<JobNotificationController>()) return;

    _clearedNotificationJobIds.add(jobId);
    Get.find<JobNotificationController>().clearByJob(jobId.toString());
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final previousIndex = controller.activeTabIndex.value;
        controller.activeTabIndex.value = _tabController.index;

        // Only refresh if tab actually changed
        if (previousIndex != _tabController.index) {
          _refreshCurrentTabSilently();

          // Clear notifications of the sub-tab the user just left
          if (Get.isRegistered<JobNotificationController>()) {
            final jobNotifController = Get.find<JobNotificationController>();
            jobNotifController.clearTasksTabNotifications(previousIndex);
            jobNotifController.updateTasksTabCount();
          }
        }
      }
    });
  }

  void _refreshCurrentTabSilently() {
    // Trigger pull-to-refresh animation for smooth visual feedback
    if (_tabController.index == 0) {
      controller.requestedRefreshController.requestRefresh();
    } else {
      controller.processingRefreshController.requestRefresh();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: 'Ýumuşlarym'.tr,
        leadingWidth: 110,
        leading: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  builder: (context) {
                    return AllOrderBySheet(
                      groupValue: controller.orderBy.value,
                      onChanged: (value) => controller.changeOrderBy(value),
                    );
                  },
                );
              },
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedSorting05,
                color: ColorConstants.blackColor,
                size: 24.0,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(75),
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(() {
                final reqCount = controller.requestedTotalCount.value;
                final procCount = controller.processingTotalCount.value;

                return TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: ColorConstants.kPrimaryColor2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Gilroy',
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Text(
                        "my_offers_tab"
                            .trParams({"count": reqCount.toString()}),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Get.locale?.languageCode == 'ru' ? 13 : 18,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "my_jobs_tab".trParams({"count": procCount.toString()}),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Get.locale?.languageCode == 'ru' ? 14 : 18,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ),
                  ],
                );
              }),
            )),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          page1(),
          Obx(() {
            if (controller.isProcessingFirstLoad.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.blue,
                  backgroundColor: ColorConstants.background,
                  strokeWidth: 4.0,
                ),
              );
            }

            return SmartRefresher(
              header: const MaterialClassicHeader(
                color: ColorConstants.blue,
                backgroundColor: ColorConstants.background,
              ),
              controller: controller.processingRefreshController,
              enablePullDown: true,
              enablePullUp: controller.hasProcessingMore.value,
              onRefresh: () => controller.fetchProcessingJobs(isRefresh: true),
              onLoading: () => controller.fetchProcessingJobs(),
              child: controller.processingJobs.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedJobSearch,
                            size: 80,
                            color: ColorConstants.greyColor,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "no_tasks_found_is".tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                      itemCount: controller.processingJobs.length,
                      itemBuilder: (context, index) {
                        final job = controller.processingJobs[index];
                        final tag = _TaskProcessingTagResolver().resolve(job);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: JobCard(
                            job: job,
                            isNew: false,
                            showDelete: true,
                            fromTaskView: true,
                            taskTabIndex: 1,
                            hideTag: tag.hideTag,
                            customTagLabel: tag.label,
                            customTagTextColor: tag.textColor,
                            customTagBgColor: tag.bgColor,
                            customTagIcon: tag.icon,
                            onOpened: () =>
                                _clearNotificationForOpenedJob(job.id),
                            onDeleted: () =>
                                controller.fetchProcessingJobs(isRefresh: true),
                          ),
                        );
                      },
                    ),
            );
          }),
        ],
      ),
    );
  }

  Obx page1() {
    return Obx(() {
      if (controller.isRequestedFirstLoad.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorConstants.blue,
            backgroundColor: ColorConstants.background,
            strokeWidth: 4.0,
          ),
        );
      }

      return SmartRefresher(
        header: const MaterialClassicHeader(
          color: ColorConstants.blue,
          backgroundColor: ColorConstants.background,
        ),
        controller: controller.requestedRefreshController,
        enablePullDown: true,
        enablePullUp: controller.hasRequestedMore.value,
        onRefresh: () => controller.fetchRequestedJobs(isRefresh: true),
        onLoading: () => controller.fetchRequestedJobs(),
        child: controller.requestedJobs.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedJobSearch,
                      size: 80,
                      color: ColorConstants.greyColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "no_tasks_found_tek".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                itemCount: controller.requestedJobs.length,
                itemBuilder: (context, index) {
                  final job = controller.requestedJobs[index];
                  final tag = _TaskRequestedTagResolver().resolve(job);
                  final bool canDeleteJob = (job.status != 3 ||
                      job.selectedUserId == null ||
                      job.finished);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: JobCard(
                      job: job,
                      isNew: false,
                      showDelete: (job.status == 5 ||
                              job.status == 4 ||
                              job.finished == true ||
                              job.status == 7)
                          ? true
                          : !canDeleteJob,
                      fromTaskView: true,
                      taskTabIndex: 0,
                      hideTag: tag.hideTag,
                      customTagLabel: tag.label,
                      customTagTextColor: tag.textColor,
                      customTagBgColor: tag.bgColor,
                      customTagIcon: tag.icon,
                      onOpened: () => _clearNotificationForOpenedJob(job.id),
                      onDeleted: () =>
                          controller.fetchRequestedJobs(isRefresh: true),
                    ),
                  );
                },
              ),
      );
    });
  }
}

// ─── Helper types ───────────────────────────────────────────────────────────

class _TaskTagData {
  final bool hideTag;
  final String label;
  final Color textColor;
  final Color bgColor;
  final Widget icon;

  const _TaskTagData({
    this.hideTag = false,
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.icon,
  });
}

class _TaskRequestedTagResolver {
  final AuthStorage _auth = AuthStorage();

  _TaskTagData resolve(JobModel job) {
    // Ýatyrylan
    if (job.status == 5) {
      return _TaskTagData(
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

    // Möhleti tamamlandy
    if (job.status == 7) {
      return _TaskTagData(
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

    // Ýerine ýetirilen
    if (job.status == 4) {
      return _TaskTagData(
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

    // Başga hünärmen saýlandy (status==3 we selected_user_id != mine)
    if (job.status == 3) {
      final user = _auth.getUser();
      final myId = int.tryParse((user?['id'] ?? '').toString());
      final isOtherSelected = myId != null &&
          job.selectedUserId != null &&
          job.selectedUserId != myId;
      if (isOtherSelected) {
        return _TaskTagData(
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
          return _TaskTagData(
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
          return _TaskTagData(
            label: 'task_status_working'.tr,
            textColor: ColorConstants.blackColor,
            bgColor: const Color.fromARGB(255, 120, 229, 118),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedWorkAlert,
              size: 14,
              color: ColorConstants.blackColor,
            ),
          );
        }
      }
    }

    // Finished ýagdaýy (gury finished true bolsa-da)
    if (job.finished == true) {
      return _TaskTagData(
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

    // Teklibiňiz görülen
    if (job.hasSeen) {
      return _TaskTagData(
        label: 'status_viewedd'.tr,
        textColor: const Color(0xFF165500),
        bgColor: const Color.fromARGB(255, 120, 229, 118),
        icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedEye,
            size: 14,
            color: Color(0xFF165500)),
      );
    }

    // Statussyz → tag gösterilmez
    return const _TaskTagData(
      hideTag: true,
      label: '',
      textColor: Colors.transparent,
      bgColor: Colors.transparent,
      icon: SizedBox.shrink(),
    );
  }
}

class _TaskProcessingTagResolver {
  _TaskTagData resolve(JobModel job) {
    // Işleýänim
    if (job.selected == true && job.finished == false) {
      return _TaskTagData(
        label: 'task_status_working'.tr,
        textColor: ColorConstants.blackColor,
        bgColor: const Color.fromARGB(255, 120, 229, 118),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedWorkAlert,
          size: 14,
          color: ColorConstants.blackColor,
        ),
      );
    }

    // Tamamlanan, baha goýulmady
    if (job.status == 3 && job.selected == true && job.finished == true) {
      return _TaskTagData(
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

    // Ýerine ýetirilen
    if (job.status == 4) {
      return _TaskTagData(
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

    // Başga ýagdaý → gizlin
    return const _TaskTagData(
      hideTag: true,
      label: '',
      textColor: Colors.transparent,
      bgColor: Colors.transparent,
      icon: SizedBox.shrink(),
    );
  }
}
