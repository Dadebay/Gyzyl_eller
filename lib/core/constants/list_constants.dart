import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gyzyleller/core/constants/icon_constants.dart';

@immutable
class ListConstants {
  static List<String> pageNames = ['home', 'all', 'tasks', 'Menýu'];
  static List<String> mainIcons = [
    IconConstants.selected1,
    IconConstants.selected2,
    IconConstants.selected3,
    IconConstants.selected4,
  ];
  static List<String> selectedIcons = [
    IconConstants.unselected1,
    IconConstants.unselected2,
    IconConstants.unselected3,
    IconConstants.unselected4,
  ];
}
