// ignore_for_file: deprecated_member_use

import 'package:gyzyleller/shared/constants/icon_constants.dart';

import '../extensions/packages.dart';

class CustomWidgets {
  static Center loader() {
    return const Center(
        child: CircularProgressIndicator(
      color: ColorConstants.kPrimaryColor,
    ));
  }

  static Center errorFetchData() {
    return const Center(child: Text("errorFetchData"));
  }

  static Center emptyData() {
    return const Center(child: Text("emptyData"));
  }

  static Center emptyDataWithLottie(
      {required String title,
      required String subtitle,
      required String lottiePath,
      bool? makeBigger,
      bool? showGif}) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showGif == true
                  ? Image.asset(lottiePath,
                      width: makeBigger == true ? 300 : 150,
                      height: makeBigger == true ? 300 : 150)
                  : Lottie.asset(lottiePath,
                      width: makeBigger == true ? 300 : 150,
                      height: makeBigger == true ? 300 : 150,
                      animate: true),
              const SizedBox(height: 16),
              Text(title.tr,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17, color: ColorConstants.greyColor)),
            ],
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 1),
    );
  }

  Widget drawerButton() {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: const Icon(Icons.menu),
        );
      },
    );
  }

  static ClipRRect imagePlaceHolder() => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(IconConstants.person, fit: BoxFit.cover));
  static Expanded miniCard(
      BuildContext context, String text1, String text2, bool premium) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 5),
          decoration: BoxDecoration(
            color: isDarkMode ? context.blackColor : context.whiteColor,
            gradient: premium
                ? const LinearGradient(
                    colors: [Colors.yellow, Colors.white],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)
                : null,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: ColorConstants.kPrimaryColor.withOpacity(.3)),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? context.whiteColor.withOpacity(.5)
                    : ColorConstants.blackColor.withOpacity(.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          padding: const EdgeInsets.only(top: 8, bottom: 4, left: 6, right: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text1,
                  style: context.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: Text(
                  text2.tr,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.greyColor,
                      fontSize: 13),
                ),
              ),
            ],
          )),
    );
  }

  static showSnackBar(String title, String subtitle, Color color) {
    Get.snackbar(
      title,
      subtitle,
      snackStyle: SnackStyle.FLOATING,
      titleText: title == ''
          ? const SizedBox.shrink()
          : Text(
              title.tr,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
      messageText: Text(
        subtitle.tr,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      borderRadius: 20.0,
      margin: const EdgeInsets.all(8),
      duration: const Duration(milliseconds: 2500),
    );
  }

  static void showErrorDialog(String messageKey) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'error_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              messageKey.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ColorConstants.kPrimaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  'ok'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showErrorMessageDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'error_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ColorConstants.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  'OK'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }
}
