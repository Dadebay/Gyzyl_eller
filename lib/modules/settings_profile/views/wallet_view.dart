// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/wallet_controller.dart';
import 'package:gyzyleller/modules/settings_profile/views/add_cash_view.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }

    const backgroundColor = Color(0xFFE7EFFF);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(
          title: "Men hasabym".tr,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: ColorConstants.kPrimaryColor2),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 30),
                  _buildRechargeAction(context),
                  const SizedBox(height: 30),
                  _buildHistorySection(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Siziň hasabyňyz:".tr,
            style: const TextStyle(
              fontSize: 16,
              color: ColorConstants.fonts,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${controller.balance.value.toStringAsFixed(0)} ŞAÝ",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: ColorConstants.kPrimaryColor2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => Get.to(() => const AddCashView()),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.kPrimaryColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "Hasabymy doldurmak".tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "History".tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorConstants.fonts,
            ),
          ),
          const SizedBox(height: 20),
          if (controller.logs.isEmpty)
            Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Yazgy yok".tr,
                  style: const TextStyle(color: Colors.grey)),
            ))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.logs.length,
              separatorBuilder: (context, index) => const Divider(height: 30),
              itemBuilder: (context, index) {
                final log = controller.logs[index];
                return _buildHistoryItem(log);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic log) {
    final String amount = "${log['summ']} ŞAÝ";
    final isNegative = double.tryParse(log['summ'].toString()) != null &&
        double.parse(log['summ'].toString()) < 0;

    // Title mapping
    final int eventType = int.tryParse(log['event_type'].toString()) ?? 0;
    String title = log['column'] ?? '';
    if (title.isEmpty) {
      title = switch (eventType) {
        1 => 'money_added'.tr,
        2 => 'tarif_bought'.tr,
        3 => 'stories_bought'.tr,
        4 => 'sale_bought'.tr,
        5 => 'refund'.tr,
        6 => 'ad_bought'.tr,
        7 => 'promo_bought'.tr,
        _ => 'unknown_transaction'.tr,
      };
    } else {
      title = title.tr;
    }

    final String date = _formatDate(log['created_at']);
    final statusText = isNegative ? "alyndy".tr : "gecdi".tr;
    final statusColor = isNegative ? Colors.orange : Colors.blue;
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

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE7EFFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            'assets/icons/toleg.svg',
            color: iconColor,
            width: 24,
            height: 24,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F55BC),
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: ColorConstants.fonts,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 13,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMMM yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
