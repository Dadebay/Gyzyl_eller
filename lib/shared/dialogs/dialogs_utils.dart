// ignore_for_file: inference_failure_on_function_return_type, inference_failure_on_function_invocation, duplicate_ignore, unused_local_variable

import 'dart:io';

import 'package:kartal/kartal.dart';

import '../extensions/packages.dart';

class DialogUtils {
  static void showNoConnectionDialog({required VoidCallback onRetry, required BuildContext context}) {
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
              style: context.general.textTheme.bodyLarge!.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'noConnection2'.tr,
                textAlign: TextAlign.start,
                maxLines: 3,
                style: context.general.textTheme.bodyMedium!.copyWith(fontSize: 14),
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
              style: context.general.textTheme.bodyMedium!.copyWith(fontSize: 13, color: context.greyColor),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'onRetry'.tr,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: context.general.textTheme.bodyMedium!.copyWith(fontSize: 13, color: context.blackColor),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
