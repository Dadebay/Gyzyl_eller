
class NotificationModel {
  NotificationModel({
    required this.id,
    required this.productId,
    required this.price,
    required this.name,
    required this.typeId,
    required this.showed,
    required this.username,
    required this.lastSeen,
    required this.userId,
    required this.userImage,
    required this.image,
    required this.notificationTime,
    required this.old,
    required this.userRoleId,
    required this.saleBody,
    required this.storyRejectReason,
    required this.saleImage,
    required this.body,
    required this.storyStatusId,
  });

  final String id;
  final String productId;
  final String price;
  final String name;
  final String typeId;
  final String showed;
  final String username;
  final String lastSeen;
  final String userId;
  final String userImage;
  final String image;
  final String old;
  final String notificationTime;
  final String userRoleId;
  final String storyStatusId;
  final String storyRejectReason;
  final String body;
  final String saleBody;
  final String saleImage;

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'].toString(),
      productId: map['product_id'].toString(),
      price: map['price'].toString(),
      name: map['name'].toString(),
      showed: map['showed'].toString(),
      username: map['username'].toString(),
      lastSeen: map['last_seen'].toString(),
      userId: map['user_id'].toString(),
      userImage: map['user_image'].toString(),
      image: map['product_image'] ?? map['image'].toString(),
      old: map['old'].toString(),
      typeId: map['type_id'].toString(),
      notificationTime: map['notification_time'].toString(),
      userRoleId: '${map['user_role_id']}',
      saleBody: map['sale_body'].toString(),
      storyRejectReason: map['story_reject_reason'].toString(),
      storyStatusId: map['story_status_id'].toString(),
      saleImage: map['sale_image'].toString(),
      body: map['body'].toString(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? productId,
    String? price,
    String? name,
    String? typeId,
    String? showed,
    String? username,
    String? lastSeen,
    String? userId,
    String? userImage,
    String? image,
    String? notificationTime,
    String? old,
    String? userRoleId,
    String? saleBody,
    String? storyRejectReason,
    String? storyStatusId,
    String? saleImage,
    String? body,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      showed: showed ?? this.showed,
      username: username ?? this.username,
      lastSeen: lastSeen ?? this.lastSeen,
      userId: userId ?? this.userId,
      userImage: userImage ?? this.userImage,
      image: image ?? this.image,
      notificationTime: notificationTime ?? this.notificationTime,
      old: old ?? this.old,
      saleBody: saleBody ?? this.saleBody,
      storyRejectReason: storyRejectReason ?? this.storyRejectReason,
      storyStatusId: storyStatusId ?? this.storyStatusId,
      saleImage: saleImage ?? this.saleImage,
      body: body ?? this.body,
      userRoleId: userRoleId ?? this.userRoleId,
    );
  }
}
