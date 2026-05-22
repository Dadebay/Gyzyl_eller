// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/job_notification_controller.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/settings_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:kartal/kartal.dart';
import '../extensions/packages.dart';

import 'package:gyzyleller/modules/special_profile/views/special_profile_add.dart';
import 'package:gyzyleller/modules/settings_profile/views/wallet_view.dart';
import 'package:get/get.dart';

class DialogUtils {
  static void showNoConnectionDialog(
      {required VoidCallback onRetry, required BuildContext context}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        actionsPadding: const EdgeInsets.only(right: 5, bottom: 5),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'noConnection1'.tr,
              textAlign: TextAlign.start,
              maxLines: 1,
              style: context.general.textTheme.bodyLarge!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'noConnection2'.tr,
                textAlign: TextAlign.start,
                maxLines: 3,
                style: context.general.textTheme.bodyMedium!
                    .copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              exit(0);
            },
            child: Text(
              'onRetryCancel'.tr,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: context.general.textTheme.bodyMedium!
                  .copyWith(fontSize: 13, color: context.greyColor),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'onRetry'.tr,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: context.general.textTheme.bodyMedium!
                  .copyWith(fontSize: 13, color: context.blackColor),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  final SettingsController controller = Get.put(SettingsController());
  Future<bool?> showDeleteProfileDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          backgroundColor: ColorConstants.background,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'deleteProfileTitle'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  IconConstants.pupup,
                ),
                const SizedBox(height: 10),
                Text(
                  'deleteProfileDescription'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.fonts,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop(true);
                        await controller.logout();
                      },
                      child: Text(
                        'delete'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.kPrimaryColor2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return null;
  }

  Future<bool?> showDeleteJobDialog(BuildContext context, int jobId,
      {bool isRequest = false}) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'deleteJobTitle'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  IconConstants.trash,
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  'deleteJobDescription'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.fonts,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        print(
                            '\x1B[34m[DELETE] ▶ jobId=$jobId | isRequest=$isRequest\x1B[0m');
                        try {
                          final MyJobsService jobsService = MyJobsService();
                          if (isRequest) {
                            print(
                                '\x1B[36m[DELETE] calling deleteJobRequest($jobId)...\x1B[0m');
                            await jobsService.deleteJobRequest(jobId);
                          } else {
                            print(
                                '\x1B[36m[DELETE] calling deleteJob($jobId)...\x1B[0m');
                            await jobsService.deleteJob(jobId);
                          }
                          // Clear all notifications for this job from the badge counter
                          if (Get.isRegistered<JobNotificationController>()) {
                            await Get.find<JobNotificationController>()
                                .clearNotificationsByJob(jobId.toString());
                          }
                          print(
                              '\x1B[32m[DELETE] ✅ Success — popping true\x1B[0m');
                          Navigator.of(dialogContext).pop(true);
                        } catch (e) {
                          print('\x1B[31m[DELETE] ❌ Error: $e\x1B[0m');
                          Navigator.of(dialogContext).pop(false);
                          Get.snackbar('Error', 'Failed to delete job: $e');
                        }
                      },
                      child: Text(
                        'delete'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.kPrimaryColor2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> showCompleteJobDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'complete_job_dialog_title'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  IconConstants.succes,
                  width: 90,
                  height: 90,
                ),
                const SizedBox(height: 10),
                Text(
                  'complete_job_dialog_message'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Text(
                        'no'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      child: Text(
                        'yes'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.kPrimaryColor2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showFillProfileDialog(
      BuildContext context, String actionTitle) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  IconConstants.personwork,
                  height: 70,
                ),
                const SizedBox(height: 16),
                Text(
                  'fill_profile_prompt'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'close_button'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.fonts,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Get.to(() => const SpecialProfileAdd());
                      },
                      child: Text(
                        'fill_button'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.kPrimaryColor2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'insufficient_balance_title'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  'assets/icons/pul.svg',
                  height: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  'insufficient_balance_prompt'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(
                            color: ColorConstants.kPrimaryColor2,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'insufficient_balance_close'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.kPrimaryColor2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Get.to(() => const WalletView());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.kPrimaryColor2,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'insufficient_balance_fill'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showInsufficientOfferBalanceDialog(
    BuildContext context, {
    required double requiredFee,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'insufficient_balance_title'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  'assets/icons/pul.svg',
                  height: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  'offer_confirm_text'
                      .trParams({'fee': requiredFee.toStringAsFixed(0)}),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(
                            color: ColorConstants.kPrimaryColor2,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'cancel_offer'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.kPrimaryColor2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (onOk != null) {
                            Future.microtask(onOk);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.kPrimaryColor2,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'ok'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
