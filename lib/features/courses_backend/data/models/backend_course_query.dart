import 'package:flutter/foundation.dart';

@immutable
class BackendCourseQuery {
  const BackendCourseQuery({
    this.search,
    this.minRating,
    this.levelCode,
    this.statusCode = 'published',
    this.durationCode,
    this.topicCode,
    this.hasCertificate,
    this.limit = 20,
  });

  final String? search;
  final double? minRating;
  final String? levelCode;
  final String statusCode;
  final String? durationCode;
  final String? topicCode;
  final bool? hasCertificate;
  final int limit;

  Map<String, String> get queryParameters {
    return <String, String>{
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (minRating != null && minRating! > 0) 'min_rating': '$minRating',
      if (levelCode != null && levelCode!.trim().isNotEmpty)
        'level': levelCode!.trim(),
      if (statusCode.trim().isNotEmpty) 'status': statusCode.trim(),
      if (durationCode != null && durationCode!.trim().isNotEmpty)
        'duration_category': durationCode!.trim(),
      if (topicCode != null && topicCode!.trim().isNotEmpty)
        'topic': topicCode!.trim(),
      if (hasCertificate != null)
        'has_certificate': hasCertificate! ? 'true' : 'false',
      if (limit > 0) 'limit': '$limit',
    };
  }

  @override
  bool operator ==(Object other) {
    return other is BackendCourseQuery &&
        other.search == search &&
        other.minRating == minRating &&
        other.levelCode == levelCode &&
        other.statusCode == statusCode &&
        other.durationCode == durationCode &&
        other.topicCode == topicCode &&
        other.hasCertificate == hasCertificate &&
        other.limit == limit;
  }

  @override
  int get hashCode =>
      Object.hash(
        search,
        minRating,
        levelCode,
        statusCode,
        durationCode,
        topicCode,
        hasCertificate,
        limit,
      );
}
