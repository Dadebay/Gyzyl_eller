// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class InfoRow extends StatelessWidget {
  final String icon;
  final String text;
  final String? suffix;

  const InfoRow(
      {super.key, required this.icon, required this.text, this.suffix});

  @override
  Widget build(BuildContext context) {
    final bool isCalendar = icon.contains('calendar');
    final Color iconColor = isCalendar ? ColorConstants.kPrimaryColor2 : ColorConstants.secondary;

    Widget coreContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(icon,
            width: 16, height: 16, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );

    if (isCalendar) {
      coreContent = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: BoxDecoration(
          color: ColorConstants.whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: coreContent,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: coreContent),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          Text(suffix!,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.secondary)),
        ]
      ],
    );
  }
}
