import 'package:kartal/kartal.dart';

import '../extensions/packages.dart';

class CustomWidgets {
  static Center loader() {
    return Center(child: Lottie.asset(IconConstants.noImage, width: 150, height: 150, animate: true));
  }

  static Center errorFetchData() {
    return Center(child: Text("errorFetchData"));
  }

  static Center emptyData() {
    return Center(child: Text("emptyData"));
  }

  static Center emptyDataWithLottie({required String title, required String subtitle, required String lottiePath, bool? makeBigger, bool? showGif}) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showGif == true
                  ? Image.asset(lottiePath, width: makeBigger == true ? 300 : 150, height: makeBigger == true ? 300 : 150)
                  : Lottie.asset(lottiePath, width: makeBigger == true ? 300 : 150, height: makeBigger == true ? 300 : 150, animate: true),
              SizedBox(height: 16),
              Text(title.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(subtitle.tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: ColorConstants.greyColor)),
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
          icon: Icon(Icons.menu),
        );
      },
    );
  }

  static ClipRRect imagePlaceHolder() => ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(IconConstants.noImage, fit: BoxFit.cover));
  static Expanded miniCard(BuildContext context, String text1, String text2, bool premium) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
          margin: EdgeInsets.only(left: 5, right: 5, top: 5),
          decoration: BoxDecoration(
            color: isDarkMode ? context.blackColor : context.whiteColor,
            gradient: premium ? LinearGradient(colors: [Colors.yellow, Colors.white], begin: Alignment.bottomCenter, end: Alignment.topCenter) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorConstants.kPrimaryColor.withOpacity(.3)),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? context.whiteColor.withOpacity(.5) : ColorConstants.blackColor.withOpacity(.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          padding: EdgeInsets.only(top: 8, bottom: 4, left: 6, right: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text1,
                  style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: Text(
                  text2.tr,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, color: context.greyColor, fontSize: 13),
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
      duration: const Duration(milliseconds: 1000),
      margin: const EdgeInsets.all(8),
    );
  }
}
