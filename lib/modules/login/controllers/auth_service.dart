import 'package:get/get.dart';
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/services/chat_socket_service.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/bottomnavbar/bindings/home_binding.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/modules/bottomnavbar/views/bottom_nav_bar_view.dart';
import 'package:gyzyleller/modules/login/controllers/auth_controller.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/modules/chats/controllers/notification_controller.dart';
import 'package:gyzyleller/core/services/fcm_token_synchronizer.dart';
import 'package:gyzyleller/core/services/fcm_token_provider.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';

class AuthService {
  final AuthController authController =
      Get.put<AuthController>(AuthController());

  final AuthStorage _auth = AuthStorage();

  Future<void> login({required String phone, required String password}) async {
    try {
      final dynamic responseData = await ApiService().handleApiRequest(
        ApiConstants.loginApi,
        body: <String, dynamic>{'phone': phone, 'password': password},
        method: 'POST',
        requiresToken: false,
        isForm: false,
      );

      // Force delete chat/notif state before switching user
      if (Get.isRegistered<ChatController>()) {
        Get.delete<ChatController>(force: true);
      }
      if (Get.isRegistered<NotificationController>()) {
        Get.delete<NotificationController>(force: true);
      }
      if (Get.isRegistered<ChatSocketService>()) {
        Get.find<ChatSocketService>().reconnect();
      }

      if (responseData is Map<String, dynamic>) {
        _auth.saveToken(responseData['access_token'].toString());
        _auth.saveRefreshToken(responseData['refresh_token'].toString());
        if (responseData['data'] is Map<String, dynamic>) {
          _auth.saveUser(responseData['data'] as Map<String, dynamic>);
        }
        
        // Sync FCM token after login
        if (Get.isRegistered<FcmTokenSynchronizer>()) {
          Get.find<FcmTokenSynchronizer>().setTokenForUser();
        }

        CustomWidgets.showSnackBar('login_success_title'.tr,
            'login_success_subtitle'.tr, ColorConstants.greenColor);
        Get.find<HomeController>().refreshData();
        Get.offAll(() => const BottomNavBar(), binding: HomeBinding());
      } else if (responseData is int) {
        CustomWidgets.showSnackBar(
            'error_title'.tr, 'login_failed'.tr, ColorConstants.redColor);
        throw Exception('Login başarısız oldu');
      } else {
        CustomWidgets.showSnackBar(
            'error_title'.tr, 'unknown_error'.tr, ColorConstants.redColor);
        throw Exception('Bilinmeyen bir hata oluştu');
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
          'error_title'.tr, 'login_error'.tr, ColorConstants.redColor);
      rethrow;
    }
  }

  Future<void> logout() async {
    _auth.clear();
    
    // Remote FCM token on logout
    if (Get.isRegistered<FcmTokenProvider>()) {
      Get.find<FcmTokenProvider>().removeToken();
    }

    // Reset chat/notif state on logout - force delete permanent controllers
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>(force: true);
    }
    if (Get.isRegistered<NotificationController>()) {
      Get.delete<NotificationController>(force: true);
    }
    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().reconnect();
    }

    CustomWidgets.showSnackBar('logout_success_title'.tr,
        'logout_success_subtitle'.tr, ColorConstants.greenColor);
    Get.offAll(() => const BottomNavBar(), binding: HomeBinding());
  }
}
