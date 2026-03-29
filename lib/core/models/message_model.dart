class MessageModel {
  final String id;
  final String message;
  final String senderId;
  final String? readedAt;
  final String? image;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    this.readedAt,
    this.image,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      readedAt: json['readed_at']?.toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'sender_id': senderId,
        'readed_at': readedAt,
        'image': image,
        'created_at': createdAt,
      };
}