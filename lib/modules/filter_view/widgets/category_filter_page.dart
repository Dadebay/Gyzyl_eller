import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';

class CategoryFilterPage extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<int> selectedCatIds;
  final Function(CategoryModel) onCategorySelected;

  const CategoryFilterPage({
    super.key,
    required this.categories,
    required this.selectedCatIds,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kategoriýa",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                "Arassala",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.kPrimaryColor2),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final item = categories[i];
              final selectedSubCount = item.subcategories
                  .where((sub) => selectedCatIds.contains(sub.id))
                  .length;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: InkWell(
                  onTap: () => onCategorySelected(item),
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
                                "$selectedSubCount bölüm saýlanan",
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
