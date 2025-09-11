import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/task/views/pages/build_task_card.dart';
import 'package:gyzyleller/modules/task/views/task_view.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        buildTaskCard(
          date: "27 august 2023, 16:31",
          title: "Aşhanadaky smesitel we turba akýar",
          status: "Hünärmen saýlandy",
          statusColor: ColorConstants.successtatus,
        ),
        buildTaskCard(
          date: "27 august 2023, 16:31",
          title: "Aşhanadaky smesitel we turba akýar",
          status: "Ýumuş ýatyryldy",
          statusColor: ColorConstants.kPrimaryColor2.withOpacity(0.3),
        ),
        buildTaskCard(
          date: "27 august 2023, 16:31",
          title: "Aşhanadaky smesitel we turba akýar",
          status: null,
          statusColor: null,
        ),
      ],
    );
  }
}
