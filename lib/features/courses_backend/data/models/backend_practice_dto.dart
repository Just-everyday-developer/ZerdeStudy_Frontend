import 'backend_lesson_dto.dart';

class BackendPracticeDto {
  const BackendPracticeDto({
    required this.id,
    required this.lessonId,
    required this.courseId,
    required this.position,
    required this.title,
    required this.summary,
    required this.brief,
    required this.description,
    required this.language,
    required this.starterCode,
    required this.checkType,
    required this.successCriteria,
    required this.knowledgeChecks,
    required this.promptSuggestion,
    required this.xpReward,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String lessonId;
  final String courseId;
  final int position;
  final BackendLocalizedTextDto title;
  final BackendLocalizedTextDto summary;
  final BackendLocalizedTextDto brief;

  /// Flat (non-localized) task description as stored by curriculum-service.
  final String description;

  /// Programming language the task expects (e.g. "java"), required by the
  /// `/practice/:id/run` endpoint.
  final String language;
  final String starterCode;
  final String checkType;
  final List<BackendLocalizedTextDto> successCriteria;
  final List<BackendLocalizedTextDto> knowledgeChecks;
  final BackendLocalizedTextDto promptSuggestion;
  final int xpReward;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BackendPracticeDto.fromJson(Map<String, dynamic> json) {
    List<BackendLocalizedTextDto> parseLocales(String key) {
      final raw = json[key] as List<dynamic>? ?? const <dynamic>[];
      return raw.map(BackendLocalizedTextDto.fromJson).toList(growable: false);
    }

    BackendLocalizedTextDto localizedOrFallback(String key, String fallback) {
      final localized = BackendLocalizedTextDto.fromJson(json[key]);
      if (!localized.isEmpty) return localized;
      return BackendLocalizedTextDto.fromJson(fallback);
    }

    final flatDescription = json['description'] as String? ?? '';
    final compactSummary = _compactSummary(flatDescription);

    return BackendPracticeDto(
      id: '${json['id'] ?? ''}',
      lessonId: '${json['lesson_id'] ?? ''}',
      courseId: '${json['course_id'] ?? ''}',
      position: (json['position'] as num?)?.round() ?? 0,
      title: localizedOrFallback('title', ''),
      summary: localizedOrFallback('summary', compactSummary),
      brief: localizedOrFallback('brief', flatDescription),
      description: flatDescription,
      language: json['language'] as String? ?? 'java',
      starterCode: json['starter_code'] as String? ?? '',
      checkType: json['check_type'] as String? ?? 'auto',
      successCriteria: parseLocales('success_criteria'),
      knowledgeChecks: parseLocales('knowledge_checks'),
      promptSuggestion: localizedOrFallback(
        'prompt_suggestion',
        flatDescription,
      ),
      xpReward: (json['xp_reward'] as num?)?.round() ?? 0,
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

String _compactSummary(String value) {
  final normalized = value
      .replaceAll('\r\n', '\n')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join(' ');
  if (normalized.length <= 150) return normalized;
  return '${normalized.substring(0, 147)}...';
}
