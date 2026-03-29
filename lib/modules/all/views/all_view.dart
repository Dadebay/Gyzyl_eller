import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/modules/all/views/pages/account_summary_bar.dart';
import 'package:gyzyleller/modules/filter_view/filter_view.dart';
import 'package:gyzyleller/modules/all/views/pages/all_order_by_sheet.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card.dart';
import 'package:gyzyleller/modules/all/views/pages/searc_view.dart';

import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/empty_state_widget.dart';
import 'package:gyzyleller/modules/settings_profile/views/wallet_view.dart';

class AllView extends StatelessWidget {
  const AllView({super.key});

  @override
  Widget build(BuildContext context) {
    final AllController controller = Get.put(AllController(), permanent: true);

    // Refresh data in background when entering the tab
    if (!controller.isLoading.value) {
      controller.fetchJobs(isRefresh: true);
    }

    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: 'all_tab'.tr,
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
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedSorting05,
                color: ColorConstants.blackColor,
                size: 24.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: ColorConstants.blackColor,
              size: 24.0,
            ),
            onPressed: () {
              Get.to(() => const AllSearchView());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isFirstLoad.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: ColorConstants.greyColor,
              backgroundColor: ColorConstants.background,
              strokeWidth: 4.0,
            ),
          );
        }

        return SmartRefresher(
          header: const MaterialClassicHeader(
            color: ColorConstants.greyColor,
            backgroundColor: ColorConstants.background,
          ),
          controller: controller.refreshController,
          enablePullDown: true,
          enablePullUp: controller.hasMore.value,
          onRefresh: () => controller.fetchJobs(isRefresh: true),
          onLoading: () => controller.fetchJobs(),
          child: controller.jobs.isEmpty
              ? EmptyStateWidget(
                  title: "no_tasks_found".tr,
                  subtitle: "Gözleýän ýumuşyň tapylmady.",
                  onActionPressed: () => controller.clearFilters(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.jobs.length,
                  itemBuilder: (context, index) {
                    final job = controller.jobs[index];
                    return JobCard(
                      job: job,
                      isNew: index == 0,
                    );
                  },
                ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() => controller.isLoggedIn.value
          ? AccountSummaryBar(
              balanceText:
                  '${"wallet".tr}: ${controller.userBalance.value.toStringAsFixed(0)} TMT',
              onPressed: () => Get.to(() => const WalletView()),
              onBalanceTap: () => Get.to(() => const WalletView()),
            )
          : const SizedBox.shrink()),
    );
  }
}
