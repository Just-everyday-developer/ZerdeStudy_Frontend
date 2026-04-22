class BackendLocalizedTextDto {
  const BackendLocalizedTextDto({
    required this.en,
    required this.ru,
    required this.kk,
  });

  final String en;
  final String ru;
  final String kk;

  bool get isEmpty => en.isEmpty && ru.isEmpty && kk.isEmpty;

  factory BackendLocalizedTextDto.fromJson(Object? raw) {
    if (raw is! Map) {
      return const BackendLocalizedTextDto(en: '', ru: '', kk: '');
    }

    final json = Map<String, dynamic>.from(raw);
    return BackendLocalizedTextDto(
      en: json['en'] as String? ?? '',
      ru: json['ru'] as String? ?? '',
      kk: json['kk'] as String? ?? '',
    );
  }
}

class BackendLessonDto {
  const BackendLessonDto({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.outcome,
    required this.keyPoints,
    required this.theoryContent,
    required this.durationMinutes,
    required this.xpReward,
    required this.codeSnippet,
    required this.exampleOutput,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String moduleId;
  final BackendLocalizedTextDto title;
  final BackendLocalizedTextDto summary;
  final BackendLocalizedTextDto outcome;
  final List<BackendLocalizedTextDto> keyPoints;
  final BackendLocalizedTextDto theoryContent;
  final int durationMinutes;
  final int xpReward;
  final String codeSnippet;
  final String exampleOutput;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BackendLessonDto.fromJson(Map<String, dynamic> json) {
    final rawKeyPoints =
        json['key_points'] as List<dynamic>? ?? const <dynamic>[];

    return BackendLessonDto(
      id: '${json['id'] ?? ''}',
      moduleId: '${json['module_id'] ?? ''}',
      title: BackendLocalizedTextDto.fromJson(json['title']),
      summary: BackendLocalizedTextDto.fromJson(json['summary']),
      outcome: BackendLocalizedTextDto.fromJson(json['out_come']),
      keyPoints: rawKeyPoints
          .map(BackendLocalizedTextDto.fromJson)
          .toList(growable: false),
      theoryContent: BackendLocalizedTextDto.fromJson(json['theory_content']),
      durationMinutes: (json['duration_minutes'] as num?)?.round() ?? 0,
      xpReward: (json['xp_reward'] as num?)?.round() ?? 0,
      codeSnippet: json['code_snippet'] as String? ?? '',
      exampleOutput: json['example_output'] as String? ?? '',
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
