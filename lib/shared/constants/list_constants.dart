import 'package:flutter/material.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:hugeicons/hugeicons.dart';

@immutable
class ListConstants {
  static List<String> pageNames = ['all', 'tasks', 'Çatlar', 'menu_tab'.tr];

  // Unselected (stroke) icons
  static List<IconData> mainIcons = [
    HugeIcons.strokeRoundedHome09,
    HugeIcons.strokeRoundedTaskDaily01,
    HugeIcons.strokeRoundedMessage01,
    HugeIcons.strokeRoundedUserCircle,
  ];

  // Selected (solid/filled) icons
  static List<IconData> selectedIcons = [
    HugeIcons.strokeRoundedHome09,
    HugeIcons.strokeRoundedTaskDaily01,
    HugeIcons.strokeRoundedMessage01,
    HugeIcons.strokeRoundedUserCircle,
  ];
}
