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

class CommunityCourseAuthor {
  const CommunityCourseAuthor({
    required this.name,
    required this.role,
    required this.accentLabel,
  });

  final String name;
  final String role;
  final String accentLabel;
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
    required this.tags,
    required this.lessons,
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
  final List<String> tags;
  final List<CommunityCourseLessonPreview> lessons;
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
