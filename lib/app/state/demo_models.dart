import 'package:flutter/material.dart';

import 'app_locale.dart';

class LocalizedText {
  const LocalizedText({
    required this.ru,
    required this.en,
    required this.kk,
  });

  final String ru;
  final String en;
  final String kk;

  String resolve(AppLocale locale) {
    switch (locale) {
      case AppLocale.ru:
        return ru;
      case AppLocale.en:
        return en;
      case AppLocale.kk:
        return kk;
    }
  }
}

class DemoUser {
  const DemoUser({
    required this.name,
    required this.email,
    required this.role,
    required this.goal,
  });

  final String name;
  final String email;
  final String role;
  final String goal;

  DemoUser copyWith({
    String? name,
    String? email,
    String? role,
    String? goal,
  }) {
    return DemoUser(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'role': role,
      'goal': goal,
    };
  }

  factory DemoUser.fromJson(Map<String, dynamic> json) {
    return DemoUser(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
    );
  }
}

enum AiAuthor { user, mentor }

class AiMessage {
  const AiMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final AiAuthor author;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'author': author.name,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] as String? ?? '',
      author: AiAuthor.values.firstWhere(
        (author) => author.name == json['author'],
        orElse: () => AiAuthor.user,
      ),
      text: json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.goal,
    required this.progress,
    required this.unlocked,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final IconData icon;
  final int goal;
  final int progress;
  final bool unlocked;

  Achievement copyWith({
    int? progress,
    bool? unlocked,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      goal: goal,
      progress: progress ?? this.progress,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  double get fraction {
    if (goal == 0) {
      return 1;
    }
    return (progress / goal).clamp(0, 1).toDouble();
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.xp,
    required this.level,
    required this.role,
    required this.focus,
    required this.isCurrentUser,
  });

  final String id;
  final String name;
  final int xp;
  final int level;
  final String role;
  final String focus;
  final bool isCurrentUser;
}

enum QuizKind { outputPrediction, conceptCheck }

class QuizOption {
  const QuizOption({
    required this.id,
    required this.label,
  });

  final String id;
  final LocalizedText label;
}

class TrackAssessmentOption {
  const TrackAssessmentOption({
    required this.id,
    required this.label,
  });

  final String id;
  final LocalizedText label;
}

class TrackAssessmentQuestion {
  const TrackAssessmentQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
  });

  final String id;
  final LocalizedText prompt;
  final List<TrackAssessmentOption> options;
  final String correctOptionId;
  final LocalizedText explanation;
}

class TrackAssessment {
  const TrackAssessment({
    required this.id,
    required this.trackId,
    required this.title,
    required this.summary,
    required this.passPercent,
    required this.questions,
  });

  final String id;
  final String trackId;
  final LocalizedText title;
  final LocalizedText summary;
  final int passPercent;
  final List<TrackAssessmentQuestion> questions;
}

class LessonQuiz {
  const LessonQuiz({
    required this.id,
    required this.title,
    required this.prompt,
    required this.kind,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText prompt;
  final QuizKind kind;
  final List<QuizOption> options;
  final String correctOptionId;
  final LocalizedText explanation;
}

enum CodeTrainerKind { fillBlank, reorderLines, matchOutput }

class CodeTrainer {
  const CodeTrainer({
    required this.id,
    required this.title,
    required this.instruction,
    required this.kind,
    required this.prompt,
    required this.options,
    this.template,
    this.correctOptionId,
    this.correctSequence = const <String>[],
  });

  final String id;
  final LocalizedText title;
  final LocalizedText instruction;
  final CodeTrainerKind kind;
  final String prompt;
  final List<QuizOption> options;
  final String? template;
  final String? correctOptionId;
  final List<String> correctSequence;
}

class LessonItem {
  const LessonItem({
    required this.id,
    required this.trackId,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.durationMinutes,
    required this.outcome,
    required this.codeSnippet,
    required this.exampleOutput,
    required this.keyPoints,
    required this.quizzes,
    required this.codeTrainers,
    required this.completionRequirements,
    required this.promptSuggestion,
    required this.xpReward,
  });

  final String id;
  final String trackId;
  final String moduleId;
  final LocalizedText title;
  final LocalizedText summary;
  final int durationMinutes;
  final LocalizedText outcome;
  final String codeSnippet;
  final String exampleOutput;
  final List<LocalizedText> keyPoints;
  final List<LessonQuiz> quizzes;
  final List<CodeTrainer> codeTrainers;
  final List<String> completionRequirements;
  final LocalizedText promptSuggestion;
  final int xpReward;
}

class PracticeTask {
  const PracticeTask({
    required this.id,
    required this.trackId,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.brief,
    required this.starterCode,
    required this.successCriteria,
    required this.knowledgeChecks,
    required this.promptSuggestion,
    required this.xpReward,
  });

  final String id;
  final String trackId;
  final String moduleId;
  final LocalizedText title;
  final LocalizedText summary;
  final LocalizedText brief;
  final String starterCode;
  final List<LocalizedText> successCriteria;
  final List<LocalizedText> knowledgeChecks;
  final LocalizedText promptSuggestion;
  final int xpReward;
}

class LearningModule {
  const LearningModule({
    required this.id,
    required this.trackId,
    required this.title,
    required this.summary,
    required this.lessons,
    required this.practice,
  });

  final String id;
  final String trackId;
  final LocalizedText title;
  final LocalizedText summary;
  final List<LessonItem> lessons;
  final PracticeTask? practice;

  int get totalUnits => lessons.length + (practice == null ? 0 : 1);
}

enum TrackZone { computerScienceCore, itSpheres }

enum TrackAvailability { available, inProgress, completed, mastered }

class KnowledgeTreeNodeSpec {
  const KnowledgeTreeNodeSpec({
    required this.id,
    required this.title,
    required this.position,
    required this.radius,
    this.trackId,
    this.subtitle,
    this.isHub = false,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText? subtitle;
  final Offset position;
  final double radius;
  final String? trackId;
  final bool isHub;
}

class KnowledgeTreeEdgeSpec {
  const KnowledgeTreeEdgeSpec({
    required this.fromNodeId,
    required this.toNodeId,
  });

  final String fromNodeId;
  final String toNodeId;
}

class LearningTrack {
  const LearningTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.teaser,
    required this.outcome,
    required this.heroMetric,
    required this.icon,
    required this.color,
    required this.zone,
    required this.availability,
    required this.order,
    required this.nodeId,
    required this.connections,
    required this.modules,
    this.assessment,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final LocalizedText description;
  final LocalizedText teaser;
  final LocalizedText outcome;
  final LocalizedText heroMetric;
  final IconData icon;
  final Color color;
  final TrackZone zone;
  final TrackAvailability availability;
  final int order;
  final String nodeId;
  final List<String> connections;
  final List<LearningModule> modules;
  final TrackAssessment? assessment;

  LearningTrack copyWith({
    TrackAssessment? assessment,
  }) {
    return LearningTrack(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      teaser: teaser,
      outcome: outcome,
      heroMetric: heroMetric,
      icon: icon,
      color: color,
      zone: zone,
      availability: availability,
      order: order,
      nodeId: nodeId,
      connections: connections,
      modules: modules,
      assessment: assessment ?? this.assessment,
    );
  }

  int get totalUnits {
    return modules.fold<int>(0, (sum, module) => sum + module.totalUnits);
  }

  int get totalQuizzes {
    return modules.fold<int>(
      0,
      (sum, module) => sum + module.lessons.fold<int>(0, (inner, lesson) => inner + lesson.quizzes.length),
    );
  }

  int get totalTrainers {
    return modules.fold<int>(
      0,
      (sum, module) => sum + module.lessons.fold<int>(0, (inner, lesson) => inner + lesson.codeTrainers.length),
    );
  }
}

class TrackProgress {
  const TrackProgress({
    required this.state,
    required this.completedUnits,
    required this.totalUnits,
    required this.completedQuizzes,
    required this.totalQuizzes,
    required this.completedTrainers,
    required this.totalTrainers,
    required this.nextTarget,
  });

  final TrackAvailability state;
  final int completedUnits;
  final int totalUnits;
  final int completedQuizzes;
  final int totalQuizzes;
  final int completedTrainers;
  final int totalTrainers;
  final LearningTarget? nextTarget;

  double get fraction {
    if (totalUnits == 0) {
      return 0;
    }
    return completedUnits / totalUnits;
  }
}

class AssessmentAttemptEntry {
  const AssessmentAttemptEntry({
    required this.trackId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percent,
    required this.passed,
    required this.completedAt,
  });

  final String trackId;
  final int correctAnswers;
  final int totalQuestions;
  final int percent;
  final bool passed;
  final DateTime completedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'trackId': trackId,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'percent': percent,
      'passed': passed,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory AssessmentAttemptEntry.fromJson(Map<String, dynamic> json) {
    return AssessmentAttemptEntry(
      trackId: json['trackId'] as String? ?? '',
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      percent: json['percent'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class TrackAssessmentResult {
  const TrackAssessmentResult({
    required this.trackId,
    required this.bestPercent,
    required this.lastPercent,
    required this.bestCorrectAnswers,
    required this.lastCorrectAnswers,
    required this.attemptCount,
    required this.lastAttemptAt,
    required this.lastPassed,
    required this.history,
  });

  final String trackId;
  final int bestPercent;
  final int lastPercent;
  final int bestCorrectAnswers;
  final int lastCorrectAnswers;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final bool lastPassed;
  final List<AssessmentAttemptEntry> history;

  TrackAssessmentResult copyWith({
    int? bestPercent,
    int? lastPercent,
    int? bestCorrectAnswers,
    int? lastCorrectAnswers,
    int? attemptCount,
    Object? lastAttemptAt = _trackAssessmentSentinel,
    bool? lastPassed,
    List<AssessmentAttemptEntry>? history,
  }) {
    return TrackAssessmentResult(
      trackId: trackId,
      bestPercent: bestPercent ?? this.bestPercent,
      lastPercent: lastPercent ?? this.lastPercent,
      bestCorrectAnswers: bestCorrectAnswers ?? this.bestCorrectAnswers,
      lastCorrectAnswers: lastCorrectAnswers ?? this.lastCorrectAnswers,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: identical(lastAttemptAt, _trackAssessmentSentinel)
          ? this.lastAttemptAt
          : lastAttemptAt as DateTime?,
      lastPassed: lastPassed ?? this.lastPassed,
      history: history ?? List<AssessmentAttemptEntry>.from(this.history),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'trackId': trackId,
      'bestPercent': bestPercent,
      'lastPercent': lastPercent,
      'bestCorrectAnswers': bestCorrectAnswers,
      'lastCorrectAnswers': lastCorrectAnswers,
      'attemptCount': attemptCount,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'lastPassed': lastPassed,
      'history': history.map((attempt) => attempt.toJson()).toList(),
    };
  }

  factory TrackAssessmentResult.fromJson(Map<String, dynamic> json) {
    return TrackAssessmentResult(
      trackId: json['trackId'] as String? ?? '',
      bestPercent: json['bestPercent'] as int? ?? 0,
      lastPercent: json['lastPercent'] as int? ?? 0,
      bestCorrectAnswers: json['bestCorrectAnswers'] as int? ?? 0,
      lastCorrectAnswers: json['lastCorrectAnswers'] as int? ?? 0,
      attemptCount: json['attemptCount'] as int? ?? 0,
      lastAttemptAt: DateTime.tryParse(json['lastAttemptAt'] as String? ?? ''),
      lastPassed: json['lastPassed'] as bool? ?? false,
      history: (json['history'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (attempt) => AssessmentAttemptEntry.fromJson(
              attempt as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

const Object _trackAssessmentSentinel = Object();

enum LearningHistoryKind {
  lessonCompleted,
  practiceCompleted,
  moduleCompleted,
  trackCompleted,
  assessmentCompleted,
  courseSaved,
  courseEnrolled,
  courseCompleted,
  certificateEarned,
}

class LearningHistoryEntry {
  const LearningHistoryEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.createdAt,
    this.subtitle,
    this.scoreLabel,
    this.trackId,
    this.refId,
  });

  final String id;
  final LearningHistoryKind kind;
  final String title;
  final String? subtitle;
  final String? scoreLabel;
  final DateTime createdAt;
  final String? trackId;
  final String? refId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'kind': kind.name,
      'title': title,
      'subtitle': subtitle,
      'scoreLabel': scoreLabel,
      'createdAt': createdAt.toIso8601String(),
      'trackId': trackId,
      'refId': refId,
    };
  }

  factory LearningHistoryEntry.fromJson(Map<String, dynamic> json) {
    return LearningHistoryEntry(
      id: json['id'] as String? ?? '',
      kind: LearningHistoryKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => LearningHistoryKind.lessonCompleted,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      scoreLabel: json['scoreLabel'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      trackId: json['trackId'] as String?,
      refId: json['refId'] as String?,
    );
  }
}

class LearningTarget {
  const LearningTarget.lesson(this.lesson)
      : practice = null,
        isPractice = false;

  const LearningTarget.practice(this.practice)
      : lesson = null,
        isPractice = true;

  final LessonItem? lesson;
  final PracticeTask? practice;
  final bool isPractice;

  String get id => isPractice ? practice!.id : lesson!.id;

  LocalizedText get title => isPractice ? practice!.title : lesson!.title;

  String get trackId => isPractice ? practice!.trackId : lesson!.trackId;
}

enum CourseDurationBucket {
  quick,
  focused,
  deep;

  String get code => name;

  static CourseDurationBucket fromHours(int hours) {
    if (hours <= 4) {
      return CourseDurationBucket.quick;
    }
    if (hours <= 8) {
      return CourseDurationBucket.focused;
    }
    return CourseDurationBucket.deep;
  }

  static CourseDurationBucket fromCode(String? code) {
    return CourseDurationBucket.values.firstWhere(
      (bucket) => bucket.code == code,
      orElse: () => CourseDurationBucket.focused,
    );
  }
}

enum CourseExerciseKind {
  singleChoice,
  multipleChoice,
  matching,
  dragDrop,
  fillBlank,
  codeInput,
}

enum CourseCertificateTier {
  standard,
  premium,
}

class CoursePlayerComment {
  const CoursePlayerComment({
    required this.id,
    required this.authorName,
    required this.role,
    required this.message,
  });

  final String id;
  final String authorName;
  final String role;
  final String message;
}

class CourseExerciseChoice {
  const CourseExerciseChoice({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class CoursePlayerExercise {
  const CoursePlayerExercise({
    required this.id,
    required this.kind,
    required this.title,
    required this.prompt,
    required this.points,
    this.description = '',
    this.choices = const <CourseExerciseChoice>[],
    this.correctChoiceIds = const <String>[],
    this.leftItems = const <String>[],
    this.rightItems = const <String>[],
    this.correctMatches = const <String, String>{},
    this.draggableItems = const <String>[],
    this.correctOrder = const <String>[],
    this.blankTemplate,
    this.correctText = '',
    this.codeTemplate,
    this.correctCodeToken = '',
  });

  final String id;
  final CourseExerciseKind kind;
  final LocalizedText title;
  final LocalizedText prompt;
  final int points;
  final String description;
  final List<CourseExerciseChoice> choices;
  final List<String> correctChoiceIds;
  final List<String> leftItems;
  final List<String> rightItems;
  final Map<String, String> correctMatches;
  final List<String> draggableItems;
  final List<String> correctOrder;
  final String? blankTemplate;
  final String correctText;
  final String? codeTemplate;
  final String correctCodeToken;
}

class CoursePlayerLesson {
  const CoursePlayerLesson({
    required this.id,
    required this.title,
    required this.annotation,
    required this.explanation,
    required this.objective,
    required this.videoLabel,
    required this.imageCaption,
    required this.codeSnippet,
    required this.exampleOutput,
    required this.comments,
    required this.exercises,
    required this.nextActionLabel,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText annotation;
  final LocalizedText explanation;
  final LocalizedText objective;
  final String videoLabel;
  final String imageCaption;
  final String codeSnippet;
  final String exampleOutput;
  final List<CoursePlayerComment> comments;
  final List<CoursePlayerExercise> exercises;
  final LocalizedText nextActionLabel;
}

class CoursePlayerModule {
  const CoursePlayerModule({
    required this.id,
    required this.title,
    required this.summary,
    required this.lessons,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText summary;
  final List<CoursePlayerLesson> lessons;
}

class CoursePlayerProgress {
  const CoursePlayerProgress({
    required this.courseId,
    required this.completedLessonIds,
    required this.attemptedExerciseIds,
    required this.correctExerciseIds,
    required this.incorrectExerciseIds,
    required this.earnedPoints,
    required this.enrolledAt,
    this.currentLessonId,
    this.lastOpenedAt,
    this.completedAt,
  });

  final String courseId;
  final Set<String> completedLessonIds;
  final Set<String> attemptedExerciseIds;
  final Set<String> correctExerciseIds;
  final Set<String> incorrectExerciseIds;
  final int earnedPoints;
  final DateTime enrolledAt;
  final String? currentLessonId;
  final DateTime? lastOpenedAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  CoursePlayerProgress copyWith({
    Set<String>? completedLessonIds,
    Set<String>? attemptedExerciseIds,
    Set<String>? correctExerciseIds,
    Set<String>? incorrectExerciseIds,
    int? earnedPoints,
    Object? currentLessonId = _coursePlayerProgressSentinel,
    DateTime? enrolledAt,
    Object? lastOpenedAt = _coursePlayerProgressSentinel,
    Object? completedAt = _coursePlayerProgressSentinel,
  }) {
    return CoursePlayerProgress(
      courseId: courseId,
      completedLessonIds:
          completedLessonIds ?? Set<String>.from(this.completedLessonIds),
      attemptedExerciseIds:
          attemptedExerciseIds ?? Set<String>.from(this.attemptedExerciseIds),
      correctExerciseIds:
          correctExerciseIds ?? Set<String>.from(this.correctExerciseIds),
      incorrectExerciseIds:
          incorrectExerciseIds ?? Set<String>.from(this.incorrectExerciseIds),
      earnedPoints: earnedPoints ?? this.earnedPoints,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      currentLessonId: identical(currentLessonId, _coursePlayerProgressSentinel)
          ? this.currentLessonId
          : currentLessonId as String?,
      lastOpenedAt: identical(lastOpenedAt, _coursePlayerProgressSentinel)
          ? this.lastOpenedAt
          : lastOpenedAt as DateTime?,
      completedAt: identical(completedAt, _coursePlayerProgressSentinel)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'completedLessonIds': completedLessonIds.toList(),
      'attemptedExerciseIds': attemptedExerciseIds.toList(),
      'correctExerciseIds': correctExerciseIds.toList(),
      'incorrectExerciseIds': incorrectExerciseIds.toList(),
      'earnedPoints': earnedPoints,
      'enrolledAt': enrolledAt.toIso8601String(),
      'currentLessonId': currentLessonId,
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CoursePlayerProgress.fromJson(Map<String, dynamic> json) {
    return CoursePlayerProgress(
      courseId: json['courseId'] as String? ?? '',
      completedLessonIds: Set<String>.from(
        (json['completedLessonIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
      ),
      attemptedExerciseIds: Set<String>.from(
        (json['attemptedExerciseIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
      ),
      correctExerciseIds: Set<String>.from(
        (json['correctExerciseIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
      ),
      incorrectExerciseIds: Set<String>.from(
        (json['incorrectExerciseIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
      ),
      earnedPoints: json['earnedPoints'] as int? ?? 0,
      enrolledAt:
          DateTime.tryParse(json['enrolledAt'] as String? ?? '') ?? DateTime.now(),
      currentLessonId: json['currentLessonId'] as String?,
      lastOpenedAt: DateTime.tryParse(json['lastOpenedAt'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    );
  }
}

const Object _coursePlayerProgressSentinel = Object();

class CourseCertificate {
  const CourseCertificate({
    required this.id,
    required this.courseId,
    required this.title,
    required this.recipientName,
    required this.issuedAt,
    required this.accent,
    required this.tier,
    required this.completionPercent,
  });

  final String id;
  final String courseId;
  final String title;
  final String recipientName;
  final DateTime issuedAt;
  final Color accent;
  final CourseCertificateTier tier;
  final int completionPercent;
}

class CommunityCourseAuthor {
  const CommunityCourseAuthor({
    required this.id,
    required this.name,
    required this.role,
    required this.accentLabel,
    required this.followersCount,
    required this.courseCount,
    required this.topicKeys,
    this.summary = '',
    this.rating = 4.8,
    this.studentCount = 0,
  });

  final String id;
  final String name;
  final String role;
  final String accentLabel;
  final int followersCount;
  final int courseCount;
  final List<String> topicKeys;
  final String summary;
  final double rating;
  final int studentCount;
}

class CommunityCourseLessonPreview {
  const CommunityCourseLessonPreview({
    required this.title,
    required this.summary,
    required this.durationMinutes,
  });

  final LocalizedText title;
  final LocalizedText summary;
  final int durationMinutes;
}

class CommunityCourseInstructor {
  const CommunityCourseInstructor({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.courseCount,
    required this.studentCount,
    required this.rating,
  });

  final String id;
  final String name;
  final String role;
  final String bio;
  final int courseCount;
  final int studentCount;
  final double rating;
}

class CommunityCourseModuleItem {
  const CommunityCourseModuleItem({
    required this.title,
    required this.durationLabel,
    required this.viewerCount,
    required this.helpfulCount,
  });

  final String title;
  final String durationLabel;
  final int viewerCount;
  final int helpfulCount;
}

class CommunityCourseModuleSection {
  const CommunityCourseModuleSection({
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<CommunityCourseModuleItem> items;
}

class CommunityCourseReviewSummary {
  const CommunityCourseReviewSummary({
    required this.averageRating,
    required this.reviewCount,
    required this.ratingDistribution,
  });

  final double averageRating;
  final int reviewCount;
  final Map<int, int> ratingDistribution;
}

class CommunityCourseReview {
  const CommunityCourseReview({
    required this.id,
    required this.authorName,
    required this.timeLabel,
    required this.rating,
    required this.text,
    this.headline,
  });

  final String id;
  final String authorName;
  final String timeLabel;
  final int rating;
  final String text;
  final String? headline;
}

class CommunityCourseUpdate {
  const CommunityCourseUpdate({
    required this.id,
    required this.title,
    required this.summary,
    required this.timeLabel,
  });

  final String id;
  final String title;
  final String summary;
  final String timeLabel;
}

class CommunityCourseFacts {
  const CommunityCourseFacts({
    required this.lessonCount,
    required this.videoMinutes,
    required this.assessmentCount,
    required this.interactiveCount,
    required this.languageLabel,
    required this.hasCertificate,
    required this.certificateLabel,
    required this.startModeLabel,
  });

  final int lessonCount;
  final int videoMinutes;
  final int assessmentCount;
  final int interactiveCount;
  final String languageLabel;
  final bool hasCertificate;
  final String certificateLabel;
  final String startModeLabel;
}

class CommunityCourseOffer {
  const CommunityCourseOffer({
    required this.priceLabel,
    required this.installmentLabel,
    required this.secondaryInstallmentLabel,
    required this.previewLabel,
    required this.favoriteLabel,
  });

  final String priceLabel;
  final String installmentLabel;
  final String secondaryInstallmentLabel;
  final String previewLabel;
  final String favoriteLabel;
}

class CommunityCourse {
  const CommunityCourse({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.level,
    required this.rating,
    required this.enrollmentCount,
    required this.estimatedHours,
    required this.color,
    required this.author,
    required this.categoryKey,
    required this.topicKeys,
    required this.searchKeywords,
    required this.isPopular,
    required this.isRecommended,
    required this.tags,
    required this.lessons,
    required this.heroBadge,
    required this.heroHeadline,
    required this.learningOutcomes,
    required this.audience,
    required this.requirements,
    required this.instructors,
    required this.moduleSections,
    required this.reviewSummary,
    required this.reviews,
    required this.updates,
    required this.facts,
    required this.offer,
    required this.supportsCoursePlayer,
    required this.coursePlayerModules,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final LocalizedText description;
  final String level;
  final double rating;
  final int enrollmentCount;
  final int estimatedHours;
  final Color color;
  final CommunityCourseAuthor author;
  final String categoryKey;
  final List<String> topicKeys;
  final List<String> searchKeywords;
  final bool isPopular;
  final bool isRecommended;
  final List<String> tags;
  final List<CommunityCourseLessonPreview> lessons;
  final String heroBadge;
  final String heroHeadline;
  final List<String> learningOutcomes;
  final List<String> audience;
  final List<String> requirements;
  final List<CommunityCourseInstructor> instructors;
  final List<CommunityCourseModuleSection> moduleSections;
  final CommunityCourseReviewSummary reviewSummary;
  final List<CommunityCourseReview> reviews;
  final List<CommunityCourseUpdate> updates;
  final CommunityCourseFacts facts;
  final CommunityCourseOffer offer;
  final bool supportsCoursePlayer;
  final List<CoursePlayerModule> coursePlayerModules;
}

class QuizAnswerStat {
  const QuizAnswerStat({
    required this.attempts,
    required this.correctAnswers,
  });

  final int attempts;
  final int correctAnswers;

  QuizAnswerStat copyWith({
    int? attempts,
    int? correctAnswers,
  }) {
    return QuizAnswerStat(
      attempts: attempts ?? this.attempts,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'attempts': attempts,
      'correctAnswers': correctAnswers,
    };
  }

  factory QuizAnswerStat.fromJson(Map<String, dynamic> json) {
    return QuizAnswerStat(
      attempts: json['attempts'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
    );
  }
}
