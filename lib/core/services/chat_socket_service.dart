import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService extends GetxService {
  IO.Socket? _socket;
  IO.Socket get socket => _socket!;
  bool get isInitialized => _socket != null;

  final _api = Api();
  final _auth = AuthStorage();

  bool get isConnected => isInitialized && _socket!.connected;

  @override
  void onInit() {
    super.onInit();
    _connect();
  }

  void _connect() {
    final token = _auth.token;
    if (token == null) {
      return;
    }

    debugPrint('🔌 [ChatSocket] Bağlanýar: ${_api.chatWebSocketUrl}');
    _socket = IO.io(
      _api.chatWebSocketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
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

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }
}
