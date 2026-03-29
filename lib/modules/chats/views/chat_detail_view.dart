// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/message_model.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_detail_controller.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;

class ChatDetailView extends StatefulWidget {
  const ChatDetailView({
    super.key,
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.userPicture,
    required this.productId,
    required this.productImage,
    required this.productPrice,
    required this.productTitle,
    required this.productStatus,
    required this.lastSeen,
    required this.blocked,
    required this.notification,
    this.postLat,
    this.postLng,
  });

  final String chatId;
  final String userId;
  final String userName;
  final String userPicture;
  final String productId;
  final String productImage;
  final String productPrice;
  final String productTitle;
  final String productStatus;
  final String lastSeen;
  final bool blocked;
  final bool notification;
  final String? postLat;
  final String? postLng;

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _auth = AuthStorage();
  final _api = Api();

  late ChatDetailController _controller;

  String get _currentUserId {
    final user = _auth.getUser();
    return user?['id']?.toString() ?? '';
  }

  String get _token => _auth.token ?? '';

  @override
  void initState() {
    super.initState();
    final tag = 'chat_${widget.chatId}';
    _controller = Get.put(
      ChatDetailController(
        chatId: widget.chatId,
        productId: widget.productId,
        notification: widget.notification,
      ),
      tag: tag,
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _controller.loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    final tag = 'chat_${widget.chatId}';
    Get.delete<ChatDetailController>(tag: tag);
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    if (widget.notification) {
      _controller.createChat(text);
    } else {
      _controller.sendMessage(text);
    }
  }

  bool _isSameDay(String dt1, String dt2) {
    try {
      final d1 = DateTime.parse(dt1).toLocal();
      final d2 = DateTime.parse(dt2).toLocal();
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  String _formatLastSeen() {
    if (widget.lastSeen.isEmpty) return '';
    try {
      final ls = widget.lastSeen;
      final trimmed = ls.endsWith('Z') ? ls.substring(0, ls.length - 1) : ls;
      final dt = DateTime.parse(trimmed).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'online'.tr;
      if (diff.inHours < 1) return '${'last_seen'.tr}: ${diff.inMinutes}m';
      if (diff.inDays < 1) return '${'last_seen'.tr}: ${diff.inHours}h';
      return '${'last_seen'.tr}: ${DateFormat('d MMM').format(dt)}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar(context)],
        body: Column(
          children: [
            Expanded(child: _buildMessageList(context)),
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: ColorConstants.background,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: widget.notification ? 80 : 160,
      automaticallyImplyLeading: false,
      pinned: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildBackButton(context),
                const SizedBox(width: 10),
                _buildUserInfo(context),
              ],
            ),
            if (!widget.notification) _buildPopupMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: SvgPicture.asset(
          'assets/icons/arrow_left.svg',
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => SpecialProfile(),
          arguments: {
            'id': widget.userId,
            'username': widget.userName,
            'image': widget.userPicture,
          },
        );
      },
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatLastSeen(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final url = widget.userPicture;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.kPrimaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: url.isNotEmpty && url != 'null'
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: url.startsWith('http') ? url : '${_api.urlImage}$url',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallbackAvatar(),
              ),
            )
          : _fallbackAvatar(),
    );
  }

  Widget _fallbackAvatar() {
    final uid = int.tryParse(widget.userId) ?? 0;
    return CircleAvatar(
      radius: 22,
      backgroundColor: ColorConstants.noUserBackground[uid % 4],
      child: Center(
        child: Text(
          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Obx(() {
      final isLoadingLoc = _controller.isSendingLocation.value;
      return PopupMenuButton<String>(
        color: Colors.white,
        enabled: !isLoadingLoc,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoadingLoc
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: ColorConstants.kPrimaryColor2),
                  ),
                )
              : const Icon(Icons.more_vert, color: Colors.black),
        ),
        onSelected: (value) {
          if (value == 'block') {
            _showBlockDialog(context);
          } else if (value == 'report') {
            _showReportDialog(context);
          } else if (value == 'location') {
            _controller.sendLocation(widget.postLat, widget.postLng);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'block',
            child: Text(
              widget.blocked ? 'unblock_user'.tr : 'block_user'.tr,
            ),
          ),
          PopupMenuItem(
            value: 'report',
            child: Text('report'.tr),
          ),
        ],
      );
    });
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                widget.blocked
                    ? Icons.check_circle_outline_rounded
                    : Icons.block_flipped,
                color: ColorConstants.kPrimaryColor2,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                widget.blocked ? 'unblock_user'.tr : 'block_user'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.blocked ? 'unblock_user_desc'.tr : 'block_user_desc'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: ColorConstants.greyColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'no'.tr,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                            color: ColorConstants.kPrimaryColor2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _blockOrUnblockUser();
                      },
                      child: Text(
                        'yes'.tr,
                        style: const TextStyle(
                            color: ColorConstants.kPrimaryColor2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _blockOrUnblockUser() async {
    final endpoint = widget.blocked
        ? '${_api.urlLink}/api/user/unblock/${widget.userId}'
        : '${_api.urlLink}/api/user/block/${widget.chatId}';
    try {
      await http.post(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $_token'},
      );
      Get.back();
    } catch (e) {
      debugPrint('[ChatDetail] block/unblock error: $e');
    }
  }

  void _showReportDialog(BuildContext context) {
    final reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.report_problem_outlined,
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'report'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: reportController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'report_reason'.tr,
                    contentPadding: const EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: ColorConstants.greyColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await http.post(
                            Uri.parse('${_api.urlLink}/api/user/report'),
                            headers: {
                              'Authorization': 'Bearer $_token',
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode({
                              'chat_id': widget.chatId,
                              'reason': reportController.text,
                            }),
                          );
                        } catch (e) {
                          debugPrint('[ChatDetail] report error: $e');
                        }
                      },
                      child: Text(
                        'send'.tr,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
      }

      if (_controller.hasError.value) {
        return Center(child: Text(''.tr));
      }

      if (widget.notification) {
        return _buildNotificationModeList(context);
      }

      return _buildChatList(context);
    });
  }

  Widget _buildNotificationModeList(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 130),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${widget.userName} ${'liked_your_post'.tr}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
            Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.insideList.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _controller.insideList[index],
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    final msgs = _controller.messages;
    if (msgs.isEmpty) {
      return Center(child: Text('no_messages'.tr));
    }

    return ListView.separated(
      reverse: true,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: msgs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final msg = msgs[index];
        final isMe = msg.senderId == _currentUserId;

        bool isFirstInGroup = false;
        bool isLastInGroup = false;

        if (index == msgs.length - 1 ||
            msgs[index + 1].senderId != msg.senderId ||
            !_isSameDay(msg.createdAt, msgs[index + 1].createdAt)) {
          isFirstInGroup = true;
        }

        if (index == 0 ||
            msgs[index - 1].senderId != msg.senderId ||
            !_isSameDay(msg.createdAt, msgs[index - 1].createdAt)) {
          isLastInGroup = true;
        }

        final dt = DateTime.tryParse(msg.createdAt)?.toLocal();

        return Column(
          children: [
            // Date separator
            if (index == msgs.length - 1) _buildDateLabel(msg.createdAt),
            if (index < msgs.length - 1 &&
                !_isSameDay(msg.createdAt, msgs[index + 1].createdAt))
              _buildDateLabel(msg.createdAt),

            // Message bubble
            _buildMessageTile(
                context, msg, isMe, dt, isFirstInGroup, isLastInGroup),

            if (isLastInGroup) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildMessageTile(BuildContext context, MessageModel msg, bool isMe,
      DateTime? dt, bool isFirst, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 4 : 0,
        bottom: isLast ? 4 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              width: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: isLast ? _buildSenderAvatar() : const SizedBox.shrink(),
            ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (msg.image != null && msg.image != 'null')
                  _buildImageMessage(context, msg, isMe, isFirst, isLast, dt),
                if (msg.message.isNotEmpty &&
                    !msg.message.startsWith('Location: '))
                  _buildTextMessage(context, msg, isMe, dt, isFirst, isLast),
                if (msg.message.startsWith('Location: '))
                  _buildLocationMessage(
                      context, msg, isMe, dt, isFirst, isLast),
              ],
            ),
          ),
          SizedBox(width: isMe ? 3 : 35), // Space for alignment
        ],
      ),
    );
  }

  Widget _buildDateLabel(String rawDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(rawDate),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSenderAvatar() {
    final url = widget.userPicture;
    if (url.isNotEmpty && url != 'null') {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url.startsWith('http') ? url : '${_api.urlImage}$url',
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _smallFallback(),
        ),
      );
    }
    return _smallFallback();
  }

  Widget _smallFallback() {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    final uid = int.tryParse(widget.userId) ?? 0;
    return CircleAvatar(
      radius: 15,
      backgroundColor: colors[uid % colors.length],
      child: Text(
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context, MessageModel msg, bool isMe,
      bool isFirst, bool isLast, DateTime? dt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: () {
          // Open full screen image
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _FullScreenImage(
                imageUrl: '${_api.urlImage}${msg.image}',
              ),
            ),
          );
        },
        child: PhysicalShape(
          clipper: _MessageBubbleClipper(
              isMe: isMe, isFirst: isFirst, isLast: isLast),
          color: isMe ? ColorConstants.blue : Colors.white,
          elevation: 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: '${_api.urlImage}${msg.image}',
                height: 200,
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dt != null ? DateFormat('HH:mm').format(dt) : '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        color: isMe ? Colors.white70 : Colors.black45,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.readedAt != null && msg.readedAt != 'null'
                            ? Icons.done_all
                            : Icons.done,
                        size: 13,
                        color: Colors.white70,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context, MessageModel msg, bool isMe,
      DateTime? dt, bool isFirst, bool isLast) {
    final text = msg.message;

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('copied'.tr), duration: const Duration(seconds: 1)),
        );
      },
      child: PhysicalShape(
        clipper:
            _MessageBubbleClipper(isMe: isMe, isFirst: isFirst, isLast: isLast),
        color: isMe ? ColorConstants.blue : Colors.white,
        elevation: 0.5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: isMe ? 14 : 18,
            right: isMe ? 14 : 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              SelectableText(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dt != null ? DateFormat('HH:mm').format(dt) : '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: isMe ? Colors.white70 : Colors.black45,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      msg.readedAt != null && msg.readedAt != 'null'
                          ? Icons.done_all
                          : Icons.done,
                      size: 13,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorConstants.background,
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorConstants.whiteColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'message_hint'.tr,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 60,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorConstants.kPrimaryColor2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset('assets/icons/send.svg'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(BuildContext context, MessageModel msg,
      bool isMe, DateTime? dt, bool isFirst, bool isLast) {
    final raw = msg.message.replaceFirst('Location: ', '');
    final parts = raw.split(',');
    ll.LatLng? coords;
    if (parts.length == 2) {
      try {
        coords = ll.LatLng(
            double.parse(parts[0].trim()), double.parse(parts[1].trim()));
      } catch (_) {}
    }

    return GestureDetector(
      onTap: coords != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _LocationMapScreen(
                    coords: coords!,
                    title: isMe ? 'me'.tr : widget.userName,
                  ),
                ),
              )
          : null,
      child: PhysicalShape(
        clipper:
            _MessageBubbleClipper(isMe: isMe, isFirst: isFirst, isLast: isLast),
        color: isMe ? ColorConstants.blue : Colors.white,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on,
                        size: 14,
                        color: isMe ? Colors.white : ColorConstants.blue),
                    const SizedBox(width: 4),
                    Text(
                      'location'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              if (coords != null) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 120,
                    width: 220,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: coords,
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(urlTemplate: _api.mapApi),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: coords,
                              width: 25,
                              height: 25,
                              child: const Icon(Icons.location_on,
                                  color: Colors.red, size: 25),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dt != null ? DateFormat('HH:mm').format(dt) : '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: isMe ? Colors.white70 : Colors.black45,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      msg.readedAt != null && msg.readedAt != 'null'
                          ? Icons.done_all
                          : Icons.done,
                      size: 13,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubbleClipper extends CustomClipper<Path> {
  final bool isMe;
  final bool isFirst;
  final bool isLast;

  _MessageBubbleClipper({
    required this.isMe,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double tr = !isMe ? 18 : (isFirst ? 18 : 6);
    final double tl = isMe ? 18 : (isFirst ? 18 : 6);
    final double br = !isMe ? 18 : (isLast ? 18 : 6);
    final double bl = isMe ? 18 : (isLast ? 18 : 6);

    path.moveTo(tl, 0);
    path.lineTo(size.width - tr, 0);
    path.quadraticBezierTo(size.width, 0, size.width, tr);

    if (isMe && isLast) {
      path.lineTo(size.width, size.height - 15);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width - 15, size.height);
    } else {
      path.lineTo(size.width, size.height - br);
      path.quadraticBezierTo(
          size.width, size.height, size.width - br, size.height);
    }

    if (!isMe && isLast) {
      path.lineTo(15, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, size.height - 15);
    } else {
      path.lineTo(bl, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - bl);
    }

    path.lineTo(0, tl);
    path.quadraticBezierTo(0, 0, tl, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _LocationMapScreen extends StatelessWidget {
  const _LocationMapScreen({required this.coords, required this.title});
  final ll.LatLng coords;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title,
            style: const TextStyle(color: Colors.black, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: coords,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: Api().mapApi,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: coords,
                width: 40,
                height: 40,
                child:
                    const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
