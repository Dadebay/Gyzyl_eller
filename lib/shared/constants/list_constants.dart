import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:gyzyleller/shared/constants/icon_constants.dart';

@immutable
class ListConstants {
  static List<String> pageNames = ['all', 'tasks', 'Çatlar', 'Menýu'];
  static List<String> mainIcons = [
    IconConstants.selected2,
    IconConstants.selected3,
    IconConstants.selected1,
    IconConstants.selected4,
  ];
  static List<String> selectedIcons = [
    IconConstants.unselected2,
    IconConstants.unselected3,
    IconConstants.unselected1,
    IconConstants.unselected4,
  ];
}
