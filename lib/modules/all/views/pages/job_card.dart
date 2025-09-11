import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/all/views/pages/info_row.dart';
import 'package:gyzyleller/modules/all/views/pages/new_tag.dart';
import 'package:gyzyleller/modules/all/views/pages/small_info.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class JobCard extends StatelessWidget {
  final String date;
  final String title;
  final bool isNew;

  const JobCard({
    super.key,
    required this.date,
    required this.title,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date,
                style:
                    TextStyle(color: ColorConstants.secondary, fontSize: 13)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.fonts)),
            if (isNew) NewTag(),
            const SizedBox(height: 12),
            Divider(height: 2, color: ColorConstants.background),
            const SizedBox(height: 12),
            InfoRow(
                icon: IconConstants.calendar,
                text: "24.05.2023 - 28.05.2023",
                suffix: 'işiň senesi'),
            const SizedBox(height: 6),
            InfoRow(icon: IconConstants.grid, text: "Gurlushyk we abatlayysh"),
            const SizedBox(height: 6),
            InfoRow(
                icon: IconConstants.locationHouse,
                text: "Aşgabat, Mir 7/2, Jaý 9, Otag 32"),
            const SizedBox(height: 6),
            Divider(height: 2, color: ColorConstants.background),
            const SizedBox(height: 6),
            Row(
              children: [
                SmallInfo(
                    icon: IconConstants.payment, text: "750 TMT - 8000 TMT"),
                const SizedBox(width: 16),
                SmallInfo(icon: IconConstants.builder, text: "15"),
                const SizedBox(width: 16),
                SmallInfo(icon: IconConstants.eye, text: "48"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
