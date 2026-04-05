import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';

class WelayatFilterPage extends StatelessWidget {
  final List<LocationModel> locations;
  final List<int> selectedWelayatIds;
  final List<int> selectedEtrapIds;
  final Function(LocationModel) onWelayatSelected;
  final ValueChanged<int> onWelayatCheckChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const WelayatFilterPage({
    super.key,
    required this.locations,
    required this.selectedWelayatIds,
    required this.selectedEtrapIds,
    required this.onWelayatSelected,
    required this.onWelayatCheckChanged,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "location".tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  "clear_all".tr,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorConstants.kPrimaryColor2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: locations.length,
            itemBuilder: (context, i) {
              final location = locations[i];
              final selectedEtrapCount = location.etraps
                  .where((e) => selectedEtrapIds.contains(e.id))
                  .length;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: InkWell(
                  onTap: () => onWelayatSelected(location),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (selectedEtrapCount > 0)
                              Text(
                                "$selectedEtrapCount ${"etrap_selected".tr}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ColorConstants.blue,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: ColorConstants.greyColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
