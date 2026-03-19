import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/filter_view/filter_view.dart';
import 'package:gyzyleller/modules/task/pages/notification_page.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card.dart';
import 'package:gyzyleller/modules/all/views/pages/all_order_by_sheet.dart';
import 'package:gyzyleller/modules/task/controllers/task_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/empty_state_widget.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorConstants.background,
        appBar: CustomAppBar(
          title: 'Ýumuşlarym',
          leadingWidth: 110,
          leading: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(IconConstants.filter),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => FilterBottomSheet(
                      initialCatIds: controller.catIds,
                      initialWelayatIds: controller.welayatIds,
                      initialEtrapIds: controller.etrapIds,
                      initialMinPrice: controller.minPrice.value,
                      initialMaxPrice: controller.maxPrice.value,
                      initialSearch: controller.search.value,
                      initialDates: controller.selectedDates,
                      requestedInput: true,
                      onApply: (filters) {
                        controller.applyFilters(
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
                icon: SvgPicture.asset(IconConstants.sort),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: SvgPicture.asset(IconConstants.notifications),
              onPressed: () {
                Get.to(const NotificationsScreen());
              },
            ),
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(75),
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(() {
                  // Calculate numbers for tabs
                  final reqCount = controller.requestedTotalCount.value;
                  final procCount = controller.processingTotalCount.value;

                  return TabBar(
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
                          "Tekliplerim ($reqCount)",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Işlerim ($procCount)",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              )),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Requested Input
            Obx(() {
              if (controller.isRequestedFirstLoad.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return SmartRefresher(
                header: const MaterialClassicHeader(
                  color: ColorConstants.blue, // Tegelegiň reňki
                  backgroundColor: ColorConstants.background, // Arka fon reňki
                ),
                controller: controller.requestedRefreshController,
                enablePullDown: true,
                enablePullUp: controller.hasRequestedMore.value,
                onRefresh: () => controller.fetchRequestedJobs(isRefresh: true),
                onLoading: () => controller.fetchRequestedJobs(),
                child: controller.requestedJobs.isEmpty
                    ? EmptyStateWidget(
                        title: "no_tasks_found".tr,
                        subtitle: "Gözleýän teklipleriňiz ýok.",
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
            // Tab 2: Processing Input
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
                onRefresh: () =>
                    controller.fetchProcessingJobs(isRefresh: true),
                onLoading: () => controller.fetchProcessingJobs(),
                child: controller.processingJobs.isEmpty
                    ? EmptyStateWidget(
                        title: "no_tasks_found".tr,
                        subtitle: "Gözleýän işleriňiz ýok. ",
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
      ),
    );
  }
}
