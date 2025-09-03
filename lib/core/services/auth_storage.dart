import 'package:get_storage/get_storage.dart';

class AuthStorage {
  final GetStorage _storage = GetStorage();

  String? get token => _storage.read<String>('AccessToken');
  String? get refreshToken => _storage.read<String>('RefreshToken');

  void saveToken(String token) => _storage.write('AccessToken', token);
  void saveRefreshToken(String token) => _storage.write('RefreshToken', token);

  void clear() {
    _storage.remove('AccessToken');
    _storage.remove('RefreshToken');
  }

  bool get isLoggedIn => token != null;
}
