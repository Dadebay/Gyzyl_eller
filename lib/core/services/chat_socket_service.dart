// ignore_for_file: unnecessary_import, library_prefixes

import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService extends GetxService {
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;
  bool get isInitialized => _socket != null;

  final _api = Api();
  final _auth = AuthStorage();

  bool get isConnected => isInitialized && _socket!.connected;

  // socket_io_client expects an HTTP(S) base URL; websocket transport
  // is negotiated via options during the Socket.IO handshake.
  String _normalizeSocketBaseUrl(String rawUrl) {
    final uri = Uri.parse(rawUrl.trim());
    if (uri.scheme == 'ws') return uri.replace(scheme: 'http').toString();
    if (uri.scheme == 'wss') return uri.replace(scheme: 'https').toString();
    if (uri.scheme == 'http' || uri.scheme == 'https') return uri.toString();
    return 'https://${rawUrl.trim()}';
  }

  @override
  void onInit() {
    super.onInit();
    _connect();
  }

  void _connect() {
    final token = _auth.token;
    final user = _auth.getUser();
    if (token == null || token.isEmpty || user == null) {
      debugPrint('ℹ️ [ChatSocket] Login ýok, socket birikmesi goýberilýär');
      return;
    }

    final socketBaseUrl = _normalizeSocketBaseUrl(_api.chatWebSocketUrl);
    final baseUri = Uri.parse(socketBaseUrl);
    final bool secure = baseUri.scheme == 'https';
    final int effectivePort =
        baseUri.hasPort ? baseUri.port : (secure ? 443 : 80);
    final String socketUri = baseUri.replace(port: effectivePort).toString();

    debugPrint('🔌 [ChatSocket] Bağlanýar: $socketUri');
    _socket = IO.io(
      socketUri,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io/')
          .setQuery({'access_token': token})
          .enableForceNewConnection()
          .disableAutoConnect()
          .setReconnectionDelay(5000)
          .setReconnectionDelayMax(10000)
          .setRandomizationFactor(0)
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) => debugPrint('✅ [ChatSocket] Bağlandý'));
    _socket!.onDisconnect((r) => debugPrint('❌ [ChatSocket] Kesildi: $r'));
    _socket!.onConnectError(
        (e) => debugPrint('⚠️ [ChatSocket] Birikme ýalňyşy: $e'));
    _socket!.onError((e) => debugPrint('🚨 [ChatSocket] Ýalňyş: $e'));

    _socket!.connect();
  }

  void reconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connect();
  }

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }
}
