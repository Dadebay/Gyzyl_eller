import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class PriceFilterPage extends StatelessWidget {
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const PriceFilterPage({
    super.key,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceChanged,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "price".tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  "clear_all".tr,
                  style: const TextStyle(
                    color: ColorConstants.kPrimaryColor2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _priceBox("from".tr, priceRange.start.toInt()),
              const SizedBox(width: 12),
              _priceBox("to".tr, priceRange.end.toInt()),
            ],
          ),
        ),
        const SizedBox(height: 30),
        RangeSlider(
          values: priceRange,
          min: minPrice,
          max: maxPrice,
          divisions: 100,
          activeColor: ColorConstants.kPrimaryColor2,
          inactiveColor: ColorConstants.background,
          labels: RangeLabels(
            "${priceRange.start.toInt()}",
            "${priceRange.end.toInt()}",
          ),
          onChanged: onPriceChanged,
        ),
      ],
    );
  }

  Widget _priceBox(String title, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ColorConstants.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "$value TMT",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
