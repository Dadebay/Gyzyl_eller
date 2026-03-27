import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gyzyleller/core/services/fcm_token_local_storage.dart';

class FcmTokenProvider {
  FcmTokenProvider();
  
  final _fcmTokenStorage = const FcmTokenLocalStorage();
  final _tokenNotifier = ValueNotifier<String?>(null);
  final _fcm = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenRefreshSubscription;

  ValueNotifier<String?> get token => _tokenNotifier;

  Future<void> init() async {
    print('🔑 FcmTokenProvider initializing...');
    await _getToken();
    _attachTokenRefreshListener();
  }

  Future<void> _getToken() async {
    try {
      final savedToken = _fcmTokenStorage.getToken();
      if (savedToken != null) {
        _tokenNotifier.value = savedToken;
        // Don't return here, we still want to fetch the latest from FCM
      }
      
      final newToken = await _fcm.getToken();
      if (newToken != null && newToken != savedToken) {
        await _fcmTokenStorage.setToken(newToken);
        _tokenNotifier.value = newToken;
      } else if (newToken != null) {
        _tokenNotifier.value = newToken;
      }
    } catch (e, s) {
      print('❌ Error getting FCM token: $e');
      print(s);
    }
  }

  Future<void> removeToken() async {
    await _fcmTokenStorage.clearToken();
    _tokenNotifier.value = null;
  }

  void _attachTokenRefreshListener() {
    _tokenRefreshSubscription = _fcm.onTokenRefresh.listen((newToken) async {
      await _fcmTokenStorage.setToken(newToken);
      _tokenNotifier.value = newToken;
    });
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenNotifier.dispose();
  }
}
