class UserModel {
  final int id;
  final int adminId;
  final String username;
  final String typeTitle;
  final String? img; // The image URL can be null
  final String name; // Name can also be null from the API
  final bool blok;
  final String rating;
  final String userStatusChanging;
  final String productCount;
  final String viewCount;
  final String premiumCount;

  UserModel({
    required this.id,
     required this.adminId,
    required this.username,
    required this.typeTitle,
    this.img,
    required this.name,
    required this.blok,
    required this.rating,
    required this.userStatusChanging,
    required this.productCount,
    required this.viewCount,
    required this.premiumCount,
  });

  // CORRECTED factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
       adminId: json['admin_id'] as int,
      username: json['username'] as String,
      // SAFELY convert numbers and nulls to String
      typeTitle: json['type_title'].toString(),
      img: json['img_url'] as String?, // Keep this, it's safer
      // Handle potential null value for name
      name: json['name']?.toString() ?? 'Unnamed User', // Provide a default value if name is null
      blok: json['blok'] as bool,
      rating: json['rating'].toString(),
      userStatusChanging: json['user_status_changing'].toString(),
      // Safely convert all count fields to String
      productCount: json['productcount'].toString(),
      viewCount: json['viewcount'].toString(),
      premiumCount: json['premiumcount'].toString(),
    );
  }
}
