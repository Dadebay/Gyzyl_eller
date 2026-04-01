// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/wallet_controller.dart';
import 'package:gyzyleller/modules/settings_profile/views/add_cash_view.dart';
import 'package:intl/intl.dart';

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
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Container(
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
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.refreshData,
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
        color: ColorConstants.kPrimaryColor2,
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
                          color: Colors.white, strokeWidth: 2),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'your_balance'.tr,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.balance.value.toStringAsFixed(0)} ŞAÝ',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.add,
                      color: ColorConstants.kPrimaryColor2),
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
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'add_money'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Text('Yazgy yok'.tr,
                style: const TextStyle(color: Colors.grey)),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _buildTransactionItem(context, log);
        },
      );
    });
  }

  Widget _buildTransactionItem(BuildContext context, dynamic log) {
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
      createdAtFormatted = DateFormat('dd.MM.yyyy, HH:mm').format(first);
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/toleg.svg',
                  width: 24,
                  height: 24,
                  color: iconColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eventType == 2 && columnText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            columnText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        createdAtFormatted,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          isPositive
              ? (0 > parsedSumm)
                  ? Text(
                      '$summ ŞAÝ',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    )
                  : Text(
                      '+$summ ŞAÝ',
                      style: const TextStyle(
                          color: ColorConstants.kPrimaryColor2, fontSize: 14),
                    )
              : Text(
                  '-$summ ŞAÝ',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
        ],
      ),
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
