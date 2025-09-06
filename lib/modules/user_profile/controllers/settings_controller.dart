import 'package:get/get.dart';
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/modules/login/controllers/auth_service.dart';

class SettingsController extends GetxController {
  final AuthStorage _authStorage = AuthStorage();
  final AuthService _authService = AuthService();

  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    user.value = _authStorage.getUser();
  }

  String get username => user.value?['username'] ?? 'adyňyz';
  String get phone => user.value?['phone'] ?? '';
  String? get imageUrl {
    if (user.value != null && user.value!['image'] != null) {
      return ApiConstants.imageURL + user.value!['image'];
    }
    return null;
  }

  bool get isLoggedIn => _authStorage.isLoggedIn;

  Future<void> logout() async {
    await _authService.logout();
    loadUser(); // Refresh user state
  }
}
