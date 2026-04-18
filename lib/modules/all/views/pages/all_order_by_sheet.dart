import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/my_tasks_order_by.dart';

class AllOrderBySheet extends StatelessWidget {
  final MyTasksOrderBy groupValue;
  final ValueChanged<MyTasksOrderBy> onChanged;

  static final List<MyTasksOrderBy> _options = MyTasksOrderBy.values;

  const AllOrderBySheet({
    super.key,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5),
            child: Text(
              'sort'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ..._options.map((e) {
            return Transform.scale(
              scale: 1.1,
              child: RadioListTile<MyTasksOrderBy>(
                value: e,
                groupValue: groupValue,
                activeColor: ColorConstants.kPrimaryColor2,
                title: Text(
                  e.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                    Get.back();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
