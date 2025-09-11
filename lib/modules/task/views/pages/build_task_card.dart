import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

Widget buildTaskCard({
  required String date,
  required String title,
  String? status,
  Color? statusColor,
}) {
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
              style: TextStyle(color: ColorConstants.secondary, fontSize: 13)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.fonts,
              )),
          if (status != null) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusColor == ColorConstants.successtatus
                        ? Icons.check
                        : Icons.close,
                    color: ColorConstants.fonts,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(status,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.fonts)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(
            height: 2,
            color: ColorConstants.background,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorConstants.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    SvgPicture.asset(
                      IconConstants.calendar,
                    ),
                    SizedBox(width: 4),
                    Text("24.05.2023 - 28.05.2023",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ])),
              SizedBox(
                width: 10,
              ),
              Text("işiň senesi",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(
                  IconConstants.grid,
                ),
                SizedBox(width: 4),
                Text("Gurlushyk we abatlayysh",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(
                  IconConstants.locationHouse,
                ),
                SizedBox(width: 4),
                Text("Aşgabat, Mir 7/2, Jaý 9, Otag 32",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Divider(
            height: 2,
            color: ColorConstants.background,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(IconConstants.payment),
                SizedBox(width: 4),
                Text("750 TMT - 8000 TMT",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(width: 16),
                SvgPicture.asset(IconConstants.builder),
                SizedBox(width: 4),
                Text("15",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(width: 16),
                SvgPicture.asset(
                  IconConstants.eye,
                  height: 16,
                  width: 16,
                  color: ColorConstants.secondary,
                ),
                SizedBox(width: 4),
                Text("48", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
