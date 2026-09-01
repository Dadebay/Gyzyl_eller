import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/filter_view/widgets/filter_checkbox_tile.dart';

class SubcategoryFilterPage extends StatelessWidget {
  final CategoryModel category;
  final List<int> selectedCatIds;
  final ValueChanged<int> onSubcategoryChanged;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;

  const SubcategoryFilterPage({
    super.key,
    required this.category,
    required this.selectedCatIds,
    required this.onSubcategoryChanged,
    required this.onSelectAll,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onSelectAll,
                child: Text(
                  'all_selected'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.blue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'clear_all'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.kPrimaryColor2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: category.subcategories.length,
            itemBuilder: (context, i) {
              final sub = category.subcategories[i];
              return FilterCheckboxTile(
                title: sub.name,
                value: selectedCatIds.contains(sub.id),
                onChanged: (_) => onSubcategoryChanged(sub.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
