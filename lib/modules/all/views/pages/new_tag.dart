import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class NewTag extends StatelessWidget {
  const NewTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.kPrimaryColor2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: ColorConstants.kPrimaryColor2, size: 16),
          const SizedBox(width: 4),
          Text('Täze', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ColorConstants.kPrimaryColor2)),
        ],
      ),
    );
  }
}
