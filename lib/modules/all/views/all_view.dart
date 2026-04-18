// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/utils/all_view_tag_resolver.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/modules/all/views/pages/account_summary_bar.dart';
import 'package:gyzyleller/modules/filter_view/filter_view.dart';
import 'package:gyzyleller/modules/all/views/pages/all_order_by_sheet.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card_services.dart';
import 'package:gyzyleller/modules/all/views/pages/searc_view.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/modules/settings_profile/views/wallet_view.dart';

class AllView extends StatefulWidget {
  const AllView({super.key});

  @override
  State<AllView> createState() => _AllViewState();
}

class _AllViewState extends State<AllView> {
  final ScrollController _scrollController = ScrollController();
  final AllController controller = Get.put(AllController(), permanent: true);
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (direction == ScrollDirection.forward && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AllViewTagResolver tagResolver = AllViewTagResolver();

    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: 'all_tab'.tr,
        leadingWidth: 110,
        leading: Row(
          children: [
            Obx(() => IconButton(
                  padding: EdgeInsets.zero,
                  icon: Stack(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedFilter,
                        color: ColorConstants.blackColor,
                        size: 24.0,
                      ),
                      if (controller.isAnyFilterActive)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
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
                )),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
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

        return Column(
          children: [
            if (controller.isFetchingLocation.value)
              Container(
                width: double.infinity,
                color: ColorConstants.blue,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'location_loading'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SmartRefresher(
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
                    ? Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
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
                              "no_tasks_found_all".tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "no_results_subtitle_all".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.jobs.length,
                        itemBuilder: (context, index) {
                          final job = controller.jobs[index];
                          final tag = tagResolver.resolve(
                            job,
                            isLoggedIn: controller.isLoggedIn.value,
                          );

                          return JobCard(
                            job: job,
                            isNew: index == 0,
                            fromAllView: true,
                            hideTag: tag.hideTag,
                            customTagLabel: tag.label,
                            customTagTextColor: tag.textColor,
                            customTagBgColor: tag.bgColor,
                            customTagIcon: tag.icon,
                            onOpened: () {
                              tagResolver.markViewed(job.id);
                              controller.jobs.refresh();
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: Obx(() {
            return controller.isLoggedIn.value
                ? AccountSummaryBar(
                    balanceText: '${"wallet".tr}: ${controller.userBalance.value.toStringAsFixed(0)} TMT',
                    onPressed: () => Get.to(() => const WalletView()),
                    onBalanceTap: () => Get.to(() => const WalletView()),
                  )
                : const SizedBox.shrink();
          }),
        ),
      ),
    );
  }
}

class _AllViewTagData {
  final bool hideTag;
  final String label;
  final Color textColor;
  final Color bgColor;
  final Widget icon;

  const _AllViewTagData({
    this.hideTag = false,
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.icon,
  });
}

// Resolver moved to core/utils/all_view_tag_resolver.dart
