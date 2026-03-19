import 'package:flutter/material.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/modules/filter_view/widgets/filter_checkbox_tile.dart';

class SubcategoryFilterPage extends StatelessWidget {
  final CategoryModel category;
  final List<int> selectedCatIds;
  final ValueChanged<int> onSubcategoryChanged;

  const SubcategoryFilterPage({
    super.key,
    required this.category,
    required this.selectedCatIds,
    required this.onSubcategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
