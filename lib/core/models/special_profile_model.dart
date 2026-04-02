class SpecialProfileModel {
  final String? id;
  final String? userId;
  final String? name;
  final String? imageUrl;
  final String? shortBio;
  final String? longBio;
  final String? legalizationType;
  final String? experience;
  final int? welayatId;
  final int? etrapId;
  final String welayat;
  final String etrap;
  final List<String> serverImages;
  final num rating;
  final int reviewCount;
  final String createdAt;
  final int doneJobsCount;
  final int totalJobsCount;

  SpecialProfileModel({
    this.id,
    this.userId,
    this.name,
    this.imageUrl,
    this.shortBio,
    this.longBio,
    this.legalizationType,
    this.experience,
    this.welayatId,
    this.etrapId,
    this.welayat = '',
    this.etrap = '',
    this.serverImages = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt = '',
    this.doneJobsCount = 0,
    this.totalJobsCount = 0,
  });

  factory SpecialProfileModel.fromJson(Map<String, dynamic> json) {
    return SpecialProfileModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      name: json['username'],
      imageUrl: json['image'],
      shortBio: json['short_description'],
      longBio: json['description'],
      legalizationType: json['legalization_type'],
      experience: json['experience'],
      welayatId: int.tryParse(json['welayat_id']?.toString() ?? ''),
      etrapId: int.tryParse(json['etrap_id']?.toString() ?? ''),
      welayat: json['welayat']?.toString() ?? '',
      etrap: json['etrap']?.toString() ?? '',
      serverImages: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rating: num.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      doneJobsCount: (json['done_jobs_count'] as num?)?.toInt() ?? 0,
      totalJobsCount: (json['jobs_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': name,
      'image': imageUrl,
      'short_description': shortBio,
      'description': longBio,
      'legalization_type': legalizationType,
      'experience': experience,
      'welayat_id': welayatId,
      'etrap_id': etrapId,
      'welayat': welayat,
      'etrap': etrap,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt,
      'done_jobs_count': doneJobsCount,
      'jobs_count': totalJobsCount,
    };
  }

  SpecialProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? imageUrl,
    String? shortBio,
    String? longBio,
    String? legalizationType,
    String? experience,
    int? welayatId,
    int? etrapId,
    String? welayat,
    String? etrap,
    List<String>? serverImages,
    num? rating,
    int? reviewCount,
    String? createdAt,
    int? doneJobsCount,
    int? totalJobsCount,
  }) {
    return SpecialProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      shortBio: shortBio ?? this.shortBio,
      longBio: longBio ?? this.longBio,
      legalizationType: legalizationType ?? this.legalizationType,
      experience: experience ?? this.experience,
      welayatId: welayatId ?? this.welayatId,
      etrapId: etrapId ?? this.etrapId,
      welayat: welayat ?? this.welayat,
      etrap: etrap ?? this.etrap,
      serverImages: serverImages ?? this.serverImages,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      doneJobsCount: doneJobsCount ?? this.doneJobsCount,
      totalJobsCount: totalJobsCount ?? this.totalJobsCount,
    );
  }
}
