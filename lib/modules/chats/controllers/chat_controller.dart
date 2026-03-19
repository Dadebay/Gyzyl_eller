// ignore_for_file: avoid_print

import 'package:gyzyleller/core/models/chat_model.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/chat_socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../core/services/api.dart';

class ChatController extends GetxController {
  final _auth = AuthStorage();
  final _api = Api();

  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxBool isLoadingChats = false.obs;
  final RxBool hasError = false.obs;
  final RxInt unreadCount = 0.obs;
  final RxInt notifCount = 0.obs;
  final RxList<dynamic> onlineUsers = <dynamic>[].obs;
  final RxSet<String> selectedChatIds = <String>{}.obs;
  final RxBool isSelectionMode = false.obs;

  // Sorting: 0=All, 1=Buy, 2=Sell, 3=Blocked
  final RxInt currentSort = 0.obs;
  // SortDate: 0=Last Message, 1=Unread
  final RxInt sortDate = 0.obs;

  Timer? _pollingTimer;

  String get token => _auth.token ?? '';
  String get currentUserId {
    final user = _auth.getUser();
    return user?['id']?.toString() ?? '';
  }

  IO.Socket get _socket => Get.find<ChatSocketService>().socket;
  bool get _socketConnected => Get.find<ChatSocketService>().isConnected;

  @override
  void onInit() {
    super.onInit();
    _initSocketListeners();
    fetchChats();
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }

  // ─── Socket listeners ───
  void _initSocketListeners() {
    if (!Get.find<ChatSocketService>().isInitialized) return;
    _socket.on('last_sended_message', (_) => fetchChats());
    _socket.on('chat_created', (_) => fetchChats());
    _socket.on('new_message', (_) => fetchChats());
    _socket.on('user_connected', (_) => _getData());
    _socket.on('user_disconnected', (_) => _getData());
  }

  void _getData() {
    if (!_socketConnected) return;
    final lang = Get.find<GetStorage>().read('langCode') ?? 'tk';
    _socket.emitWithAck('get_data', {'lang': lang}, ack: (data) {
      if (data['status'] == 200) {
        onlineUsers.value = data['online_users'] ?? [];
      }
    });
  }

  // ─── Polling fallback ───
  void _startPolling() {
    if (_pollingTimer != null) return;
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_socketConnected) _fetchChatsHttp();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ─── Main fetch: socket first, HTTP fallback ───
  Future<void> fetchChats() async {
    if (_socketConnected) {
      _fetchChatsSocket();
      _getData();
    } else {
      await _fetchChatsHttp();
      _startPolling();
    }
  }

  void setSort(int sort) {
    currentSort.value = sort;
    fetchChats();
  }

  void setSortDate(int sort) {
    sortDate.value = sort;
    fetchChats();
  }

  void _fetchChatsSocket() {
    isLoadingChats.value = true;
    bool responded = false;
    final lang = Get.find<GetStorage>().read('langCode') ?? 'tk';

    // 1-second fallback if socket doesn't respond
    Timer(const Duration(seconds: 1), () {
      if (!responded) {
        responded = true;
        _fetchChatsHttp();
        _startPolling();
      }
    });

    _socket.emitWithAck('get_chats', {
      'all': currentSort.value == 0,
      'buy': currentSort.value == 1,
      'sell': currentSort.value == 2,
      'blocked': currentSort.value == 3,
      'column': sortDate.value == 0 ? 'last_sended_message' : 'unread_count',
      'lang': lang,
      'direction': 'DESC',
      'type': 'gyzyl',
    }, ack: (data) {
      if (responded) return;
      responded = true;
      try {
        if (data['status'] == 200) {
          final List<dynamic> chatList = data['chats'] ?? [];
          final Map<String, dynamic> products =
              (data['products'] as Map?)?.cast<String, dynamic>() ??
                  (data['jobs'] as Map?)?.cast<String, dynamic>() ??
                  {};
          final Map<String, dynamic> users =
              (data['users'] as Map?)?.cast<String, dynamic>() ?? {};
          chats.value = chatList
              .map((e) => ChatModel.fromApiData(
                    e as Map<String, dynamic>,
                    products,
                    users,
                  ))
              .toList();
          _computeUnread();
          hasError.value = false;
          debugPrint(
              '✅ [ChatController] Socket: ${chats.length} chat ýüklendi');
        }
      } catch (e) {
        debugPrint('⚠️ [ChatController] Socket ack parse ýalňyşy: $e');
        _fetchChatsHttp();
      } finally {
        isLoadingChats.value = false;
      }
    });

    // Also get general unread status
    _socket.emitWithAck('get_data', {'lang': lang}, ack: (data) {
      if (data['status'] == 200) {
        unreadCount.value =
            int.tryParse(data['messages']?.toString() ?? '0') ?? 0;
      }
    });
  }

  Future<void> _fetchChatsHttp() async {
    isLoadingChats.value = true;
    hasError.value = false;
    try {
      final response = await http.get(
        Uri.parse('${_api.urlLink}api/user/chats').replace(
          queryParameters: {'type': 'gyzyl'},
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> chatList = data['chats'] ?? [];
        final Map<String, dynamic> products =
            (data['products'] as Map?)?.cast<String, dynamic>() ??
                (data['jobs'] as Map?)?.cast<String, dynamic>() ??
                {};
        final Map<String, dynamic> users =
            (data['users'] as Map?)?.cast<String, dynamic>() ?? {};

        chats.value = chatList
            .map((e) => ChatModel.fromApiData(
                  e as Map<String, dynamic>,
                  products,
                  users,
                ))
            .toList();
        _computeUnread();
        debugPrint('✅ [ChatController] HTTP: ${chats.length} chat ýüklendi');
      } else {
        hasError.value = true;
        debugPrint('[ChatController] fetchChats error: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      debugPrint('[ChatController] fetchChats exception: $e');
    } finally {
      isLoadingChats.value = false;
    }
  }

  void _computeUnread() {
    int total = 0;
    for (final c in chats) {
      total += c.unreadCount;
    }
    unreadCount.value = total;
  }

  bool isUserOnline(String userId) {
    return onlineUsers.any((u) => u.toString() == userId);
  }

  void blockUser(String chatId) {
    if (_socketConnected) {
      _socket.emitWithAck('block_chat', {'chat_id': chatId}, ack: (_) {});
    }
  }

  void unBlockUser(String userId) {
    if (_socketConnected) {
      _socket.emitWithAck('unblock_user', {'user_id': userId}, ack: (_) {
        fetchChats();
      });
    }
  }

  void setUnread(int index) {
    if (!_socketConnected) return;
    if (index < 0 || index >= chats.length) return;

    final chat = chats[index];
    // Local update
    final updatedChat = ChatModel(
      chatId: chat.chatId,
      userId: chat.userId,
      userName: chat.userName,
      userPicture: chat.userPicture,
      productId: chat.productId,
      productImage: chat.productImage,
      productPrice: chat.productPrice,
      productTitle: chat.productTitle,
      productStatus: chat.productStatus,
      lastMessage: chat.lastMessage,
      lastMessageTime: chat.lastMessageTime,
      unreadCount: 0,
      lastSeen: chat.lastSeen,
      blocked: chat.blocked,
      notification: chat.notification,
      postLat: chat.postLat,
      postLng: chat.postLng,
    );
    chats[index] = updatedChat;

    final lang = Get.find<GetStorage>().read('langCode') ?? 'tk';
    _socket.emitWithAck('get_data', {'lang': lang}, ack: (data) {
      if (data['status'] == 200) {
        unreadCount.value =
            int.tryParse(data['messages']?.toString() ?? '0') ?? 0;
        onlineUsers.value = data['online_users'] ?? [];
      }
    });
  }

  void toggleSelection(String chatId) {
    if (selectedChatIds.contains(chatId)) {
      selectedChatIds.remove(chatId);
    } else {
      selectedChatIds.add(chatId);
    }
    isSelectionMode.value = selectedChatIds.isNotEmpty;
    selectedChatIds.refresh();
  }

  void clearSelection() {
    selectedChatIds.clear();
    isSelectionMode.value = false;
    selectedChatIds.refresh();
  }

  Future<void> deleteSelectedChats() async {
    final ids = List<String>.from(selectedChatIds);
    clearSelection();
    for (final id in ids) {
      await deleteChat(id, refresh: false);
    }
    chats.removeWhere((c) => ids.contains(c.chatId));
    _computeUnread();
    await fetchChats();
  }

  Future<void> deleteChat(String chatId, {bool refresh = true}) async {
    if (_socketConnected) {
      _socket.emitWithAck('delete_chat', {'chat_id': chatId}, ack: (_) {});
    } else {
      try {
        await http.delete(
          Uri.parse('${_api.urlLink}api/user/chats/$chatId'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e) {
        debugPrint('[ChatController] deleteChat HTTP error: $e');
      }
    }
    if (refresh) {
      chats.removeWhere((c) => c.chatId == chatId);
      _computeUnread();
      await fetchChats();
    }
  }
}
