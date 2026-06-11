// ignore_for_file: deprecated_member_use, unused_element
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/utils/all_view_tag_resolver.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/modules/all/views/pages/account_summary_bar.dart';
import 'package:gyzyleller/modules/filter_view/filter_view.dart';
import 'package:gyzyleller/modules/all/views/pages/all_order_by_sheet.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card_services.dart';
import 'package:gyzyleller/modules/all/views/pages/searc_view.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/job_notification_controller.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/modules/settings_profile/views/wallet_view.dart';

class AllView extends StatefulWidget {
  const AllView({super.key});

  @override
  State<AllView> createState() => _AllViewState();
}

class _AllViewState extends State<AllView> {
  final ScrollController _scrollController = ScrollController();
  late final AllController controller;
  bool _isFabVisible = true;
  final GlobalKey _filterKey = GlobalKey();
  final Set<int> _clearedNotificationJobIds = <int>{};

  @override
  void initState() {
    super.initState();
    // Get existing controller or create new one
    if (Get.isRegistered<AllController>()) {
      controller = Get.find<AllController>();
      // Reset the RefreshController so the new SmartRefresher can bind cleanly.
      // Without this, the old _refresherState reference causes an assertion error.
      controller.resetRefreshController();
    } else {
      controller = Get.put(AllController(), permanent: true);
    }
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

  Future<void> _clearNotificationForOpenedJob(int jobId) async {
    if (_clearedNotificationJobIds.contains(jobId)) return;
    if (!Get.isRegistered<JobNotificationController>()) return;

    _clearedNotificationJobIds.add(jobId);
    final success = await Get.find<JobNotificationController>()
        .clearByJob(jobId.toString());

    // If API clear was successful, immediately update the badge count
    if (success) {
      Get.find<JobNotificationController>().updateAllTabCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AllViewTagResolver tagResolver = AllViewTagResolver();

    return ShowCaseWidget(builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.shouldShowFilterShowcase.value) {
          ShowCaseWidget.of(context).startShowCase([_filterKey]);
          controller.shouldShowFilterShowcase.value = false;
        }
      });
      return Scaffold(
        backgroundColor: ColorConstants.background,
        appBar: CustomAppBar(
          title: 'all_tab'.tr,
          leadingWidth: 110,
          leading: Row(
            children: [
              Obx(
                () => Showcase(
                    key: _filterKey,
                    description: 'filter_showcase_text'.tr,
                    descTextStyle: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                    disposeOnTap: false,
                    showArrow: false,
                    disableBarrierInteraction: true,
                    onTargetClick: () {
                      ShowCaseWidget.of(context).dismiss();
                      _openFilterBottomSheet(context);
                    },
                    onToolTipClick: () {},
                    child: IconButton(
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
                                  border:
                                      Border.all(color: Colors.white, width: 1),
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
                        _openFilterBottomSheet(context);
                      },
                    )),
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

          return Column(
            children: [
              if (controller.isFetchingLocation.value)
                Container(
                  width: double.infinity,
                  color: ColorConstants.blue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  key: const PageStorageKey('all_view_refresher'),
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
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 20),
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
                              showDelete: false,
                              isNew: index == 0,
                              fromAllView: true,
                              hideTag: tag.hideTag,
                              customTagLabel: tag.label,
                              customTagTextColor: tag.textColor,
                              customTagBgColor: tag.bgColor,
                              customTagIcon: tag.icon,
                              onOpened: () async {
                                tagResolver.markViewed(job.id);
                                controller.jobs.refresh();
                                await _clearNotificationForOpenedJob(job.id);
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
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: AccountSummaryBar(
                        balanceText:
                            '${"wallet".tr}: ${controller.userBalance.value.toStringAsFixed(0)} TMT',
                        onPressed: () => Get.to(() => const WalletView()),
                        onBalanceTap: () => Get.to(() => const WalletView()),
                      ),
                    )
                  : const SizedBox.shrink();
            }),
          ),
        ),
      );
    });
  }

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initialCatIds: controller.catIds,
        initialWelayatIds: controller.welayatIds,
        initialEtrapIds: controller.etrapIds,
        initialDates: controller.selectedDates.isEmpty
            ? null
            : controller.selectedDates.toList(),
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
            newSearch: filters['search'],
          );
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
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
