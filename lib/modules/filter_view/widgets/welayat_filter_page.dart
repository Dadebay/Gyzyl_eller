import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';

class WelayatFilterPage extends StatefulWidget {
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
  State<WelayatFilterPage> createState() => _WelayatFilterPageState();
}

class _WelayatFilterPageState extends State<WelayatFilterPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.locations
        .where(
          (l) =>
              query.isEmpty ||
              l.name.toLowerCase().contains(query) ||
              l.etraps.any(
                (e) => e.name.toLowerCase().contains(query),
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
                "location".tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: widget.onClear,
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
          child: filtered.isEmpty
              ? Center(child: Text('no_data_found'.tr))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final location = filtered[i];
                    final isWelayatSelected =
                        widget.selectedWelayatIds.contains(location.id);
                    final selectedEtrapCount = location.etraps
                        .where((e) => widget.selectedEtrapIds.contains(e.id))
                        .length;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: InkWell(
                        onTap: () => widget.onWelayatSelected(location),
                        child: Row(
                          children: [
                            // Custom checkbox
                            GestureDetector(
                              onTap: () =>
                                  widget.onWelayatCheckChanged(location.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isWelayatSelected
                                        ? Colors.red
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  color: isWelayatSelected
                                      ? Colors.red
                                      : Colors.transparent,
                                ),
                                child: isWelayatSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Name + sub-count
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
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: ColorConstants.greyColor,
                              size: 18,
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
