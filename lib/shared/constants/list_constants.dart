import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

@immutable
class ListConstants {
  static const List<String> pageTitleKeys = [
    'all_tab',
    'tasks_tab',
    'chat',
    'menu_tab',
  ];

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
