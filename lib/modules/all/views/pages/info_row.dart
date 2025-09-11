import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class InfoRow extends StatelessWidget {
  final String icon;
  final String text;
  final String? suffix;

  const InfoRow({super.key, required this.icon, required this.text, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 16, height: 16, color: ColorConstants.secondary),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          Text(suffix!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorConstants.secondary)),
        ]
      ],
    );
  }
}
