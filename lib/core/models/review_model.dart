import 'package:gyzyleller/core/services/api_constants.dart';

/// Professional profile review model – mirrors the API response from
/// `master-reviews/{userId}`.
class ReviewModel {
  final String id;
  final String userId;
  final String jobId;
  final String review;
  final int rating;
  final String requestId;
  final DateTime createdAt;
  final String username;
  final String? image;
  final List<ReviewReply> replies;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.review,
    required this.rating,
    required this.requestId,
    required this.createdAt,
    required this.username,
    this.image,
    this.replies = const [],
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Build absolute image URL if the path is relative.
    String? rawImage = json['image']?.toString();
    if (rawImage != null && rawImage.isNotEmpty && !rawImage.startsWith('http')) {
      if (rawImage.startsWith('/')) rawImage = rawImage.substring(1);
      rawImage = '${ApiConstants.imageURL}$rawImage';
    }

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      review: json['review']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      requestId: json['request_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      username: json['username']?.toString() ?? '',
      image: rawImage,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => ReviewReply.fromJson(e))
              .toList() ??
          const [],
    );
  }
}

/// A reply posted by the master (profile owner) to a specific review.
class ReviewReply {
  final String id;
  final String reviewId;
  final String reply;
  final DateTime createdAt;

  ReviewReply({
    required this.id,
    required this.reviewId,
    required this.reply,
    required this.createdAt,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id']?.toString() ?? '',
      reviewId: json['review_id']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
