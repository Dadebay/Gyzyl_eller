import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class MainFilterPage extends StatelessWidget {
  final VoidCallback onCategoryTap;
  final String categoryValue;
  final VoidCallback onLocationTap;
  final String locationValue;
  final VoidCallback onPriceTap;
  final String priceValue;
  final VoidCallback? onYearTap;
  final String? selectedYear;

  const MainFilterPage({
    super.key,
    required this.onCategoryTap,
    required this.categoryValue,
    required this.onLocationTap,
    required this.locationValue,
    required this.onPriceTap,
    required this.priceValue,
    this.onYearTap,
    this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildFilterItem(
          svgIcon: IconConstants.categoryFilled,
          title: "category".tr,
          value: categoryValue,
          onTap: onCategoryTap,
        ),
        _buildFilterItem(
          svgIcon: IconConstants.locationHouse,
          title: "location".tr,
          value: locationValue,
          onTap: onLocationTap,
        ),
        _buildFilterItem(
          svgIcon: IconConstants.payment,
          title: "price".tr,
          value: priceValue,
          onTap: onPriceTap,
        ),
        _buildFilterItem(
          svgIcon: IconConstants.calendar,
          title: "job_date_label".tr,
          value: selectedYear != null && selectedYear!.isNotEmpty
              ? selectedYear!
              : "all".tr,
          onTap: onYearTap,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFilterItem({
    required String svgIcon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: ColorConstants.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              svgIcon,
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ColorConstants.blue,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
