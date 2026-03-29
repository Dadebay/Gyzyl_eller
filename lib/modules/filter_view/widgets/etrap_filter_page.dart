import 'package:flutter/material.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/modules/filter_view/widgets/filter_checkbox_tile.dart';

class EtrapFilterPage extends StatelessWidget {
  final LocationModel welayat;
  final List<int> selectedEtrapIds;
  final ValueChanged<int> onEtrapChanged;

  const EtrapFilterPage({
    super.key,
    required this.welayat,
    required this.selectedEtrapIds,
    required this.onEtrapChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
