import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'stat_box.dart';

/// Profile header widget for the professional profile view.
/// Displays avatar, stats (total jobs / done jobs), name, short bio,
/// registration date and star rating — matching the ayterek HunarmenScreen design.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String shortBio;
  final num rating;
  final int reviewCount;
  final String createdAt;
  final int doneJobsCount;
  final int totalJobsCount;

  const ProfileHeader({
    super.key,
    required this.name,
    this.imageUrl,
    required this.shortBio,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt = '',
    this.doneJobsCount = 0,
    this.totalJobsCount = 0,
  });

  /// Parses the ISO date string and formats it as dd.MM.yyyy.
  String get _formattedDate {
    if (createdAt.isEmpty) return '';
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(createdAt).toLocal());
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Stats row + avatar ───────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatBox(
              icon: SvgPicture.asset(IconConstants.Isolation_Mode,
                  width: 26, height: 25),
              label: 'created_tasks'.tr,
              value: totalJobsCount.toString(),
            ),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: (imageUrl != null && imageUrl!.startsWith('http'))
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          color: Colors.grey.shade400,
                          size: 60,
                        ),
                      )
                    : Icon(Icons.person, color: Colors.grey.shade400, size: 60),
              ),
            ),
            StatBox(
              icon: SvgPicture.asset(IconConstants.Isolation_Mode2,
                  width: 26, height: 25),
              label: 'completed_jobs'.tr,
              value: doneJobsCount.toString(),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Name ────────────────────────────────────────────────────────
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 3),

        // ── Short bio / speciality ───────────────────────────────────────
        Text(
          shortBio,
          style: const TextStyle(fontSize: 14, color: ColorConstants.fonts),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 5),

        // ── Registration date ────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(IconConstants.calendar),
            const SizedBox(width: 5),
            Text(
              _formattedDate,
              style: const TextStyle(
                  fontSize: 14, color: ColorConstants.blackColor),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Star rating + numeric score ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              5,
              (i) => Icon(
                Icons.star,
                color: i < rating ? Colors.amber : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                  color: ColorConstants.blackColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 3),
            Text(
              '($reviewCount)',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }
}
