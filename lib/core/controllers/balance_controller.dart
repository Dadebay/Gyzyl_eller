import 'package:get/get.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';

class BalanceController extends GetxController {
  final MyJobsService _jobsService = MyJobsService();
  final RxDouble balance = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AuthStorage().isLoggedIn) {
      fetchBalance();
    }
  }

  Future<void> fetchBalance() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final newBalance = await _jobsService.fetchBalance();
      balance.value = newBalance;
    } finally {
      isLoading.value = false;
    }
  }

  void updateBalance(double newBalance) {
    balance.value = newBalance;
  }
}
