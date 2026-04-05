import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

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
          iconData: HugeIcons.strokeRoundedGridView,
          title: "category".tr,
          value: categoryValue,
          onTap: onCategoryTap,
        ),
        _buildFilterItem(
          iconData: HugeIcons.strokeRoundedLocation04,
          title: "location".tr,
          value: locationValue,
          onTap: onLocationTap,
        ),
        _buildFilterItem(
          iconData: HugeIcons.strokeRoundedMoney03,
          title: "price".tr,
          value: priceValue,
          onTap: onPriceTap,
        ),
        _buildFilterItem(
          iconData: HugeIcons.strokeRoundedCalendar01,
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
    required IconData iconData,
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
            HugeIcon(
              icon: iconData,
              color: Colors.red,
              size: 26,
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
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: Colors.black,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
