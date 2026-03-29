class ChatModel {
  final String chatId;
  final String userId;
  final String userName;
  final String userPicture;
  final String productId;
  final String productImage;
  final String productPrice;
  final String productTitle;
  final String productStatus;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final String lastSeen;
  final bool blocked;
  final bool notification;
  final String? postLat;
  final String? postLng;
  final bool isAdmin;

  ChatModel({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.userPicture,
    required this.productId,
    required this.productImage,
    required this.productPrice,
    required this.productTitle,
    required this.productStatus,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.lastSeen,
    required this.blocked,
    required this.notification,
    this.postLat,
    this.postLng,
    this.isAdmin = false,
  });

  /// Builds a ChatModel from the chat entry + the separate products/users maps
  /// that the API returns as: { "chats": [...], "products": {...}, "users": {...} }
  factory ChatModel.fromApiData(
    Map<String, dynamic> chat,
    Map<String, dynamic> products,
    Map<String, dynamic> users,
  ) {
    final productId = chat['product_id']?.toString() ??
        chat['job_id']?.toString() ??
        chat['service_id']?.toString() ??
        '';
    final userId = chat['user_id']?.toString() ?? '';
    final product = products[productId] as Map<String, dynamic>? ?? {};
    final user = users[userId] as Map<String, dynamic>? ?? {};

    return ChatModel(
      chatId: chat['id']?.toString() ?? '',
      userId: userId,
      userName:
          user['username']?.toString() ?? chat['username']?.toString() ?? '',
      userPicture: user['image']?.toString() ?? chat['image']?.toString() ?? '',
      productId: productId,
      productImage: product['image']?.toString() ?? '',
      productPrice: product['price']?.toString() ?? '',
      productTitle: product['name']?.toString() ??
          product['title']?.toString() ??
          product['product_name']?.toString() ??
          product['job_name']?.toString() ??
          product['product_title']?.toString() ??
          product['job_title']?.toString() ??
          chat['name']?.toString() ??
          chat['title']?.toString() ??
          chat['product_name']?.toString() ??
          chat['job_name']?.toString() ??
          chat['product_title']?.toString() ??
          chat['job_title']?.toString() ??
          '',
      productStatus: product['status']?.toString() ?? '1',
      lastMessage: chat['last_message']?.toString() ?? '',
      lastMessageTime: chat['last_sended_message']?.toString() ?? '',
      unreadCount: () {
        final val = chat['unread_count']?.toString() ?? chat['unreadCount']?.toString() ?? chat['unread']?.toString() ?? '0';
        final parsed = int.tryParse(val) ?? 0;
        if (parsed > 0) {
          print('🔥 [ChatModel] Found unreadCount: $parsed in chat ${chat['id']}');
        }
        return parsed;
      }(),
      lastSeen:
          user['last_seen']?.toString() ?? chat['last_seen']?.toString() ?? '',
      blocked: chat['banned'] == true,
      notification: false,
      postLat: product['lat']?.toString(),
      postLng: product['lng']?.toString(),
      isAdmin: chat['type_id']?.toString() == '2' ||
          chat['type_id']?.toString() == '4',
    );
  }
}
