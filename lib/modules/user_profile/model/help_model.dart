// Gelen tüm yanıtı temsil eden ana model
class HelpApiResponse {
  final List<HelpResult> results;

  HelpApiResponse({
    required this.results,
  });

  factory HelpApiResponse.fromJson(Map<String, dynamic> json) => HelpApiResponse(
        results: List<HelpResult>.from(json["results"].map((x) => HelpResult.fromJson(x))),
      );
}

class HelpResult {
  final int id;
  final String titleTm;
  final String titleRu;
  final String titleEn;
  final String subtitleTm;
  final String subtitleRu;
  final String subtitleEn;
  final String? img;

  HelpResult({
    required this.id,
    required this.titleTm,
    required this.titleRu,
    required this.titleEn,
    required this.subtitleTm,
    required this.subtitleRu,
    required this.subtitleEn,
    this.img,
  });

  factory HelpResult.fromJson(Map<String, dynamic> json) => HelpResult(
        id: json["id"],
        titleTm: json["title_tm"],
        titleRu: json["title_ru"],
        titleEn: json["title_en"],
        subtitleTm: json["subtitle_tm"],
        subtitleRu: json["subtitle_ru"],
        subtitleEn: json["subtitle_en"],
        img: json["img"],
      );
}
