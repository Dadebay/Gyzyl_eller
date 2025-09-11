// ignore_for_file: inference_failure_on_function_return_type, inference_failure_on_function_invocation, duplicate_ignore, unused_local_variable

import 'dart:io';

import 'package:flutter_svg/svg.dart';
import 'package:gyzyleller/modules/user_profile/controllers/settings_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:kartal/kartal.dart';

import '../extensions/packages.dart';

class DialogUtils {
  static void showNoConnectionDialog(
      {required VoidCallback onRetry, required BuildContext context}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        actionsPadding: EdgeInsets.only(right: 5, bottom: 5),
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
                  style: TextStyle(
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
                        style: TextStyle(
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
                        style: TextStyle(
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
}
