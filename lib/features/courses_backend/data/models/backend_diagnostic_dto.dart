import '../../../../app/state/app_locale.dart';

/// Tri-lingual text returned by the diagnostic endpoints.
class DiagnosticLocalizedText {
  const DiagnosticLocalizedText({
    required this.ru,
    required this.en,
    required this.kk,
  });

  final String ru;
  final String en;
  final String kk;

  String resolve(AppLocale locale) {
    return switch (locale) {
      AppLocale.ru => ru,
      AppLocale.kk => kk,
      AppLocale.en => en,
    };
  }

  factory DiagnosticLocalizedText.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return DiagnosticLocalizedText(
      ru: '${map['ru'] ?? ''}',
      en: '${map['en'] ?? ''}',
      kk: '${map['kk'] ?? ''}',
    );
  }
}

/// A programming sphere the test probes (and recommends courses for).
class DiagnosticSphereDto {
  const DiagnosticSphereDto({
    required this.id,
    required this.slug,
    required this.position,
    required this.icon,
    required this.accentColor,
    required this.name,
  });

  final String id;
  final String slug;
  final int position;
  final String icon;
  final String accentColor;
  final DiagnosticLocalizedText name;

  factory DiagnosticSphereDto.fromJson(Map<String, dynamic> json) {
    return DiagnosticSphereDto(
      id: '${json['id'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      position: (json['position'] as num?)?.toInt() ?? 0,
      icon: '${json['icon'] ?? ''}',
      accentColor: '${json['accent_color'] ?? ''}',
      name: DiagnosticLocalizedText.fromJson(
        json['name'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// A single answer option. Note: there is intentionally no `isCorrect` — the
/// backend never sends correctness to the client.
class DiagnosticOptionDto {
  const DiagnosticOptionDto({
    required this.id,
    required this.position,
    required this.label,
  });

  final String id;
  final int position;
  final DiagnosticLocalizedText label;

  factory DiagnosticOptionDto.fromJson(Map<String, dynamic> json) {
    return DiagnosticOptionDto(
      id: '${json['id'] ?? ''}',
      position: (json['position'] as num?)?.toInt() ?? 0,
      label: DiagnosticLocalizedText.fromJson(
        json['label'] as Map<String, dynamic>?,
      ),
    );
  }
}

class DiagnosticQuestionDto {
  const DiagnosticQuestionDto({
    required this.id,
    required this.sphereId,
    required this.sphereSlug,
    required this.questionType,
    required this.difficulty,
    required this.position,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String sphereId;
  final String sphereSlug;
  final String questionType; // single_choice | multiple_choice
  final String difficulty; // easy | medium | hard
  final int position;
  final DiagnosticLocalizedText prompt;
  final List<DiagnosticOptionDto> options;

  bool get isMultipleChoice => questionType == 'multiple_choice';

  factory DiagnosticQuestionDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(DiagnosticOptionDto.fromJson)
        .toList(growable: false);
    return DiagnosticQuestionDto(
      id: '${json['id'] ?? ''}',
      sphereId: '${json['sphere_id'] ?? ''}',
      sphereSlug: '${json['sphere_slug'] ?? ''}',
      questionType: '${json['question_type'] ?? 'single_choice'}',
      difficulty: '${json['difficulty'] ?? 'easy'}',
      position: (json['position'] as num?)?.toInt() ?? 0,
      prompt: DiagnosticLocalizedText.fromJson(
        json['prompt'] as Map<String, dynamic>?,
      ),
      options: rawOptions,
    );
  }
}

class DiagnosticTestDto {
  const DiagnosticTestDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.spheres,
    required this.questions,
  });

  final String id;
  final String slug;
  final DiagnosticLocalizedText title;
  final DiagnosticLocalizedText description;
  final List<DiagnosticSphereDto> spheres;
  final List<DiagnosticQuestionDto> questions;

  factory DiagnosticTestDto.fromJson(Map<String, dynamic> json) {
    return DiagnosticTestDto(
      id: '${json['id'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      title: DiagnosticLocalizedText.fromJson(
        json['title'] as Map<String, dynamic>?,
      ),
      description: DiagnosticLocalizedText.fromJson(
        json['description'] as Map<String, dynamic>?,
      ),
      spheres: (json['spheres'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DiagnosticSphereDto.fromJson)
          .toList(growable: false),
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DiagnosticQuestionDto.fromJson)
          .toList(growable: false),
    );
  }
}

/// Per-sphere breakdown of a saved result.
class DiagnosticResultSphereDto {
  const DiagnosticResultSphereDto({
    required this.sphere,
    required this.score,
    required this.maxScore,
    required this.correctCount,
    required this.questionCount,
  });

  final DiagnosticSphereDto sphere;
  final int score;
  final int maxScore;
  final int correctCount;
  final int questionCount;

  /// 0..1 mastery of this sphere.
  double get mastery => maxScore <= 0 ? 0 : score / maxScore;

  factory DiagnosticResultSphereDto.fromJson(Map<String, dynamic> json) {
    return DiagnosticResultSphereDto(
      sphere: DiagnosticSphereDto.fromJson(
        (json['sphere'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class DiagnosticResultDto {
  const DiagnosticResultDto({
    required this.id,
    required this.testId,
    required this.level,
    required this.totalScore,
    required this.maxScore,
    required this.correctCount,
    required this.questionCount,
    required this.topSphereId,
    required this.spheres,
  });

  final String id;
  final String testId;
  final String level; // beginner | intermediate | advanced
  final int totalScore;
  final int maxScore;
  final int correctCount;
  final int questionCount;
  final String? topSphereId;
  final List<DiagnosticResultSphereDto> spheres;

  /// 0..1 overall mastery.
  double get percent => maxScore <= 0 ? 0 : totalScore / maxScore;

  /// Spheres ordered strongest-first (by mastery, then raw score).
  List<DiagnosticResultSphereDto> get spheresByStrength {
    final sorted = [...spheres];
    sorted.sort((a, b) {
      final byMastery = b.mastery.compareTo(a.mastery);
      if (byMastery != 0) return byMastery;
      return b.score.compareTo(a.score);
    });
    return sorted;
  }

  factory DiagnosticResultDto.fromJson(Map<String, dynamic> json) {
    return DiagnosticResultDto(
      id: '${json['id'] ?? ''}',
      testId: '${json['test_id'] ?? ''}',
      level: '${json['level'] ?? 'beginner'}',
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
      topSphereId: (json['top_sphere_id'] as String?)?.trim().isEmpty ?? true
          ? null
          : json['top_sphere_id'] as String?,
      spheres: (json['spheres'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DiagnosticResultSphereDto.fromJson)
          .toList(growable: false),
    );
  }
}

/// One submitted answer (question + chosen option ids).
class DiagnosticAnswerInput {
  const DiagnosticAnswerInput({
    required this.questionId,
    required this.selectedOptionIds,
  });

  final String questionId;
  final List<String> selectedOptionIds;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'question_id': questionId,
    'selected_option_ids': selectedOptionIds,
  };
}
