class JobDetailModel {
  final String date;
  final String shortTitle;
  final String additionalInfoTitle;
  final String additionalInfoContent;
  final String neededTitle;
  final String neededContent;
  final List<String> files;
  final List<String> images;

  JobDetailModel({
    required this.date,
    required this.shortTitle,
    required this.additionalInfoTitle,
    required this.additionalInfoContent,
    required this.neededTitle,
    required this.neededContent,
    required this.files,
    required this.images,
  });

  factory JobDetailModel.fromJson(Map<String, dynamic> json) {
    return JobDetailModel(
      date: json['date'] ?? '',
      shortTitle: json['shortTitle'] ?? '',
      additionalInfoTitle: json['additionalInfoTitle'] ?? '',
      additionalInfoContent: json['additionalInfoContent'] ?? '',
      neededTitle: json['neededTitle'] ?? '',
      neededContent: json['neededContent'] ?? '',
      files: List<String>.from(json['files'] ?? []),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'shortTitle': shortTitle,
      'additionalInfoTitle': additionalInfoTitle,
      'additionalInfoContent': additionalInfoContent,
      'neededTitle': neededTitle,
      'neededContent': neededContent,
      'files': files,
      'images': images,
    };
  }
}
