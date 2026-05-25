class BackendReviewDto {
  const BackendReviewDto({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String courseId;
  final String userId;
  final int rating;
  final String comment;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BackendReviewDto.fromJson(Map<String, dynamic> json) {
    return BackendReviewDto(
      id: '${json['id'] ?? ''}',
      courseId: '${json['course_id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      rating: (json['rating'] as num?)?.round() ?? 0,
      comment: json['comment'] as String? ?? '',
      viewCount: (json['view_count'] as num?)?.round() ?? 0,
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class BackendCreateReviewRequest {
  const BackendCreateReviewRequest({
    required this.courseId,
    required this.userId,
    required this.rating,
    this.comment = '',
  });

  final String courseId;
  final String userId;
  final int rating;
  final String comment;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'course_id': courseId.trim(),
    'user_id': userId.trim(),
    'rating': rating.clamp(1, 5),
    'comment': comment.trim(),
  };
}

class BackendUpdateReviewRequest {
  const BackendUpdateReviewRequest({
    required this.rating,
    this.comment = '',
  });

  final int rating;
  final String comment;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'rating': rating.clamp(1, 5),
    'comment': comment.trim(),
  };
}
