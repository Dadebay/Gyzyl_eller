// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/wallet_controller.dart';
import 'package:gyzyleller/modules/settings_profile/views/add_cash_view.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }

    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: ColorConstants.kPrimaryColor2,
              elevation: 4,
              centerTitle: true,
              toolbarHeight: 100,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 45,
                      width: 45,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: ColorConstants.kPrimaryColor2, size: 18),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(
                  height: 20,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: ColorConstants.background,
                    border: Border.all(color: ColorConstants.background),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              title: Text(
                'my_account_title'.tr,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ];
        },
        body: Obx(() {
          if (controller.isLoading.value && controller.logs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            );
          }
          return SmartRefresher(
            header: const MaterialClassicHeader(
              color: ColorConstants.greyColor,
              backgroundColor: ColorConstants.background,
            ),
            controller: controller.walletRefreshController,
            enablePullDown: true,
            onRefresh: () => controller.refreshData(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBalanceFrame(context),
                  const SizedBox(height: 20),
                  _buildTransactionHistory(context),
                  const SizedBox(height: 10),
                  _buildTransactionList(context),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBalanceFrame(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorConstants.whiteColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: ColorConstants.kPrimaryColor2, strokeWidth: 2),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'your_balance'.tr,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.balance.value.toStringAsFixed(0)} ŞAÝ',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ],
                  );
                }),
              ),
              GestureDetector(
                onTap: () {
                  controller.showWalletInfoAlert(context);
                },
                child: Container(
                  height: 48,
                  width: 48,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorConstants.kPrimaryColor2,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child:
                      const Icon(Icons.add, color: ColorConstants.whiteColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Get.to(() => const AddCashView());
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: ColorConstants.kPrimaryColor2,
                side: const BorderSide(color: ColorConstants.kPrimaryColor2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: ColorConstants.whiteColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'add_money'.tr,
                    style: const TextStyle(
                        color: ColorConstants.whiteColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 11),
                child: Text(
                  controller.sort.value == 0
                      ? 'all_payments'.tr
                      : controller.sort.value == 1
                          ? 'money_in'.tr
                          : 'money_out'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.fonts,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _showSortBottomSheet(context, controller.sort.value);
                },
                icon: const Icon(Icons.filter_list,
                    color: ColorConstants.kPrimaryColor2),
              ),
            ],
          ),
        ));
  }

  Widget _buildTransactionList(BuildContext context) {
    return Obx(() {
      if (controller.isLogsLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final logs = controller.logs;
      if (logs.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'no_transactions'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildTransactionItem(
                context, log, index == logs.length - 1);
          },
        ),
      );
    });
  }

  Widget _buildTransactionItem(BuildContext context, dynamic log,
      [bool isLast = false]) {
    final int eventType = int.tryParse(log['event_type'].toString()) ?? 0;
    final summ = log['summ']?.toString() ?? '0';
    final parsedSumm = int.tryParse(summ) ?? 0;
    final isPositive = (eventType == 1 || eventType == 5) && !(0 > parsedSumm);

    String columnText = log['?column?']?.toString() ?? '';

    String title = switch (eventType) {
      1 => 'money_added'.tr,
      2 => 'tarif_bought'.tr,
      3 => 'stories_bought'.tr,
      4 => 'sale_bought'.tr,
      5 => 'refund'.tr,
      6 => 'ad_bought'.tr,
      7 => 'promo_bought'.tr,
      _ => 'unknown_transaction'.tr,
    };

    final iconColor = switch (eventType) {
      1 => ColorConstants.blue,
      2 => ColorConstants.purpleColor,
      3 => Colors.orange,
      4 => Colors.pink,
      5 => ColorConstants.greenColor,
      6 => ColorConstants.kPrimaryColor2,
      7 => ColorConstants.premiumColor,
      _ => Colors.grey,
    };

    String createdAtFormatted = '';
    try {
      DateTime first = DateTime.parse(log['created_at']).toLocal();
      createdAtFormatted = DateFormat('dd.MM.yyyy HH:mm').format(first);
    } catch (_) {}

    final displayTitle = columnText.isNotEmpty ? columnText : title;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: ColorConstants.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset(
                  'assets/icons/toleg.svg',
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.blue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$summ ŞAÝ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.fonts,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      createdAtFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isPositive
                    ? (parsedSumm >= 0 ? 'alyndy'.tr : 'geçdi'.tr)
                    : 'alyndy'.tr,
                style: TextStyle(
                  color: isPositive
                      ? ColorConstants.kPrimaryColor2
                      : ColorConstants.kPrimaryColor2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 12,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  void _showSortBottomSheet(BuildContext context, int sortId) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption(ctx, 'all_payments'.tr, 0, sortId),
              const SizedBox(height: 10),
              _buildSortOption(ctx, 'money_in'.tr, 1, sortId),
              const SizedBox(height: 10),
              _buildSortOption(ctx, 'money_out'.tr, 2, sortId),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
      BuildContext context, String label, int id, int currentSort) {
    return InkWell(
      onTap: () {
        controller.setSort(id);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16)),
          Radio<int>(
            value: id,
            groupValue: currentSort,
            activeColor: ColorConstants.kPrimaryColor2,
            onChanged: (value) {
              if (value != null) {
                controller.setSort(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
