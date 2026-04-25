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
        Center(
          child: SizedBox(
            width: 60,
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: ColorConstants.fonts,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ColorConstants.fonts,
          ),
        ),
      ],
    );
  }
}
