import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class BioSection extends StatelessWidget {
  final String longBio;
  final String province;

  const BioSection({super.key, required this.longBio, required this.province});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("bio_section_title".tr,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(longBio, style: const TextStyle(color: ColorConstants.fonts)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 16, color: ColorConstants.fonts),
              const SizedBox(width: 4),
              Text("${'location_label'.tr}$province",
                  style: const TextStyle(color: ColorConstants.fonts)),
            ],
          )
        ],
      ),
    );
  }
}
