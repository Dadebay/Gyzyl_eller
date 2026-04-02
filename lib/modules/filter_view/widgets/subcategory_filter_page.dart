import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/filter_view/widgets/filter_checkbox_tile.dart';

class SubcategoryFilterPage extends StatefulWidget {
  final CategoryModel category;
  final List<int> selectedCatIds;
  final ValueChanged<int> onSubcategoryChanged;
  final VoidCallback onClear;

  const SubcategoryFilterPage({
    super.key,
    required this.category,
    required this.selectedCatIds,
    required this.onSubcategoryChanged,
    required this.onClear,
  });

  @override
  State<SubcategoryFilterPage> createState() => _SubcategoryFilterPageState();
}

class _SubcategoryFilterPageState extends State<SubcategoryFilterPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.category.subcategories
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "subcategory".tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: widget.onClear,
                child: Text(
                  "clear".tr,
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
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final sub = filtered[i];
              return FilterCheckboxTile(
                title: sub.name,
                value: widget.selectedCatIds.contains(sub.id),
                onChanged: (_) => widget.onSubcategoryChanged(sub.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
