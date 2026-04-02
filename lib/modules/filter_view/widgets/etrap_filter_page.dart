import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/filter_view/widgets/filter_checkbox_tile.dart';

class EtrapFilterPage extends StatefulWidget {
  final LocationModel welayat;
  final List<int> selectedEtrapIds;
  final ValueChanged<int> onEtrapChanged;
  final VoidCallback onClear;

  const EtrapFilterPage({
    super.key,
    required this.welayat,
    required this.selectedEtrapIds,
    required this.onEtrapChanged,
    required this.onClear,
  });

  @override
  State<EtrapFilterPage> createState() => _EtrapFilterPageState();
}

class _EtrapFilterPageState extends State<EtrapFilterPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.welayat.etraps
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                "etrap".tr,
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
              final etrap = filtered[i];
              return FilterCheckboxTile(
                title: etrap.name,
                value: widget.selectedEtrapIds.contains(etrap.id),
                onChanged: (_) => widget.onEtrapChanged(etrap.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
