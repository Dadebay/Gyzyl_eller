import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class SmallInfo extends StatelessWidget {
  final String icon;
  final String text;

  const SmallInfo({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 16, height: 16, color: ColorConstants.secondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
