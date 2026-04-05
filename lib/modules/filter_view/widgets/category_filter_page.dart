import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';

class CategoryFilterPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'category'.tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              int selectedSubCount = 0;
              selectedSubCount = category.subcategories
                  .where((sub) => selectedCatIds.contains(sub.id))
                  .length;

              return InkWell(
                onTap: () => onCategorySelected(category),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (selectedSubCount > 0)
                        Text(
                          selectedSubCount.toString(),
                          style: const TextStyle(
                            color: ColorConstants.kPrimaryColor2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(width: 8),
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
