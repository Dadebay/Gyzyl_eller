// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/chat_model.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/chats/controllers/chat_controller.dart';
import 'package:gyzyleller/modules/chats/views/chat_detail_view.dart';
import 'package:gyzyleller/modules/chats/views/non_auth_chat_detail_view.dart';
import 'package:gyzyleller/modules/settings_profile/views/settings_view.dart';
import 'package:intl/intl.dart';

const zerror = Color.fromRGBO(255, 45, 95, 1.0);
const gray300 = Color(0xFFE3E3E3);

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ChatController? _chatController;
  final Api api = Api();
  final _auth = AuthStorage();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_auth.isLoggedIn) {
      _chatController = Get.find<ChatController>();
      _chatController?.fetchChats();
    }
  }

  Future<void> _onRefresh() async {
    await _chatController?.fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_auth.isLoggedIn && _chatController == null) {
      _chatController = Get.find<ChatController>();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _chatController?.fetchChats();
      });
    }

    if (!_auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: ColorConstants.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSimple(context),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: _buildAdminTile(context),
            ),
            const Spacer(),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: RefreshIndicator(
              color: ColorConstants.blue,
              backgroundColor: ColorConstants.background,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildAdminTileForAuth(context),
                  ),
                  _buildChatList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSimple(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 50),
          Expanded(
            child: Center(
              child: Text(
                'chat'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTileForAuth(BuildContext context) {
    return Obx(() {
      final adminChat =
          _chatController?.chats.firstWhereOrNull((c) => c.isAdmin);
      return _buildAdminTile(
        context,
        unreadCount: adminChat?.unreadCount ?? 0,
        chatId: adminChat?.chatId ?? 'admin',
        lastMessage: adminChat?.lastMessage ?? '',
        time: adminChat?.lastMessageTime ?? '',
      );
    });
  }

  Widget _buildAdminTile(BuildContext context,
      {int unreadCount = 0,
      String chatId = 'admin',
      String lastMessage = '',
      String time = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: gray300.withOpacity(0.5)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (!_auth.isLoggedIn) {
                Get.to(() => const NonAuthChatDetailView());
              } else {
                Get.to(
                  () => ChatDetailView(
                    chatId: chatId,
                    userName: 'chat_admin'.tr,
                    userId: 'admin',
                    userPicture: '',
                    productId: '',
                    productImage: '',
                    productPrice: '',
                    productTitle: '',
                    productStatus: '1',
                    lastSeen: '',
                    blocked: false,
                    notification: false,
                  ),
                );
              }
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 18.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.support_agent,
                                  color: ColorConstants.kPrimaryColor2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'chat_admin'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessage.isNotEmpty ? lastMessage : '...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: unreadCount > 0
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ctrl = _chatController!;
    return Obx(() {
      final isSelectionMode = ctrl.isSelectionMode.value;
      final selectedCount = ctrl.selectedChatIds.length;

      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: ctrl.clearSelection,
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    isSelectionMode
                        ? '$selectedCount ${'selected'.tr}'
                        : 'chat'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _showDeleteDialog(context),
              )
          ],
        ),
      );
    });
  }

  void _showDeleteDialog(BuildContext context) {
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
                Icons.delete_outline_rounded,
                color: ColorConstants.kPrimaryColor2,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'delete_chats'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'delete_chats_desc'.tr,
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
                        _chatController?.deleteSelectedChats();
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

  Widget _buildChatList(BuildContext context) {
    final ctrl = _chatController!;
    return Obx(() {
      if (ctrl.isLoadingChats.value && ctrl.chats.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: ColorConstants.kPrimaryColor2,
            ),
          ),
        );
      }

      if (ctrl.hasError.value || ctrl.chats.isEmpty) {
        final lang = Get.locale?.languageCode ?? 'tk';
        final imagePath = lang == 'ru'
            ? 'assets/images/onboarding4_ru.png'
            : 'assets/images/onboarding4.png';
        return SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imagePath, width: 260),
                  const SizedBox(height: 24),
                  Text(
                    ctrl.hasError.value
                        ? 'chat_error_title'.tr
                        : 'chat_empty_title'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ctrl.hasError.value
                        ? 'chat_error_subtitle'.tr
                        : 'chat_empty_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.kPrimaryColor2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _onRefresh,
                    child: Text(
                      'refresh'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final chats = ctrl.chats.where((c) => !c.isAdmin).toList();
      final int firstValid = chats.indexWhere((c) => c.productTitle.isNotEmpty);

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final chat = chats[index];
              final br = _getBorderRadius(index, chats.length, firstValid);
              return Obx(() {
                final isSelected = ctrl.selectedChatIds.contains(chat.chatId);
                final isSelMode = ctrl.isSelectionMode.value;

                return _ChatListItem(
                  chat: chat,
                  borderRadius: br,
                  isSelected: isSelected,
                  isSelectionMode: isSelMode,
                  onTap: () {
                    if (isSelMode) {
                      ctrl.toggleSelection(chat.chatId);
                    } else {
                      ctrl.setUnread(index);
                      Get.to(
                        () => ChatDetailView(
                          chatId: chat.chatId,
                          userId: chat.userId,
                          userName: chat.userName,
                          userPicture: chat.userPicture,
                          productId: chat.productId,
                          productImage: chat.productImage,
                          productPrice: chat.productPrice,
                          productTitle: chat.productTitle,
                          productStatus: chat.productStatus,
                          lastSeen: chat.lastSeen,
                          blocked: chat.blocked,
                          notification: chat.notification,
                          postLat: chat.postLat,
                          postLng: chat.postLng,
                        ),
                      )?.then((_) => ctrl.fetchChats());
                    }
                  },
                  onLongPress: () => ctrl.toggleSelection(chat.chatId),
                  onDelete: () => ctrl.deleteChat(chat.chatId),
                );
              });
            },
            childCount: chats.length,
          ),
        ),
      );
    });
  }

  BorderRadiusGeometry _getBorderRadius(
      int index, int total, int firstValidIndex) {
    if (total == 1) return BorderRadius.circular(20);
    if (index == firstValidIndex) {
      return const BorderRadius.vertical(top: Radius.circular(20));
    }
    if (index == total - 1) {
      return const BorderRadius.vertical(bottom: Radius.circular(20));
    }
    return BorderRadius.zero;
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final BorderRadiusGeometry borderRadius;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final _api = Api();

  _ChatListItem({
    required this.chat,
    required this.borderRadius,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.red.withOpacity(0.12)
                : Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Slidable(
          key: Key(chat.chatId),
          enabled: !isSelectionMode,
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
                label: 'delete'.tr,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 18.0), // Increased spacing
                    child: Row(
                      children: [
                        _buildAvatarWithStatus(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.productTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(chat.lastMessageTime),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.lastMessage.isNotEmpty
                                          ? chat.lastMessage
                                          : '...',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: chat.unreadCount > 0
                                            ? Colors.black87
                                            : Colors.grey.shade500,
                                        fontWeight: chat.unreadCount > 0
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                  if (chat.unreadCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${chat.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isSelectionMode) _buildTrailingImage(chat),
                  if (isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected
                            ? ColorConstants.kPrimaryColor2
                            : Colors.grey.shade300,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingImage(ChatModel chat) {
    if (chat.productImage.isEmpty || chat.productImage == 'null') {
      return const SizedBox.shrink();
    }
    final url = chat.productImage.startsWith('http')
        ? chat.productImage
        : '${_api.urlImage}${chat.productImage}';

    return GestureDetector(
      onTap: () {
        _navigateToDetail(chat);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported,
                size: 20, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(ChatModel chat) {
    Get.to(
      () => ChatDetailView(
        chatId: chat.chatId,
        userId: chat.userId,
        userName: chat.userName,
        userPicture: chat.userPicture,
        productId: chat.productId,
        productImage: chat.productImage,
        productPrice: chat.productPrice,
        productTitle: chat.productTitle,
        productStatus: chat.productStatus,
        lastSeen: chat.lastSeen,
        blocked: chat.blocked,
        notification: chat.notification,
        postLat: chat.postLat,
        postLng: chat.postLng,
      ),
    );
  }

  Widget _buildAvatarWithStatus() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ColorConstants.kPrimaryColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: _buildAvatar(),
        ),
      ],
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return DateFormat('HH:mm').format(dt);
      }
      return DateFormat('dd.MM').format(dt);
    } catch (_) {
      return '';
    }
  }

  Widget _buildAvatar() {
    if (chat.userPicture.isNotEmpty && chat.userPicture != 'null') {
      final url = chat.userPicture.startsWith('http')
          ? chat.userPicture
          : '${_api.urlImage}${chat.userPicture}';
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallbackAvatar(),
        ),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    final uid = int.tryParse(chat.userId) ?? 0;
    return CircleAvatar(
      radius: 22,
      backgroundColor: ColorConstants.noUserBackground[uid % 4],
      child: Center(
        child: Text(
          chat.userName.isNotEmpty ? chat.userName[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
