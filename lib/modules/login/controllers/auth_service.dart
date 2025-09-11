import 'package:get/get.dart';
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/login/controllers/auth_controller.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/bottom_nav_bar_view.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';

class AuthService {
  final AuthController authController =
      Get.put<AuthController>(AuthController());

  final AuthStorage _auth = AuthStorage();

  Future<void> login({required String phone, required String password}) async {
    final dynamic responseData = await ApiService().handleApiRequest(
      ApiConstants.loginApi,
      body: <String, dynamic>{'phone': phone, 'password': password},
      method: 'POST',
      requiresToken: false,
      isForm: false,
    );
    if (responseData is Map<String, dynamic>) {
      print("Access Token: ${responseData['access_token']}");
      _auth.saveToken(responseData['access_token'].toString());
      _auth.saveRefreshToken(responseData['refresh_token'].toString());
      if (responseData['data'] is Map<String, dynamic>) {
        _auth.saveUser(responseData['data'] as Map<String, dynamic>);
      }
      CustomWidgets.showSnackBar(
          'loginTitle'.tr, 'loginSubtitle'.tr, ColorConstants.greenColor);
      Get.find<HomeController>().refreshData();
      Get.offAll(() => BottomNavBar());
    }
  }

  Future<void> logout() async {
    _auth.clear();
    CustomWidgets.showSnackBar(
        'logoutTitle'.tr, 'logoutSubtitle'.tr, ColorConstants.greenColor);
    Get.offAll(() => BottomNavBar());
  }
}
