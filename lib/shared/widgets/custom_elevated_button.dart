import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final Widget? child;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final FontWeight? fontWeight;
  final Widget? icon; // New parameter for icon
  final Color? iconColor; // New parameter for icon color

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    this.text,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.padding,
    this.elevation,
    this.fontWeight = FontWeight.w600,
    this.icon,
    this.iconColor,
  }) : assert(text != null || child != null, 'Text or child must be provided'), super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ColorConstants.kPrimaryColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          elevation: elevation,
        ),
        child: icon != null && text != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: iconColor ?? textColor),
                    child: icon!,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text!,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor ?? ColorConstants.whiteColor,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              )
            : child ??
                Text(
                  text!,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor ?? ColorConstants.whiteColor,
                    fontWeight: fontWeight,
                  ),
                ),
      ),
    );
  }
}
