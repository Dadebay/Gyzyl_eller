
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';

@immutable
class ListConstants {
  static List<String> pageNames = ['all', 'tasks', 'Çatlar', 'menu_tab'.tr];
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
