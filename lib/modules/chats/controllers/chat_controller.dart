// ignore_for_file: library_prefixes, avoid_print, empty_catches

import 'dart:developer';
import 'package:gyzyleller/core/models/chat_model.dart';
import 'package:gyzyleller/modules/chats/controllers/notification_controller.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/chat_socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../core/services/api.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
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

  bool _isFetching = false;

  // Sorting: 0=All, 1=Buy, 2=Sell, 3=Blocked
  final RxInt currentSort = 0.obs;
  // SortDate: 0=Last Message, 1=Unread
  final RxInt sortDate = 0.obs;

  // Metadata Cache to prevent "disappearing" job names
  final Map<String, dynamic> _productsCache = {};
  final Map<String, dynamic> _usersCache = {};

  Timer? _pollingTimer;
  Timer? _socketGuardTimer;
  IO.Socket? _boundSocket;
  bool _pendingFetch = false;

  String get token => _auth.token ?? '';
  String get currentUserId {
    final user = _auth.getUser();
    return user?['id']?.toString() ?? '';
  }

  IO.Socket? get _socket => Get.find<ChatSocketService>().socket;
  bool get _socketConnected => Get.find<ChatSocketService>().isConnected;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initSocketListeners();
    _startSocketGuard();

    // Bind notification count to stay updated in UI
    final notifCtrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    notifCount.value = notifCtrl.unreadCount.value;
    ever<int>(notifCtrl.unreadCount, (val) => notifCount.value = val);

    if (_auth.isLoggedIn) fetchChats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _auth.isLoggedIn) {
      debugPrint('🔄 [ChatController] App resumed, refreshing data...');
      fetchChats();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _socketGuardTimer?.cancel();
    _socketGuardTimer = null;
    _stopPolling();
    super.onClose();
  }

  // ─── Socket listeners ───
  void _initSocketListeners() {
    final s = _socket;
    if (s == null) return;
    if (identical(_boundSocket, s)) return;

    _boundSocket = s;

    // Avoid duplicated listeners when socket is recreated/reconnected.
    s.off('last_sended_message');
    s.off('chat_created');
    s.off('new_message');
    s.off('user_connected');
    s.off('user_disconnected');
    s.off('connect');
    s.off('disconnect');
    s.off('connect_error');

    s.on('last_sended_message', (_) => fetchChats());
    s.on('chat_created', (_) => fetchChats());
    s.on('new_message', (_) => fetchChats());
    s.on('user_connected', (_) => _getData());
    s.on('user_disconnected', (_) => _getData());

    s.onConnect((_) {
      fetchChats();
      _stopPolling();
    });

    s.onDisconnect((reason) {
      _fetchChatsHttp(); // Immediate fetch on cut
      _startPolling();
    });

    s.onConnectError((data) {
      _fetchChatsHttp();
      _startPolling();
    });
  }

  void _startSocketGuard() {
    _socketGuardTimer?.cancel();
    _socketGuardTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_auth.isLoggedIn) return;

      // Rebind listeners automatically if socket instance changed while user
      // is on another page.
      _initSocketListeners();

      if (_socketConnected) {
        _stopPolling();
      } else {
        _startPolling();
      }
    });
  }

  /// Called from the view when it becomes visible to ensure socket is live
  /// and data is shown. Falls back to HTTP + polling until socket reconnects.
  void ensureConnected() {
    if (!_auth.isLoggedIn) return;
    if (!_socketConnected) {
      // Fetch immediately via HTTP so the list shows without waiting for socket
      _fetchChatsHttp();
      // Start polling (no-op if already running)
      _startPolling();
      // Try to reconnect the socket in the background
      final service = Get.find<ChatSocketService>();
      if (!service.isConnected) {
        service.reconnect();
        Future.delayed(const Duration(milliseconds: 600), () {
          _initSocketListeners();
        });
      }
    } else {
      fetchChats();
    }
  }

  void _getData() {
    if (!_socketConnected) return;
    final lang = Get.find<GetStorage>().read('langCode') ?? 'tk';
    _socket?.emitWithAck('get_data', {'lang': lang, 'type': 'gyzyl'},
        ack: (data) {
      if (data['status'] == 200) {
        onlineUsers.value = data['online_users'] ?? [];
      }
    });
  }

  // ─── Polling fallback ───
  void _startPolling() {
    if (!_auth.isLoggedIn) return;
    if (_pollingTimer != null) return;
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_socketConnected && _auth.isLoggedIn) {
        _fetchChatsHttp();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void reset() {
    _stopPolling();
    chats.clear();
    _productsCache.clear();
    _usersCache.clear();
    unreadCount.value = 0;
    notifCount.value = 0;
    onlineUsers.clear();
    selectedChatIds.clear();
    isSelectionMode.value = false;
    hasError.value = false;
    _isFetching = false;
  }

  Future<void> fetchChats() async {
    if (!_auth.isLoggedIn) return;
    if (_isFetching) {
      _pendingFetch = true;
      return;
    }
    _isFetching = true;

    // If we have data, don't show full screen loader
    if (chats.isEmpty) {
      isLoadingChats.value = true;
    }

    try {
      if (_socketConnected) {
        await _fetchChatsSocket();
        _getData();
        _stopPolling();
      } else {
        await _fetchChatsHttp();
        _startPolling();
      }
    } finally {
      _isFetching = false;
      isLoadingChats.value = false;
      if (_pendingFetch) {
        _pendingFetch = false;
        Future.microtask(fetchChats);
      }
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

  Future<void> _fetchChatsSocket() {
    final completer = Completer<void>();
    if (chats.isEmpty) {
      isLoadingChats.value = true;
    }
    bool responded = false;
    final lang = Get.find<GetStorage>().read('langCode') ?? 'tk';

    // 1-second fallback if socket doesn't respond
    Timer(const Duration(seconds: 1), () {
      if (!responded) {
        responded = true;
        _fetchChatsHttp().then((_) {
          if (!completer.isCompleted) completer.complete();
        });
        _startPolling();
      }
    });

    _socket?.emitWithAck('get_chats', {
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
          // Metadata processing: convert List to Map or ensure String keys
          Map<String, dynamic> toMap(dynamic input) {
            final map = <String, dynamic>{};
            if (input is Map) {
              input.forEach((k, v) => map[k.toString()] = v);
            } else if (input is List) {
              for (var item in input) {
                if (item is Map && item['id'] != null) {
                  map[item['id'].toString()] = item;
                }
              }
            }

            return map;
          }

          if (chatList.isNotEmpty) {}

          final products = toMap(data['products'] ?? data['jobs']);
          final users = toMap(data['users']);

          // Update cache
          _productsCache.addAll(products);
          _usersCache.addAll(users);

          if (chatList.length > 1 && (products.isEmpty || users.isEmpty)) {
            log('⚠️ [ChatController] Metadata eksik (Socket), 2s soň täzeden synanyşylýar...');
            Future.delayed(const Duration(seconds: 2), () => fetchChats());
            responded = true; // Mark as handled but don't update UI yet
            return;
          }

          final newChats = chatList
              .map((e) => ChatModel.fromApiData(
                    e as Map<String, dynamic>,
                    _productsCache,
                    _usersCache,
                  ))
              .toList();

          chats.value = newChats;
          _computeUnread(newChats);

          // Also fetch notifications on socket response
          if (Get.isRegistered<NotificationController>()) {
            Get.find<NotificationController>()
                .fetchNotificationCount()
                .then((_) {
              notifCount.value =
                  Get.find<NotificationController>().unreadCount.value;
            });
          }
          hasError.value = false;
        }
      } catch (e) {
        _fetchChatsHttp().then((_) {
          if (!completer.isCompleted) completer.complete();
        });
      } finally {
        if (responded) {
          isLoadingChats.value = false;
          if (!completer.isCompleted) completer.complete();
        }
      }
    });

    // Get online users, but don't overwrite unreadCount here to avoid lag
    _socket?.emitWithAck('get_data', {'lang': lang, 'type': 'gyzyl'},
        ack: (data) {
      if (data['status'] == 200) {
        onlineUsers.value = data['online_users'] ?? [];
      }
    });

    return completer.future;
  }

  Future<void> _fetchChatsHttp() async {
    if (chats.isEmpty) {
      isLoadingChats.value = true;
    }
    hasError.value = false;

    final notifCtrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    await notifCtrl.fetchNotificationCount();
    notifCount.value = notifCtrl.unreadCount.value;
    try {
      // Prevent request if no token is available
      if (token.isEmpty) {
        print(
            '⚠️ [ChatController] GET request blocked: No token available for /api/user/chats');
        hasError.value = true;
        isLoadingChats.value = false;
        return;
      }

      final uri = Uri.parse('${_api.urlLink}api/user/chats').replace(
        queryParameters: {
          'all': 'true',
          'type': 'gyzyl',
        },
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> chatList = data['chats'] ?? [];

        if (chatList.isNotEmpty) {}

        // Metadata processing: convert List to Map or ensure String keys
        Map<String, dynamic> toMap(dynamic input) {
          final map = <String, dynamic>{};
          if (input is Map) {
            input.forEach((k, v) => map[k.toString()] = v);
          } else if (input is List) {
            for (var item in input) {
              if (item is Map && item['id'] != null) {
                map[item['id'].toString()] = item;
              }
            }
          }
          if (map.isNotEmpty) {}
          return map;
        }

        final products = toMap(data['products'] ?? data['jobs']);
        final users = toMap(data['users']);

        // Update cache
        _productsCache.addAll(products);
        _usersCache.addAll(users);

        final newHttpChats = chatList
            .map((e) => ChatModel.fromApiData(
                  e as Map<String, dynamic>,
                  _productsCache,
                  _usersCache,
                ))
            .toList();

        chats.value = newHttpChats;
        _computeUnread(newHttpChats);

        hasError.value = false;
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoadingChats.value = false;
    }
  }

  void _computeUnread([List<ChatModel>? customList]) {
    final listToProcess = customList ?? chats;
    int total = 0;
    for (final c in listToProcess) {
      if (c.unreadCount > 0) {}
      total += c.unreadCount;
    }
    unreadCount.value = total;
  }

  bool isUserOnline(String userId) {
    return onlineUsers.any((u) => u.toString() == userId);
  }

  void blockUser(String chatId) {
    if (_socketConnected) {
      _socket?.emitWithAck('block_chat', {'chat_id': chatId, 'type': 'gyzyl'},
          ack: (_) {});
    }
  }

  void unBlockUser(String userId) {
    if (_socketConnected) {
      _socket?.emitWithAck('unblock_user', {'user_id': userId, 'type': 'gyzyl'},
          ack: (_) {
        fetchChats();
      });
    }
  }

  void setUnread(int index) {
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
    _computeUnread(); // Immediate local badge refresh

    if (_socketConnected) {
      final lang = Get.find<GetStorage>().read('langCode') ?? 'tk';
      _socket?.emitWithAck('get_data', {'lang': lang, 'type': 'gyzyl'},
          ack: (data) {
        if (data['status'] == 200) {
          onlineUsers.value = data['online_users'] ?? [];
          // Note: we don't overwrite unreadCount from server response here
          // to prevent flickering if server lag occurs.
          // _computeUnread() already handled it locally.
        }
      });
    }
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
      _socket?.emitWithAck('delete_chat', {'chat_id': chatId, 'type': 'gyzyl'},
          ack: (_) {});
    } else {
      try {
        await http.delete(
          Uri.parse('${_api.urlLink}api/user/chats/$chatId')
              .replace(queryParameters: {'type': 'gyzyl'}),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e) {}
    }
    if (refresh) {
      chats.removeWhere((c) => c.chatId == chatId);
      _computeUnread();
      await fetchChats();
    }
  }
}
