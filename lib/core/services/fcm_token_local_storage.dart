import 'package:get_storage/get_storage.dart';

const _fcmTokenKey = 'fcm_token';

class FcmTokenLocalStorage {
  const FcmTokenLocalStorage();

  GetStorage _getStorage() {
    return GetStorage();
  }

  String? getToken() {
    final storage = _getStorage();
    return storage.read<String>(_fcmTokenKey);
  }

  Future<void> setToken(String token) async {
    final storage = _getStorage();
    await storage.write(_fcmTokenKey, token);
  }

  Future<void> clearToken() async {
    final storage = _getStorage();
    await storage.remove(_fcmTokenKey);
  }
}
