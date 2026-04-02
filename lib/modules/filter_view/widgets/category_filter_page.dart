import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';

class CategoryFilterPage extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<int> selectedCatIds;
  final Function(CategoryModel) onCategorySelected;
  final VoidCallback onClear;

  const CategoryFilterPage({
    super.key,
    required this.categories,
    required this.selectedCatIds,
    required this.onCategorySelected,
    required this.onClear,
  });

  @override
  State<CategoryFilterPage> createState() => _CategoryFilterPageState();
}

class _CategoryFilterPageState extends State<CategoryFilterPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.categories
        .where(
          (c) =>
              query.isEmpty ||
              c.name.toLowerCase().contains(query) ||
              c.subcategories.any(
                (sub) => sub.name.toLowerCase().contains(query),
              ),
        )
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "category".tr,
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
                      color: ColorConstants.kPrimaryColor2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('no_data_found'.tr))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    final selectedSubCount = item.subcategories
                        .where((sub) => widget.selectedCatIds.contains(sub.id))
                        .length;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: InkWell(
                        onTap: () => widget.onCategorySelected(item),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (selectedSubCount > 0)
                                    Text(
                                      "subcategory_selected_count".trParams({
                                        'count': selectedSubCount.toString()
                                      }),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: ColorConstants.blue,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: ColorConstants.greyColor, size: 18),
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
