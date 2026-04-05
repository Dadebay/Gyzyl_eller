import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/wallet_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddCashView extends GetView<WalletController> {
  const AddCashView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: ColorConstants.background,
          bottomNavigationBar: _buildBottomButton(context),
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
                    'toleg'.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ];
            },
            body: SmartRefresher(
              header: const MaterialClassicHeader(
                color: ColorConstants.greyColor,
                backgroundColor: ColorConstants.background,
              ),
              controller: controller.addCashRefreshController,
              enablePullDown: true,
              onRefresh: () => controller.refreshData(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBalanceFrame(context),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'summ_to_send'.tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: ColorConstants.fonts,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: ColorConstants.kPrimaryColor2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 9),
                          TextField(
                            controller: controller.amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: 'how_much'.tr,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'remind_money'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: ColorConstants.fonts,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildBalanceFrame(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorConstants.whiteColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'your_balance'.tr,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.balance.value.toStringAsFixed(0)} ŞAÝ',
                  style: const TextStyle(color: Colors.black, fontSize: 24),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Obx(() {
      final bool isEmpty = controller.amountText.value.isEmpty;
      return Card(
        margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
        elevation: 6,
        child: InkWell(
          onTap: isEmpty ? null : () => controller.showAddMoneyDialog(context),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isEmpty
                  ? ColorConstants.secondary
                  : ColorConstants.kPrimaryColor2,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'continue'.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
