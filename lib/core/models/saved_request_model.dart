class SavedRequestModel {
  final int id;
  final String comment;

  SavedRequestModel({required this.id, required this.comment});

  factory SavedRequestModel.fromJson(Map<String, dynamic> json) {
    return SavedRequestModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}
