import 'package:get/get.dart';

enum MyTasksOrderBy {
  sene,
  teklip;

  String get displayName {
    switch (this) {
      case MyTasksOrderBy.sene:
        return 'sort_by_date'.tr;
      case MyTasksOrderBy.teklip:
        return 'sort_by_offers'.tr;
    }
  }

  String get apiValue {
    switch (this) {
      case MyTasksOrderBy.sene:
        return 'date';
      case MyTasksOrderBy.teklip:
        return 'responses';
    }
  }
}
