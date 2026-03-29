// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class InfoRowRed extends StatelessWidget {
  final String icon;
  final String text;
  final String? suffix;

  const InfoRowRed(
      {super.key, required this.icon, required this.text, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(icon,
            width: 16, height: 16, color: ColorConstants.kPrimaryColor2),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
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
