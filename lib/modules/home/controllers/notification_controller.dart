import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationController extends GetxController {
  final box = GetStorage();
  late final RxInt notificationCount;

  @override
  void onInit() {
    super.onInit();
    final count = box.read<int>('notification_count') ?? 0;
    notificationCount = RxInt(count);
  }

  void increment() {
    notificationCount.value++;
    box.write('notification_count', notificationCount.value);
  }

  void reset() {
    notificationCount.value = 0;
    box.write('notification_count', 0);
  }
}
