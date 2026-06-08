/// Mirrors curriculum-service's `studentstats.Statistics` — the aggregated
/// payload returned by `GET /api/v1/student/statistics`.
class BackendStudentStatisticsDto {
  const BackendStudentStatisticsDto({
    required this.summary,
    required this.quiz,
    required this.practice,
    required this.activity,
    required this.topics,
    required this.courseProgress,
  });

  final BackendStudentSummaryDto summary;
  final BackendStudentQuizStatsDto quiz;
  final BackendStudentPracticeStatsDto practice;
  final List<BackendStudentActivityDayDto> activity;
  final List<BackendStudentTopicProgressDto> topics;
  final List<BackendStudentCourseDetailDto> courseProgress;

  factory BackendStudentStatisticsDto.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = json[key] as List<dynamic>? ?? const <dynamic>[];
      return raw
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }

    return BackendStudentStatisticsDto(
      summary: BackendStudentSummaryDto.fromJson(
        (json['summary'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      quiz: BackendStudentQuizStatsDto.fromJson(
        (json['quiz'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      practice: BackendStudentPracticeStatsDto.fromJson(
        (json['practice'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      activity: parseList('activity', BackendStudentActivityDayDto.fromJson),
      topics: parseList('topics', BackendStudentTopicProgressDto.fromJson),
      courseProgress: parseList(
        'courseProgress',
        BackendStudentCourseDetailDto.fromJson,
      ),
    );
  }
}

class BackendStudentSummaryDto {
  const BackendStudentSummaryDto({
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.maxStreak,
    required this.startedCourses,
    required this.activeCourses,
    required this.completedCourses,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.certificates,
    required this.achievements,
    required this.totalAchievements,
  });

  final int totalXp;
  final int level;
  final int currentStreak;
  final int maxStreak;
  final int startedCourses;
  final int activeCourses;
  final int completedCourses;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;
  final int certificates;
  final int achievements;
  final int totalAchievements;

  factory BackendStudentSummaryDto.fromJson(Map<String, dynamic> json) {
    int asInt(String key) => (json[key] as num?)?.round() ?? 0;
    return BackendStudentSummaryDto(
      totalXp: asInt('total_xp'),
      level: asInt('level'),
      currentStreak: asInt('current_streak'),
      maxStreak: asInt('max_streak'),
      startedCourses: asInt('started_courses'),
      activeCourses: asInt('active_courses'),
      completedCourses: asInt('completed_courses'),
      totalLessons: asInt('total_lessons'),
      completedLessons: asInt('completed_lessons'),
      progressPercent: asInt('progress_percent'),
      certificates: asInt('certificates'),
      achievements: asInt('achievements'),
      totalAchievements: asInt('total_achievements'),
    );
  }
}

class BackendStudentQuizStatsDto {
  const BackendStudentQuizStatsDto({
    required this.attemptedQuizzes,
    required this.passedQuizzes,
    required this.accuracyPercent,
  });

  final int attemptedQuizzes;
  final int passedQuizzes;
  final int accuracyPercent;

  factory BackendStudentQuizStatsDto.fromJson(Map<String, dynamic> json) {
    return BackendStudentQuizStatsDto(
      attemptedQuizzes: (json['attempted_quizzes'] as num?)?.round() ?? 0,
      passedQuizzes: (json['passed_quizzes'] as num?)?.round() ?? 0,
      accuracyPercent: (json['accuracy_percent'] as num?)?.round() ?? 0,
    );
  }
}

class BackendStudentPracticeStatsDto {
  const BackendStudentPracticeStatsDto({
    required this.runs,
    required this.submissions,
    required this.successfulSubmits,
    required this.attemptedPractices,
    required this.completedPractices,
    required this.passRatePercent,
    required this.xpEarned,
  });

  final int runs;
  final int submissions;
  final int successfulSubmits;
  final int attemptedPractices;
  final int completedPractices;
  final int passRatePercent;
  final int xpEarned;

  factory BackendStudentPracticeStatsDto.fromJson(Map<String, dynamic> json) {
    int asInt(String key) => (json[key] as num?)?.round() ?? 0;
    return BackendStudentPracticeStatsDto(
      runs: asInt('runs'),
      submissions: asInt('submissions'),
      successfulSubmits: asInt('successful_submits'),
      attemptedPractices: asInt('attempted_practices'),
      completedPractices: asInt('completed_practices'),
      passRatePercent: asInt('pass_rate_percent'),
      xpEarned: asInt('xp_earned'),
    );
  }
}

class BackendStudentActivityDayDto {
  const BackendStudentActivityDayDto({
    required this.date,
    required this.lessonsCompleted,
    required this.quizzesPassed,
    required this.practiceAttempts,
    required this.practiceCompleted,
    required this.xp,
  });

  final String date;
  final int lessonsCompleted;
  final int quizzesPassed;
  final int practiceAttempts;
  final int practiceCompleted;
  final int xp;

  factory BackendStudentActivityDayDto.fromJson(Map<String, dynamic> json) {
    int asInt(String key) => (json[key] as num?)?.round() ?? 0;
    return BackendStudentActivityDayDto(
      date: '${json['date'] ?? ''}',
      lessonsCompleted: asInt('lessons_completed'),
      quizzesPassed: asInt('quizzes_passed'),
      practiceAttempts: asInt('practice_attempts'),
      practiceCompleted: asInt('practice_completed'),
      xp: asInt('xp'),
    );
  }
}

class BackendStudentTopicProgressDto {
  const BackendStudentTopicProgressDto({
    required this.topicId,
    required this.code,
    required this.name,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.xp,
  });

  final String topicId;
  final String code;
  final String name;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;
  final int xp;

  factory BackendStudentTopicProgressDto.fromJson(Map<String, dynamic> json) {
    int asInt(String key) => (json[key] as num?)?.round() ?? 0;
    return BackendStudentTopicProgressDto(
      topicId: '${json['topic_id'] ?? ''}',
      code: '${json['code'] ?? ''}',
      name: '${json['name'] ?? ''}',
      totalLessons: asInt('total_lessons'),
      completedLessons: asInt('completed_lessons'),
      progressPercent: asInt('progress_percent'),
      xp: asInt('xp'),
    );
  }
}

class BackendStudentCourseDetailDto {
  const BackendStudentCourseDetailDto({
    required this.courseId,
    required this.title,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.practiceRuns,
    required this.practiceCompleted,
  });

  final String courseId;
  final String title;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;
  final int practiceRuns;
  final int practiceCompleted;

  factory BackendStudentCourseDetailDto.fromJson(Map<String, dynamic> json) {
    int asInt(String key) => (json[key] as num?)?.round() ?? 0;
    return BackendStudentCourseDetailDto(
      courseId: '${json['course_id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      totalLessons: asInt('total_lessons'),
      completedLessons: asInt('completed_lessons'),
      progressPercent: asInt('progress_percent'),
      practiceRuns: asInt('practice_runs'),
      practiceCompleted: asInt('practice_completed'),
    );
  }
}
