import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

import 'review_tile.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.background,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${'reviews_section_title'.tr} 15",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("view_all_button".tr,
                  style: const TextStyle(color: ColorConstants.blue)),
            ],
          ),
          const SizedBox(height: 10),
          const ReviewTile(),
          const SizedBox(height: 8),
          const ReviewTile(),
        ],
      ),
    );
  }
}
