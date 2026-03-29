class SpecialProfileModel {
  final String? id;
  final String? name;
  final String? imageUrl;
  final String? shortBio;
  final String? longBio;
  final String? legalizationType;
  final int? welayatId;
  final int? etrapId;
  final List<String> serverImages;

  SpecialProfileModel({
    this.id,
    this.name,
    this.imageUrl,
    this.shortBio,
    this.longBio,
    this.legalizationType,
    this.welayatId,
    this.etrapId,
    this.serverImages = const [],
  });

  factory SpecialProfileModel.fromJson(Map<String, dynamic> json) {
    return SpecialProfileModel(
      id: json['id']?.toString(),
      name: json['username'],
      imageUrl: json['image'],
      shortBio: json['short_description'],
      longBio: json['description'],
      legalizationType: json['legalization_type'],
      welayatId: int.tryParse(json['welayat_id']?.toString() ?? ''),
      etrapId: int.tryParse(json['etrap_id']?.toString() ?? ''),
      serverImages: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'image': imageUrl,
      'short_description': shortBio,
      'description': longBio,
      'legalization_type': legalizationType,
      'welayat_id': welayatId,
      'etrap_id': etrapId,
    };
  }

  SpecialProfileModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? shortBio,
    String? longBio,
    String? legalizationType,
    int? welayatId,
    int? etrapId,
    List<String>? serverImages,
  }) {
    return SpecialProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      shortBio: shortBio ?? this.shortBio,
      longBio: longBio ?? this.longBio,
      legalizationType: legalizationType ?? this.legalizationType,
      welayatId: welayatId ?? this.welayatId,
      etrapId: etrapId ?? this.etrapId,
      serverImages: serverImages ?? this.serverImages,
    );
  }
}
