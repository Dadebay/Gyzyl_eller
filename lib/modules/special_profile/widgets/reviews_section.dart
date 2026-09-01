import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'review_tile.dart';

/// Reviews section widget — used as a reusable component.
/// The [reviews] list is passed in from the parent screen.
class ReviewsSection extends StatelessWidget {
  final List<ReviewModel> reviews;
  final int totalCount;
  final VoidCallback? onViewAll;

  const ReviewsSection({
    super.key,
    required this.reviews,
    this.totalCount = 0,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
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
              Text(
                '${'reviews_section_title'.tr} $totalCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'view_all_button'.tr,
                    style: const TextStyle(color: ColorConstants.blue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...reviews.take(2).map((r) => ReviewTile(review: r)),
        ],
      ),
    );
  }
}
