import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'stat_box.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String shortBio;
  final num rating;
  final int reviewCount;
  final String createdAt;
  final int doneJobsCount;
  final int totalJobsCount;

  final String? experience;

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
    this.experience,
  });

  String get _formattedDate {
    if (createdAt.isEmpty) return '';
    try {
      return DateFormat('dd.MM.yyyy')
          .format(DateTime.parse(createdAt).toLocal());
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: (imageUrl != null && imageUrl!.startsWith('http'))
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildShimmer(),
                        errorWidget: (context, url, error) => const HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          color: ColorConstants.greyColor,
                          size: 60,
                        ),
                      )
                    : const HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: ColorConstants.greyColor,
                        size: 60,
                      ),
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
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          shortBio,
          style: const TextStyle(fontSize: 14, color: ColorConstants.fonts),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar01,
              size: 18,
              color: ColorConstants.kPrimaryColor2,
            ),
            const SizedBox(width: 5),
            Text(
              _formattedDate,
              style: const TextStyle(
                  fontSize: 14, color: ColorConstants.blackColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
        if (experience != null && experience!.isNotEmpty) ...[
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedWorkHistory,
                      color: ColorConstants.blackColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'work_tejribe'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.blackColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Text(
                    experience!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ColorConstants.fonts,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          color: Colors.grey[200]!.withOpacity(value),
        );
      },
      onEnd: () {},
    );
  }
}
