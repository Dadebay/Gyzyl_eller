class AboutApiResponse {
  final List<AboutResult> results;

  AboutApiResponse({
    required this.results,
  });

  factory AboutApiResponse.fromJson(Map<String, dynamic> json) => AboutApiResponse(
        results: List<AboutResult>.from(json["results"].map((x) => AboutResult.fromJson(x))),
      );
}

class AboutResult {
  final int id;
  final String content;
  final String content_ru;

  AboutResult({
    required this.id,
    required this.content,
    required this.content_ru,
  });

  factory AboutResult.fromJson(Map<String, dynamic> json) => AboutResult(
        id: json["id"],
        content: json["content"],
        content_ru: json["content_ru"],
      );
}
