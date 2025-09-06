import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool? centerTitle;
  final bool? showElevation;
  final Widget? actionButton;
  final Widget? leadingButton;

  CustomAppBar(
      {required this.title,
      required this.showBackButton,
      this.centerTitle,
      this.showElevation,
      this.leadingButton,
      this.actionButton});
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      //  backgroundColor: ColorConstants.background,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      elevation: showElevation == true ? 1.0 : 0.0,
      shadowColor:
          isDarkMode ? context.blackColor : context.greyColor.withOpacity(.3),
      centerTitle: true,
      backgroundColor: isDarkMode ? context.blackColor : context.background,
      leadingWidth: centerTitle == false ? 10.0 : 80,
      leading: showBackButton
          ? IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: ColorConstants.kPrimaryColor2,
              ),
            )
          : leadingButton ?? const SizedBox.shrink(),
      title: Text(
        title.tr,
        style: context.general.textTheme.headlineMedium!
            .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      actions: [
        actionButton ?? const SizedBox.shrink(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
