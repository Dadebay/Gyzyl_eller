import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gyzyleller/core/services/fcm_token_local_storage.dart';

class FcmTokenProvider {
  FcmTokenProvider();
  
  final _fcmTokenStorage = const FcmTokenLocalStorage();
  final _tokenNotifier = ValueNotifier<String?>(null);
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
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
        print('🔥 [FCM] Saved token in local storage: $savedToken');
        _tokenNotifier.value = savedToken;
      } else {
        print('🔥 [FCM] No token saved in local storage.');
      }
      
      print('🔥 [FCM] Fetching current token from Firebase Messaging...');
      final newToken = await _fcm.getToken();
      if (newToken != null) {
        if (newToken != savedToken) {
          print('🔥 [FCM] NEW/UPDATED TOKEN: $newToken');
          await _fcmTokenStorage.setToken(newToken);
          _tokenNotifier.value = newToken;
        } else {
          print('🔥 [FCM] Token is same as saved: $newToken');
          // If value is same, ValueNotifier doesn't trigger listeners.
          // We can manually trigger it or rely on the initial check in Synchronizer.
        }
      } else {
        print('🔥 [FCM] Firebase Messaging returned NULL token.');
      }
    } catch (e, s) {
      print('❌ [FCM] Error getting token: $e');
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
