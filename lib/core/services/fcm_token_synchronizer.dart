import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/services/call_api.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/shared/no_internet_screen.dart';
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
    print('📍 ENDPOINT: api/user/master/fcm-token');
    print('🔑 TOKEN: $fcmToken');

    try {
      await CallApi().postToken(
          {'fcm_token': fcmToken}, 'api/user/master/fcm-token', userToken);
    } on SocketException catch (_) {
      _goNoInternet();
    } on TimeoutException catch (_) {
      _goNoInternet();
    } catch (e, s) {
      // http paketi SocketException-y ClientException höküminde sarlýap ýolladýar
      final msg = e.toString().toLowerCase();
      if (msg.contains('socketexception') ||
          msg.contains('failed host lookup') ||
          msg.contains('no address associated') ||
          msg.contains('connection refused') ||
          msg.contains('network is unreachable')) {
        _goNoInternet();
      } else {
        print('❌ [SYNC ERROR] Sending FCM token to server: $e');
        print(s);
      }
    }
  }

  void _goNoInternet() {
    if (Get.context == null) return;
    // Build phase tamamlanandan soň navigate et
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.offAll(() => const NoInternetScreen());
      }
    });
  }
}
