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
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
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
    required this.isCurrentUser,
  });

  final String id;
  final String name;
  final int xp;
  final int level;
  final bool isCurrentUser;
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
    required this.keyPoints,
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
  final List<LocalizedText> keyPoints;
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
    required this.isPlayable,
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
  final bool isPlayable;
  final List<LearningModule> modules;

  int get totalUnits {
    return modules.fold<int>(0, (sum, module) => sum + module.totalUnits);
  }
}

enum TrackVisualState { locked, inProgress, completed }

class TrackProgress {
  const TrackProgress({
    required this.state,
    required this.completedUnits,
    required this.totalUnits,
    required this.nextTarget,
  });

  final TrackVisualState state;
  final int completedUnits;
  final int totalUnits;
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
