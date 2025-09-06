import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class AuthStorage {
  final GetStorage _storage = GetStorage();

  String? get token => _storage.read<String>('AccessToken');
  String? get refreshToken => _storage.read<String>('RefreshToken');

  void saveToken(String token) => _storage.write('AccessToken', token);
  void saveRefreshToken(String token) => _storage.write('RefreshToken', token);

  void saveUser(Map<String, dynamic> data) {
    _storage.write('UserData', jsonEncode(data));
  }

  Map<String, dynamic>? getUser() {
    final userDataString = _storage.read<String>('UserData');
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  void clear() {
    _storage.remove('AccessToken');
    _storage.remove('RefreshToken');
    _storage.remove('UserData');
  }

  bool get isLoggedIn => token != null;
}
