import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/filter_view/widgets/filter_checkbox_tile.dart';

class EtrapFilterPage extends StatelessWidget {
  final LocationModel welayat;
  final List<int> selectedEtrapIds;
  final ValueChanged<int> onEtrapChanged;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const EtrapFilterPage({
    super.key,
    required this.welayat,
    required this.selectedEtrapIds,
    required this.onEtrapChanged,
    required this.onSelectAll,
    required this.onClear,
    required this.onApply,
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
            itemCount: welayat.etraps.length,
            itemBuilder: (context, i) {
              final etrap = welayat.etraps[i];
              return FilterCheckboxTile(
                title: etrap.name,
                value: selectedEtrapIds.contains(etrap.id),
                onChanged: (_) => onEtrapChanged(etrap.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
