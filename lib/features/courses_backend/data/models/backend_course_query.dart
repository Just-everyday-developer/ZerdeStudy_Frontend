import 'package:flutter/foundation.dart';

@immutable
class BackendCourseQuery {
  const BackendCourseQuery({
    this.minRating,
    this.levelCode,
    this.statusCode = 'published',
    this.durationCode,
    this.topicCode,
  });

  final double? minRating;
  final String? levelCode;
  final String statusCode;
  final String? durationCode;
  final String? topicCode;

  Map<String, String> get queryParameters {
    return <String, String>{
      if (minRating != null && minRating! > 0) 'min_rating': '$minRating',
      if (levelCode != null && levelCode!.trim().isNotEmpty)
        'level': levelCode!.trim(),
      if (statusCode.trim().isNotEmpty) 'status': statusCode.trim(),
      if (durationCode != null && durationCode!.trim().isNotEmpty)
        'duration_category': durationCode!.trim(),
      if (topicCode != null && topicCode!.trim().isNotEmpty)
        'topic': topicCode!.trim(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is BackendCourseQuery &&
        other.minRating == minRating &&
        other.levelCode == levelCode &&
        other.statusCode == statusCode &&
        other.durationCode == durationCode &&
        other.topicCode == topicCode;
  }

  @override
  int get hashCode =>
      Object.hash(minRating, levelCode, statusCode, durationCode, topicCode);
}
