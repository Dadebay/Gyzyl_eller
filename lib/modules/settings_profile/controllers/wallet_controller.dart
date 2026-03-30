import 'package:get/get.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/settings_profile/views/add_cash_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class WalletController extends GetxController {
  final MyJobsService _jobsService = MyJobsService();

  final RxDouble balance = 0.0.obs;
  final RxList<dynamic> logs = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLogsLoading = false.obs;
  final RxBool isBanksLoading = false.obs;
  final RxList<dynamic> banks = <dynamic>[].obs;
  final TextEditingController amountController = TextEditingController();
  final RxString amountText = "".obs;
  final RxInt sort = 0.obs;

  @override
  void onInit() {
    super.onInit();
    amountController.addListener(() {
      amountText.value = amountController.text;
    });
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.wait([
      fetchBalance(),
      fetchLogs(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchBalance() async {
    try {
      balance.value = await _jobsService.fetchBalance();
    } catch (e) {
      print('Error in WalletController fetchBalance: $e');
    }
  }

  Future<void> fetchLogs() async {
    isLogsLoading.value = true;
    try {
      final fetchedLogs = await _jobsService.fetchPocketLogs(sort: sort.value);
      logs.assignAll(fetchedLogs);
    } catch (e) {
      print('Error in WalletController fetchLogs: $e');
    } finally {
      isLogsLoading.value = false;
    }
  }

  void setSort(int id) {
    sort.value = id;
    fetchLogs();
  }

  Future<void> showWalletInfoAlert(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: ColorConstants.kPrimaryColor,
                      size: 30,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, size: 30),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      '1_token_1_manat'.tr,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'koshelok_info_desc'.tr,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          height: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: ColorConstants.kPrimaryColor),
                      ),
                      backgroundColor: ColorConstants.kPrimaryColor,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.to(() => const AddCashView());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'add_money'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showAddMoneyDialog(BuildContext context) async {
    _fetchBanks();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('select_payment_method'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (isBanksLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final lang = Get.locale?.languageCode ?? 'tk';
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: ListView.builder(
                    itemCount: banks.length,
                    itemBuilder: (context, index) {
                      final bank = banks[index];
                      final String logoUrl =
                          '${Api().urlSimple}${bank['logo'] ?? ''}';

                      return InkWell(
                        onTap: () {
                          _createOrder(bank['id'], ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  logoUrl,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.account_balance,
                                          size: 40),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(bank['name']?[lang]?.toString() ?? ''),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchBanks() async {
    isBanksLoading.value = true;
    try {
      final fetchedBanks = await _jobsService.getBanks();
      print('Fetched banks count: ${fetchedBanks.length}');
      banks.assignAll(fetchedBanks);
    } catch (e) {
      print('Error fetching banks: $e');
    } finally {
      isBanksLoading.value = false;
    }
  }

  Future<void> _createOrder(int bankId, BuildContext dialogContext) async {
    try {
      final response = await _jobsService.createOrder(
        bankId: bankId,
        amount: amountController.text,
      );

      if (response is Map<String, dynamic> && response['formUrl'] != null) {
        final url = Uri.parse(response['formUrl']);
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      print('Error in createOrder: $e');
    }
  }
}
