/// Course progress returned by GET /api/v1/course/:id/progress,
/// GET /api/v1/progress, and POST /api/v1/lesson/:id/complete.
class BackendCourseProgressDto {
  const BackendCourseProgressDto({
    required this.courseId,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.completedLessonIds,
    required this.passedQuizIds,
  });

  final String courseId;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;
  final List<String> completedLessonIds;
  final List<String> passedQuizIds;

  factory BackendCourseProgressDto.fromJson(Map<String, dynamic> json) {
    List<String> ids(String key) {
      final raw = json[key];
      if (raw is List) {
        return raw.map((e) => '$e').toList(growable: false);
      }
      return const <String>[];
    }

    return BackendCourseProgressDto(
      courseId: '${json['course_id'] ?? ''}',
      totalLessons: (json['total_lessons'] as num?)?.round() ?? 0,
      completedLessons: (json['completed_lessons'] as num?)?.round() ?? 0,
      progressPercent: (json['progress_percent'] as num?)?.round() ?? 0,
      completedLessonIds: ids('completed_lesson_ids'),
      passedQuizIds: ids('passed_quiz_ids'),
    );
  }
}
