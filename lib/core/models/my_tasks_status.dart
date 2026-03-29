import 'package:get/get.dart';

enum MyTasksStatus {
  hemmesi,
  garasylyan,
  aktiw,
  retEdilen,
  hunarmenSaylandy,
  tamamlanan,
  pozulan,
  arhiw,
  mohletiGecen;

  String get displayName {
    switch (this) {
      case MyTasksStatus.hemmesi:
        return 'status_all'.tr;
      case MyTasksStatus.garasylyan:
        return 'status_moderation'.tr;
      case MyTasksStatus.aktiw:
        return 'status_active_card'.tr;
      case MyTasksStatus.retEdilen:
        return 'status_rejected'.tr;
      case MyTasksStatus.hunarmenSaylandy:
        return 'status_worker_selected'.tr;
      case MyTasksStatus.tamamlanan:
        return 'status_completed'.tr;
      case MyTasksStatus.pozulan:
        return 'status_deleted'.tr;
      case MyTasksStatus.arhiw:
        return 'status_archive'.tr;
      case MyTasksStatus.mohletiGecen:
        return 'status_expired'.tr;
    }
  }

  int? get apiValue {
    switch (this) {
      case MyTasksStatus.hemmesi:
        return null;
      case MyTasksStatus.garasylyan:
        return 0;
      case MyTasksStatus.aktiw:
        return 1;
      case MyTasksStatus.retEdilen:
        return 2;
      case MyTasksStatus.hunarmenSaylandy:
        return 3;
      case MyTasksStatus.tamamlanan:
        return 4;
      case MyTasksStatus.pozulan:
        return 5;
      case MyTasksStatus.arhiw:
        return 6;
      case MyTasksStatus.mohletiGecen:
        return 7;
    }
  }

  static MyTasksStatus fromApiValue(int? value) {
    if (value == null) return MyTasksStatus.hemmesi;
    for (var status in MyTasksStatus.values) {
      if (status.apiValue == value) return status;
    }
    return MyTasksStatus.hemmesi;
  }
}
