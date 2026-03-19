import 'app_locale.dart';
import 'app_theme_mode.dart';
import 'demo_models.dart';

class DemoAppState {
  const DemoAppState({
    required this.locale,
    required this.themeMode,
    required this.isAuthenticated,
    required this.user,
    required this.currentTrackId,
    required this.focusedLessonId,
    required this.focusedPracticeId,
    required this.completedLessonIds,
    required this.completedPracticeIds,
    required this.completedQuizIds,
    required this.completedTrainerIds,
    required this.quizAnswerStats,
    required this.assessmentResultsByTrackId,
    required this.assessmentAttemptHistory,
    required this.learningHistory,
    required this.viewedCommunityCourseIds,
    required this.savedCommunityCourseIds,
    required this.courseRatingsByCourseId,
    required this.enrolledCommunityCourseIds,
    required this.coursePlayerProgressByCourseId,
    required this.xp,
    required this.streak,
    required this.dailyMissionDone,
    required this.weeklyActivity,
    required this.aiMessages,
    required this.unlockedAchievementIds,
  });

  static const Object _sentinel = Object();
  static const int xpPerLevel = 180;

  final AppLocale locale;
  final AppThemeMode themeMode;
  final bool isAuthenticated;
  final DemoUser? user;
  final String currentTrackId;
  final String? focusedLessonId;
  final String? focusedPracticeId;
  final Set<String> completedLessonIds;
  final Set<String> completedPracticeIds;
  final Set<String> completedQuizIds;
  final Set<String> completedTrainerIds;
  final Map<String, QuizAnswerStat> quizAnswerStats;
  final Map<String, TrackAssessmentResult> assessmentResultsByTrackId;
  final List<AssessmentAttemptEntry> assessmentAttemptHistory;
  final List<LearningHistoryEntry> learningHistory;
  final Set<String> viewedCommunityCourseIds;
  final Set<String> savedCommunityCourseIds;
  final Map<String, int> courseRatingsByCourseId;
  final Set<String> enrolledCommunityCourseIds;
  final Map<String, CoursePlayerProgress> coursePlayerProgressByCourseId;
  final int xp;
  final int streak;
  final bool dailyMissionDone;
  final List<int> weeklyActivity;
  final List<AiMessage> aiMessages;
  final Set<String> unlockedAchievementIds;

  int get level => 1 + (xp ~/ xpPerLevel);

  int get xpIntoLevel => xp % xpPerLevel;

  int get xpToNextLevel {
    final remaining = xpPerLevel - xpIntoLevel;
    return remaining == 0 ? xpPerLevel : remaining;
  }

  int get totalQuizAttempts {
    return quizAnswerStats.values.fold<int>(0, (sum, stat) => sum + stat.attempts);
  }

  int get totalCorrectQuizAnswers {
    return quizAnswerStats.values
        .fold<int>(0, (sum, stat) => sum + stat.correctAnswers);
  }

  double get quizAccuracy {
    if (totalQuizAttempts == 0) {
      return 0;
    }
    return totalCorrectQuizAnswers / totalQuizAttempts;
  }

  DemoAppState copyWith({
    AppLocale? locale,
    AppThemeMode? themeMode,
    bool? isAuthenticated,
    Object? user = _sentinel,
    String? currentTrackId,
    Object? focusedLessonId = _sentinel,
    Object? focusedPracticeId = _sentinel,
    Set<String>? completedLessonIds,
    Set<String>? completedPracticeIds,
    Set<String>? completedQuizIds,
    Set<String>? completedTrainerIds,
    Map<String, QuizAnswerStat>? quizAnswerStats,
    Map<String, TrackAssessmentResult>? assessmentResultsByTrackId,
    List<AssessmentAttemptEntry>? assessmentAttemptHistory,
    List<LearningHistoryEntry>? learningHistory,
    Set<String>? viewedCommunityCourseIds,
    Set<String>? savedCommunityCourseIds,
    Map<String, int>? courseRatingsByCourseId,
    Set<String>? enrolledCommunityCourseIds,
    Map<String, CoursePlayerProgress>? coursePlayerProgressByCourseId,
    int? xp,
    int? streak,
    bool? dailyMissionDone,
    List<int>? weeklyActivity,
    List<AiMessage>? aiMessages,
    Set<String>? unlockedAchievementIds,
  }) {
    return DemoAppState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: identical(user, _sentinel) ? this.user : user as DemoUser?,
      currentTrackId: currentTrackId ?? this.currentTrackId,
      focusedLessonId: identical(focusedLessonId, _sentinel)
          ? this.focusedLessonId
          : focusedLessonId as String?,
      focusedPracticeId: identical(focusedPracticeId, _sentinel)
          ? this.focusedPracticeId
          : focusedPracticeId as String?,
      completedLessonIds:
          completedLessonIds ?? Set<String>.from(this.completedLessonIds),
      completedPracticeIds:
          completedPracticeIds ?? Set<String>.from(this.completedPracticeIds),
      completedQuizIds: completedQuizIds ?? Set<String>.from(this.completedQuizIds),
      completedTrainerIds:
          completedTrainerIds ?? Set<String>.from(this.completedTrainerIds),
      quizAnswerStats:
          quizAnswerStats ?? Map<String, QuizAnswerStat>.from(this.quizAnswerStats),
      assessmentResultsByTrackId: assessmentResultsByTrackId ??
          Map<String, TrackAssessmentResult>.from(this.assessmentResultsByTrackId),
      assessmentAttemptHistory: assessmentAttemptHistory ??
          List<AssessmentAttemptEntry>.from(this.assessmentAttemptHistory),
      learningHistory:
          learningHistory ?? List<LearningHistoryEntry>.from(this.learningHistory),
      viewedCommunityCourseIds: viewedCommunityCourseIds ??
          Set<String>.from(this.viewedCommunityCourseIds),
      savedCommunityCourseIds:
          savedCommunityCourseIds ?? Set<String>.from(this.savedCommunityCourseIds),
      courseRatingsByCourseId:
          courseRatingsByCourseId ?? Map<String, int>.from(this.courseRatingsByCourseId),
      enrolledCommunityCourseIds: enrolledCommunityCourseIds ??
          Set<String>.from(this.enrolledCommunityCourseIds),
      coursePlayerProgressByCourseId: coursePlayerProgressByCourseId ??
          Map<String, CoursePlayerProgress>.from(this.coursePlayerProgressByCourseId),
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      dailyMissionDone: dailyMissionDone ?? this.dailyMissionDone,
      weeklyActivity: weeklyActivity ?? List<int>.from(this.weeklyActivity),
      aiMessages: aiMessages ?? List<AiMessage>.from(this.aiMessages),
      unlockedAchievementIds:
          unlockedAchievementIds ?? Set<String>.from(this.unlockedAchievementIds),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'locale': locale.code,
      'themeMode': themeMode.code,
      'isAuthenticated': isAuthenticated,
      'user': user?.toJson(),
      'currentTrackId': currentTrackId,
      'focusedLessonId': focusedLessonId,
      'focusedPracticeId': focusedPracticeId,
      'completedLessonIds': completedLessonIds.toList(),
      'completedPracticeIds': completedPracticeIds.toList(),
      'completedQuizIds': completedQuizIds.toList(),
      'completedTrainerIds': completedTrainerIds.toList(),
      'quizAnswerStats': quizAnswerStats.map<String, dynamic>(
        (key, value) => MapEntry<String, dynamic>(key, value.toJson()),
      ),
      'assessmentResultsByTrackId': assessmentResultsByTrackId.map<String, dynamic>(
        (key, value) => MapEntry<String, dynamic>(key, value.toJson()),
      ),
      'assessmentAttemptHistory':
          assessmentAttemptHistory.map((attempt) => attempt.toJson()).toList(),
      'learningHistory':
          learningHistory.map((entry) => entry.toJson()).toList(),
      'viewedCommunityCourseIds': viewedCommunityCourseIds.toList(),
      'savedCommunityCourseIds': savedCommunityCourseIds.toList(),
      'courseRatingsByCourseId': courseRatingsByCourseId,
      'enrolledCommunityCourseIds': enrolledCommunityCourseIds.toList(),
      'coursePlayerProgressByCourseId': coursePlayerProgressByCourseId.map<String, dynamic>(
        (key, value) => MapEntry<String, dynamic>(key, value.toJson()),
      ),
      'xp': xp,
      'streak': streak,
      'dailyMissionDone': dailyMissionDone,
      'weeklyActivity': weeklyActivity,
      'aiMessages': aiMessages.map((message) => message.toJson()).toList(),
      'unlockedAchievementIds': unlockedAchievementIds.toList(),
    };
  }

  factory DemoAppState.fromJson(Map<String, dynamic> json) {
    return DemoAppState(
      locale: AppLocale.fromCode(json['locale'] as String?),
      themeMode: AppThemeMode.fromCode(json['themeMode'] as String?),
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      user: json['user'] is Map<String, dynamic>
          ? DemoUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      currentTrackId: json['currentTrackId'] as String? ?? 'fundamentals',
      focusedLessonId: json['focusedLessonId'] as String?,
      focusedPracticeId: json['focusedPracticeId'] as String?,
      completedLessonIds: Set<String>.from(
        (json['completedLessonIds'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      ),
      completedPracticeIds: Set<String>.from(
        (json['completedPracticeIds'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      ),
      completedQuizIds: Set<String>.from(
        (json['completedQuizIds'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      ),
      completedTrainerIds: Set<String>.from(
        (json['completedTrainerIds'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      ),
      quizAnswerStats: (json['quizAnswerStats'] as Map<String, dynamic>? ??
              <String, dynamic>{})
          .map<String, QuizAnswerStat>(
        (key, value) => MapEntry<String, QuizAnswerStat>(
          key,
          QuizAnswerStat.fromJson(value as Map<String, dynamic>),
        ),
      ),
      assessmentResultsByTrackId:
          (json['assessmentResultsByTrackId'] as Map<String, dynamic>? ??
                  <String, dynamic>{})
              .map<String, TrackAssessmentResult>(
        (key, value) => MapEntry<String, TrackAssessmentResult>(
          key,
          TrackAssessmentResult.fromJson(value as Map<String, dynamic>),
        ),
      ),
      assessmentAttemptHistory:
          (json['assessmentAttemptHistory'] as List<dynamic>? ?? <dynamic>[])
              .map(
                (attempt) => AssessmentAttemptEntry.fromJson(
                  attempt as Map<String, dynamic>,
                ),
              )
              .toList(),
      learningHistory: (json['learningHistory'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (entry) => LearningHistoryEntry.fromJson(
              entry as Map<String, dynamic>,
            ),
          )
          .toList(),
      viewedCommunityCourseIds: Set<String>.from(
        (json['viewedCommunityCourseIds'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      ),
      savedCommunityCourseIds: Set<String>.from(
        (json['savedCommunityCourseIds'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      ),
      courseRatingsByCourseId:
          (json['courseRatingsByCourseId'] as Map<String, dynamic>? ??
                  <String, dynamic>{})
              .map<String, int>(
        (key, value) => MapEntry<String, int>(key, value as int? ?? 0),
      ),
      enrolledCommunityCourseIds: Set<String>.from(
        (json['enrolledCommunityCourseIds'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      ),
      coursePlayerProgressByCourseId:
          (json['coursePlayerProgressByCourseId'] as Map<String, dynamic>? ??
                  <String, dynamic>{})
              .map<String, CoursePlayerProgress>(
        (key, value) => MapEntry<String, CoursePlayerProgress>(
          key,
          CoursePlayerProgress.fromJson(value as Map<String, dynamic>),
        ),
      ),
      xp: json['xp'] as int? ?? 240,
      streak: json['streak'] as int? ?? 4,
      dailyMissionDone: json['dailyMissionDone'] as bool? ?? false,
      weeklyActivity: List<int>.from(
        (json['weeklyActivity'] as List<dynamic>? ??
                <dynamic>[2, 4, 3, 5, 4, 6, 2])
            .cast<int>(),
      ),
      aiMessages: (json['aiMessages'] as List<dynamic>? ?? <dynamic>[])
          .map((message) => AiMessage.fromJson(message as Map<String, dynamic>))
          .toList(),
      unlockedAchievementIds: Set<String>.from(
        (json['unlockedAchievementIds'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      ),
    );
  }
}
