// ignore_for_file: avoid_print

import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/core/models/message_model.dart';
import 'package:gyzyleller/core/services/chat_socket_service.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:gyzyleller/core/services/my_jobs_service.dart';
import '../../../core/services/api.dart';

class ChatDetailController extends GetxController {
  final String chatId;
  final String productId;
  final bool notification;

  ChatDetailController({
    required this.chatId,
    required this.productId,
    required this.notification,
  });

  final _auth = AuthStorage();
  final _api = Api();
  final _jobsService = MyJobsService();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rxn<JobModel> job = Rxn<JobModel>();
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSendingLocation = false.obs;
  final RxList<String> insideList = <String>[].obs;

  int _page = 0;
  Timer? _pollingTimer;
  bool _isPollingActive = false;
  bool _initialDataFetched = false;

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
    if (notification == false) {
      _setupSocketListeners();
    }
    _fetchInitialMessages();
    _fetchJobDetail();
  }

  void _fetchJobDetail() {
    if (productId.isNotEmpty && productId != '0' && productId != 'null') {
      final id = int.tryParse(productId);
      if (id != null) {
        _jobsService.getJobDetail(id).then((resp) {
          job.value = resp.job;
        }).catchError((e) {
          debugPrint('[ChatDetailController] fetchJobDetail error: $e');
        });
      }
    }
  }

  @override
  void onClose() {
    _stopPolling();
    _removeSocketListeners();
    super.onClose();
  }

  void _setupSocketListeners() {
    if (!Get.find<ChatSocketService>().isInitialized) return;
    _socket.onConnect((_) {
      debugPrint('✅ [ChatDetail] Socket bağlandý – polling durduryldy');
      _stopPolling();
    });

    _socket.onDisconnect((_) {
      debugPrint('❌ [ChatDetail] Socket kesildi – polling başladyldy');
      _startPolling();
    });

    _socket.on('new_message', (data) {
      if (data == null) return;
      if (data is Map &&
          data['message'] != null &&
          data['message']['chat_id']?.toString() == chatId) {
        final msg = MessageModel.fromJson(
            Map<String, dynamic>.from(data['message'] as Map));

        final exists = messages.any((m) => m.id == msg.id);
        if (!exists) {
          messages.insert(0, msg);
        }
      }
    });

    _socket.on('readed_messages_$chatId', (_) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].readedAt == null || messages[i].readedAt == 'null') {
          messages[i] = MessageModel(
            id: messages[i].id,
            message: messages[i].message,
            senderId: messages[i].senderId,
            readedAt: DateTime.now().toIso8601String(),
            image: messages[i].image,
            createdAt: messages[i].createdAt,
          );
        }
      }
      messages.refresh();
    });
  }

  void _removeSocketListeners() {
    _socket.off('new_message');
    _socket.off('readed_messages_$chatId');
  }

  void _fetchInitialMessages() {
    if (_initialDataFetched) return;
    _initialDataFetched = true;

    _fetchMessagesHttp(page: 0, isInitial: true);

    if (_socketConnected) {
      _socket.emitWithAck(
        'get_chat_2',
        {'chat_id': chatId, 'page': 0, 'limit': 20, 'type': 'gyzyl'},
        ack: (data) {
          if (data is Map && data['status'] != 500) {
            final list = data['messages'];
            if (list is List && list.isNotEmpty) {
              messages.value = list
                  .map((e) => MessageModel.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList();
              hasError.value = false;
              isLoading.value = false;
              debugPrint(
                  '✅ [ChatDetail] Socket: ${messages.length} habar ýüklendi');
            }
          }
        },
      );
    } else {
      _startPolling();
    }
  }

  void _startPolling() {
    if (_isPollingActive) return;
    _isPollingActive = true;
    debugPrint('[ChatDetail] Polling başladyldy (5s)');
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_socketConnected) {
        _stopPolling();
        return;
      }
      await _fetchMessagesHttp(page: 0, isInitial: false);
    });
  }

  void _stopPolling() {
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
      _pollingTimer = null;
      _isPollingActive = false;
      debugPrint('[ChatDetail] Polling durduryldy');
    }
  }

  Future<void> _fetchMessagesHttp(
      {required int page, required bool isInitial}) async {
    if (isInitial) isLoading.value = true;
    try {
      final uri = Uri.parse('${_api.urlLink}api/user/messages/$chatId').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': '20',
          'type': 'gyzyl'
        },
      );
      print('[DEBUG] Fetching messages for chatId: $chatId, url: '
          '"+uri.toString()+"');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> list = data['messages'] ?? data ?? [];
        final newMessages = list
            .map((e) =>
                MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        if (page == 0) {
          messages.value = newMessages;
        } else {
          messages.addAll(newMessages);
        }
        hasError.value = false;
      } else {
        if (isInitial) hasError.value = true;
      }
    } catch (e) {
      if (isInitial) hasError.value = true;
      debugPrint('[ChatDetailController] fetchMessages error: $e');
    } finally {
      if (isInitial) isLoading.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;
    _page++;

    if (_socketConnected) {
      bool got = false;
      _socket.emitWithAck(
        'get_chat_2',
        {'chat_id': chatId, 'page': _page, 'limit': 20, 'type': 'gyzyl'},
        ack: (data) {
          got = true;
          if (data is Map &&
              data['messages'] is List &&
              (data['messages'] as List).isNotEmpty) {
            final older = (data['messages'] as List)
                .map((e) =>
                    MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
            messages.addAll(older);
          }
          isLoadingMore.value = false;
        },
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (!got) await _fetchMessagesHttp(page: _page, isInitial: false);
    } else {
      await _fetchMessagesHttp(page: _page, isInitial: false);
    }
    isLoadingMore.value = false;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final optimistic = MessageModel(
      id: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
      message: text,
      senderId: currentUserId,
      readedAt: null,
      createdAt: DateTime.now().toIso8601String(),
    );
    messages.insert(0, optimistic);

    if (_socketConnected) {
      _socket.emit('send_message',
          {'message': text, 'chat_id': chatId, 'type': 'gyzyl'});
    } else {
      try {
        await http.post(
          Uri.parse('${_api.urlLink}api/user/message')
              .replace(queryParameters: {'type': 'gyzyl'}),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'chat_id': chatId, 'message': text}),
        );
      } catch (e) {
        debugPrint('[ChatDetailController] sendMessage HTTP error: $e');
      }
    }
  }

  Future<void> createChat(String text) async {
    insideList.add(text);

    if (_socketConnected) {
      _socket.emit('create_chat', {
        'message': text,
        'product_id': productId,
        'user_id': currentUserId,
        'type': 'gyzyl',
      });
    } else {
      try {
        final response = await http.post(
          Uri.parse('${_api.urlLink}api/user/create-chat')
              .replace(queryParameters: {'type': 'gyzyl'}),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'product_id': productId, 'message': text}),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.back();
        }
      } catch (e) {
        debugPrint('[ChatDetailController] createChat error: $e');
      }
    }
  }

  // ─── Send location ───
  Future<void> sendLocation(String? postLat, String? postLng) async {
    if (isSendingLocation.value) return;
    if (postLat == null ||
        postLat == 'null' ||
        postLat.isEmpty ||
        postLng == null ||
        postLng == 'null' ||
        postLng.isEmpty) {
      debugPrint('[ChatDetail] sendLocation: koord ýok');
      return;
    }
    isSendingLocation.value = true;
    try {
      await sendMessage('Location: $postLat,$postLng');
    } finally {
      isSendingLocation.value = false;
    }
  }
}
