import 'package:flutter/foundation.dart';
import 'package:gyzyleller/core/services/call_api.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'fcm_token_provider.dart';

class FcmTokenSynchronizer {
  const FcmTokenSynchronizer(this._fcmTokenProvider);

  final FcmTokenProvider _fcmTokenProvider;

  void init() {
    print('🔄 FcmTokenSynchronizer initializing...');
    _attachFcmTokenUpdateListener();

    // Check current value immediately
    if (_fcmTokenProvider.token.value != null) {
      print('🔄 FcmTokenSynchronizer: Initial token found, syncing...');
      _sendTokenToServer(fcmToken: _fcmTokenProvider.token.value);
    } else {
      print('🔄 FcmTokenSynchronizer: No initial token, waiting for update...');
    }
  }

  void _attachFcmTokenUpdateListener() {
    final tokenNotifier = _fcmTokenProvider.token;
    tokenNotifier.addListener(() {
      print('🔄 FcmTokenSynchronizer: Token changed, syncing...');
      _sendTokenToServer(fcmToken: tokenNotifier.value);
    });
  }

  Future<void> setTokenForUser() async {
    final fcmToken = _fcmTokenProvider.token.value;
    if (fcmToken == null) {
      return;
    }
    await _sendTokenToServer(fcmToken: fcmToken);
  }

  Future<void> _sendTokenToServer({required String? fcmToken}) async {
    if (fcmToken == null) {
      if (kDebugMode) {
        print('--- FCM SYNC START ---');
        print('FCM Token is null, skipping sync.');
      }
      return;
    }

    final userToken = AuthStorage().token;
    if (userToken == null) {
      print('--- FCM SYNC START ---');
      print('User not logged in, skipping FCM token sync.');
      return;
    }

    print('--- FCM SYNC START ---');
    print('📍 ENDPOINT: user/master/fcm-token');
    print('🔑 TOKEN: $fcmToken');

    try {
      // Replicating Ayterek's putToken call
      await CallApi().putToken(
          {'fcm_token': fcmToken}, 'user/master/fcm-token', userToken);
    } catch (e, s) {
      print('❌ [SYNC ERROR] Sending FCM token to server: $e');
      print(s);
    }
  }
}
