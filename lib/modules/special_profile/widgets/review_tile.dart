import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:intl/intl.dart';

/// A single review card displayed in the professional profile review section.
class ReviewTile extends StatelessWidget {
  final ReviewModel review;

  const ReviewTile({super.key, required this.review});

  String get _formattedDate {
    try {
      return DateFormat('dd.MM.yyyy').format(review.createdAt.toLocal());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author row: avatar + name + stars ─────────────────────────
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: (review.image != null && review.image!.isNotEmpty)
                    ? NetworkImage(review.image!) as ImageProvider
                    : null,
                child: (review.image == null || review.image!.isEmpty)
                    ? Icon(Icons.person, color: Colors.grey.shade400, size: 20)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.username,
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 14, color: ColorConstants.fonts),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(Icons.star,
                      color: i < review.rating ? Colors.amber : Colors.grey,
                      size: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Review text ───────────────────────────────────────────────
          Text(
            review.review,
            style: const TextStyle(fontSize: 14, color: ColorConstants.fonts),
          ),

          const SizedBox(height: 4),

          // ── Date ──────────────────────────────────────────────────────
          Text(
            _formattedDate,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),

          // ── Master reply (if any) ─────────────────────────────────────
          if (review.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorConstants.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'master_reply'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ColorConstants.kPrimaryColor2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.replies.first.reply,
                    style: const TextStyle(
                        fontSize: 13, color: ColorConstants.fonts),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer placeholder shown while reviews are loading.
class ReviewTileShimmer extends StatelessWidget {
  const ReviewTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar shimmer
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Name shimmer
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              // Stars shimmer
              Container(
                width: 70,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 180,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

