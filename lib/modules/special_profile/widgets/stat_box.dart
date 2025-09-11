import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class StatBox extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;

  const StatBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        Text(label,
            style: const TextStyle(color: ColorConstants.fonts, fontSize: 10)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorConstants.fonts,
          ),
        ),
      ],
    );
  }
}
