import 'package:get/get.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class WalletController extends GetxController {
  final MyJobsService _jobsService = MyJobsService();

  final RxDouble balance = 0.0.obs;
  final RxList<dynamic> logs = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxList<dynamic> banks = <dynamic>[].obs;
  final TextEditingController amountController = TextEditingController();
  final RxString amountText = "".obs;

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
    try {
      final fetchedLogs = await _jobsService.fetchPocketLogs();
      logs.assignAll(fetchedLogs);
    } catch (e) {
      print('Error in WalletController fetchLogs: $e');
    }
  }

  Future<void> showAddMoneyDialog(BuildContext context) async {
    if (amountController.text.isEmpty) {
      Get.snackbar('error'.tr, 'enter_amount'.tr);
      return;
    }

    print('showAddMoneyDialog called');
    
    // Start fetching in background if not already loading
    if (!isLoading.value) {
      _fetchBanks();
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('select_payment_method'.tr),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              Obx(() {
                if (isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (banks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text('no_payment_methods'.tr, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => _fetchBanks(),
                          child: Text('refresh'.tr),
                        )
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    final String? logoUrl = bank['logo'] != null ? 'http://ayterek.ajayyptilsimatlar.com/${bank['logo']}' : null;
                    
                    return InkWell(
                      onTap: () async {
                        Get.back();
                        await _createOrder(bank['id']);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            if (logoUrl != null)
                              Image.network(
                                logoUrl,
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, size: 40),
                              )
                            else
                              const Icon(Icons.account_balance, size: 40),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                bank['name']?['ru'] ?? bank['name']?['tm'] ?? 'bank'.tr,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchBanks() async {
    isLoading.value = true;
    try {
      final fetchedBanks = await _jobsService.getBanks();
      print('Fetched banks count: ${fetchedBanks.length}');
      banks.assignAll(fetchedBanks);
    } catch (e) {
      print('Error fetching banks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createOrder(int bankId) async {
    try {
      final response = await _jobsService.createOrder(
        bankId: bankId,
        amount: amountController.text,
      );

      if (response != null && response['formUrl'] != null) {
        final url = Uri.parse(response['formUrl']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('error'.tr, 'could_not_launch_payment_url'.tr);
        }
      } else {
        Get.snackbar('error'.tr, 'failed_to_create_order'.tr);
      }
    } catch (e) {
      print('Error in createOrder: $e');
      Get.snackbar('error'.tr, 'error_occurred'.tr);
    }
  }
}
