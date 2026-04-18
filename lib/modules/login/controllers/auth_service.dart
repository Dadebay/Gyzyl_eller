import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/services/api.dart';
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
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/shared/widgets/widgets.dart';

class AuthService {
  final AuthController authController = Get.put<AuthController>(AuthController());

  final AuthStorage _auth = AuthStorage();

  Future<void> login({required String phone, required String password}) async {
    try {
      final lang = GetStorage().read('langCode') ?? 'tk';
      final url = Uri.parse('${Api().urlLink}api/user/$lang/login');
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final statusCode = response.statusCode;
      final body = utf8.decode(response.bodyBytes);
      print('🌐 LOGIN STATUS: $statusCode');
      print('🌐 LOGIN BODY: $body');

      if (statusCode >= 200 && statusCode < 300) {
        final responseData = jsonDecode(body) as Map<String, dynamic>;

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

        _auth.saveToken(responseData['access_token'].toString());
        _auth.saveRefreshToken(responseData['refresh_token'].toString());
        if (responseData['data'] is Map<String, dynamic>) {
          _auth.saveUser(responseData['data'] as Map<String, dynamic>);
        }
        GetStorage().write('all_view_login_at', DateTime.now().toUtc().toIso8601String());

        _fetchAndSaveMasterProfileId();

        if (Get.isRegistered<FcmTokenSynchronizer>()) {
          Get.find<FcmTokenSynchronizer>().setTokenForUser();
        }

        // Update AllController isLoggedIn reactively after login
        if (Get.isRegistered<AllController>()) {
          Get.find<AllController>().isLoggedIn.value = true;
        }

        CustomWidgets.showSnackBar('login_success_title'.tr, 'login_success_subtitle'.tr, ColorConstants.greenColor);
        Get.find<HomeController>().refreshData();
        Get.offAll(() => const BottomNavBar(), binding: HomeBinding());
      } else {
        // Extract backend error message and show it directly
        String errorMsg = 'login_failed'.tr;
        try {
          final errorJson = jsonDecode(body);
          if (errorJson is Map<String, dynamic>) {
            final errorField = errorJson['error'];
            if (errorField is Map<String, dynamic> && errorField.isNotEmpty) {
              errorMsg = errorField.values.first?.toString() ?? errorMsg;
            } else if (errorField is String && errorField.isNotEmpty) {
              errorMsg = errorField;
            } else if (errorJson['message'] is String) {
              errorMsg = errorJson['message'] as String;
            }
          }
        } catch (_) {}

        CustomWidgets.showErrorMessageDialog(errorMsg);
      }
    } on SocketException {
      if (!(Get.isDialogOpen ?? false)) {
        CustomWidgets.showErrorDialog('login_error');
      }
    } catch (e) {
      print('🔴 LOGIN CATCH: $e');
      if (!(Get.isDialogOpen ?? false)) {
        CustomWidgets.showErrorDialog('login_error');
      }
    }
  }

  Future<void> logout() async {
    GetStorage().remove('all_view_login_at');
    GetStorage().remove('all_view_seen_jobs');
    _auth.clear();

    // Update AllController isLoggedIn reactively so AccountSummaryBar hides immediately
    if (Get.isRegistered<AllController>()) {
      Get.find<AllController>().isLoggedIn.value = false;
    }

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

    CustomWidgets.showSnackBar('logout_success_title'.tr, 'logout_success_subtitle'.tr, ColorConstants.greenColor);
    Get.offAll(() => const BottomNavBar(), binding: HomeBinding());
  }

  /// Fetches master profile after login and saves the ID locally.
  Future<void> _fetchAndSaveMasterProfileId() async {
    try {
      final response = await ApiService().getRequest(ApiConstants.specialProfile);
      if (response != null && response['data'] != null && response['data']['id'] != null) {
        _auth.saveMasterProfileId(response['data']['id'].toString());
      }
    } catch (e) {
      print('Error fetching master profile id: $e');
    }
  }
}
