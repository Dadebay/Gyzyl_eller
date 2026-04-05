import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/filter_view/filter_view.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card_services.dart';
import 'package:gyzyleller/modules/all/views/pages/all_order_by_sheet.dart';
import 'package:gyzyleller/modules/task/controllers/task_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/empty_state_widget.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TaskController controller = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.activeTabIndex.value = _tabController.index;
      }
    });
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
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedFilter,
                color: ColorConstants.blackColor,
                size: 24.0,
              ),
              onPressed: () {
                final tabIndex = _tabController.index;
                final isRequested = tabIndex == 0;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FilterBottomSheet(
                    initialCatIds: isRequested
                        ? controller.reqCatIds
                        : controller.procCatIds,
                    initialWelayatIds: isRequested
                        ? controller.reqWelayatIds
                        : controller.procWelayatIds,
                    initialEtrapIds: isRequested
                        ? controller.reqEtrapIds
                        : controller.procEtrapIds,
                    initialMinPrice: isRequested
                        ? controller.reqMinPrice.value
                        : controller.procMinPrice.value,
                    initialMaxPrice: isRequested
                        ? controller.reqMaxPrice.value
                        : controller.procMaxPrice.value,
                    initialSearch: isRequested
                        ? controller.reqSearch.value
                        : controller.procSearch.value,
                    initialDates: isRequested
                        ? controller.reqSelectedDates
                        : controller.procSelectedDates,
                    requestedInput: isRequested,
                    processingInput: !isRequested,
                    onApply: (filters) {
                      controller.applyFilters(
                        tabIndex: tabIndex,
                        newCatIds: filters['catIds'],
                        newWelayatIds: filters['welayatIds'],
                        newEtrapIds: filters['etrapIds'],
                        newMinPrice: filters['minPrice'],
                        newMaxPrice: filters['maxPrice'],
                        newDates: filters['dates'],
                      );
                    },
                  ),
                );
              },
            ),
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
        // actions: [
        //   IconButton(
        //     icon: SvgPicture.asset(IconConstants.notifications),
        //     onPressed: () {
        //       Get.to(const NotificationsScreen());
        //     },
        //   ),
        // ],
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
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Text(
                        "my_offers_tab"
                            .trParams({"count": reqCount.toString()}),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "my_jobs_tab".trParams({"count": procCount.toString()}),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
          Obx(() {
            if (controller.isRequestedFirstLoad.value) {
              return const Center(child: CircularProgressIndicator());
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
                  ? EmptyStateWidget(
                      title: "no_tasks_found".tr,
                      subtitle: "no_offers_subtitle".tr,
                      onActionPressed: () => controller.clearFilters(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: controller.requestedJobs.length,
                      itemBuilder: (context, index) {
                        final job = controller.requestedJobs[index];
                        return JobCard(
                          job: job,
                          isNew: false,
                        );
                      },
                    ),
            );
          }),
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
                  ? EmptyStateWidget(
                      title: "no_tasks_found".tr,
                      subtitle: "no_jobs_subtitle".tr,
                      onActionPressed: () => controller.clearFilters(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: controller.processingJobs.length,
                      itemBuilder: (context, index) {
                        final job = controller.processingJobs[index];
                        return JobCard(
                          job: job,
                          isNew: false,
                        );
                      },
                    ),
            );
          }),
        ],
      ),
    );
  }
}
