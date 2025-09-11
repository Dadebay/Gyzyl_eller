import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'stat_box.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String shortBio;

  const ProfileHeader({
    super.key,
    required this.name,
    this.imageUrl,
    required this.shortBio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatBox(
              icon: SvgPicture.asset(IconConstants.Isolation_Mode),
              label: "created_tasks".tr,
              value: "12",
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : const AssetImage("assets/images/profile_avatar.png")
                      as ImageProvider,
            ),
            StatBox(
              icon: SvgPicture.asset(IconConstants.Isolation_Mode2),
              label: "completed_jobs".tr,
              value: "28",
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          shortBio,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(IconConstants.calendar),
            const SizedBox(width: 5),
            Text("24.07.2023", style: TextStyle(color: ColorConstants.fonts)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => Icon(Icons.star,
                color: i < 3 ? Colors.amber : Colors.grey, size: 20),
          ),
        ),
        const Text("(281)", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
