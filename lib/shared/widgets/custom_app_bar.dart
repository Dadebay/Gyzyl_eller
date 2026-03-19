import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final double? leadingWidth;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.leadingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConstants.background,
      elevation: 0,
      leading: leading,
      leadingWidth: leadingWidth,
      title: Text(
        title,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}