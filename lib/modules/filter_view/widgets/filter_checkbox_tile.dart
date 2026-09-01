import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class FilterCheckboxTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const FilterCheckboxTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: value ? ColorConstants.kPrimaryColor2 : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(5),
                color:
                    value ? ColorConstants.kPrimaryColor2 : Colors.transparent,
              ),
              child: value
                  ? const HugeIcon(
                      icon: HugeIcons.strokeRoundedTick02,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
