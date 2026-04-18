import 'package:get/get.dart';

enum MyTasksOrderBy {
  sene,
  nearest,
  price,
  teklip,
  aktiw;

  String get displayName {
    switch (this) {
      case MyTasksOrderBy.sene:
        return 'sort_by_date'.tr;
      case MyTasksOrderBy.nearest:
        return 'nearest'.tr;
      case MyTasksOrderBy.price:
        return 'price_sort'.tr;
      case MyTasksOrderBy.teklip:
        return 'sort_by_offers'.tr;

      case MyTasksOrderBy.aktiw:
        return 'sort_show_active'.tr;
    }
  }

  String get apiValue {
    switch (this) {
      case MyTasksOrderBy.sene:
        return 'created_at';
      case MyTasksOrderBy.teklip:
        return 'request_count';
      case MyTasksOrderBy.nearest:
        return 'near';
      case MyTasksOrderBy.price:
        return 'price';
      case MyTasksOrderBy.aktiw:
        return 'active';
    }
  }

  /// null = no status filter, 1 = active only
  int? get statusFilter {
    switch (this) {
      case MyTasksOrderBy.aktiw:
        return 1;
      default:
        return null;
    }
  }
}
