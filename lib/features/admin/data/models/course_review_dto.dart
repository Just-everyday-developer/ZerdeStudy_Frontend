import 'package:flutter/foundation.dart';

@immutable
class PendingCourseDto {
  const PendingCourseDto({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.category,
    required this.difficulty,
    required this.isChecked,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String authorId;
  final String category;
  final String difficulty;
  final bool isChecked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PendingCourseDto.fromJson(Map<String, dynamic> json) {
    return PendingCourseDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      isChecked: json['is_checked'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime(2000);
    return DateTime(2000);
  }
}

@immutable
class CourseReviewResultDto {
  const CourseReviewResultDto({
    required this.courseId,
    required this.title,
    required this.isChecked,
    required this.isApproved,
    required this.reviewStatus,
    this.comment,
    this.reviewedBy,
    this.reviewedAt,
  });

  final String courseId;
  final String title;
  final bool isChecked;
  final bool isApproved;
  final String reviewStatus;
  final String? comment;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  factory CourseReviewResultDto.fromJson(Map<String, dynamic> json) {
    return CourseReviewResultDto(
      courseId: json['course_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isChecked: json['is_checked'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? false,
      reviewStatus: json['review_status'] as String? ?? '',
      comment: json['comment'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] is String
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
    );
  }
}
