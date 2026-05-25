import 'backend_lesson_dto.dart';

class BackendPracticeDto {
  const BackendPracticeDto({
    required this.id,
    required this.lessonId,
    required this.position,
    required this.title,
    required this.summary,
    required this.brief,
    required this.starterCode,
    required this.successCriteria,
    required this.knowledgeChecks,
    required this.promptSuggestion,
    required this.xpReward,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String lessonId;
  final int position;
  final BackendLocalizedTextDto title;
  final BackendLocalizedTextDto summary;
  final BackendLocalizedTextDto brief;
  final String starterCode;
  final List<BackendLocalizedTextDto> successCriteria;
  final List<BackendLocalizedTextDto> knowledgeChecks;
  final BackendLocalizedTextDto promptSuggestion;
  final int xpReward;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BackendPracticeDto.fromJson(Map<String, dynamic> json) {
    List<BackendLocalizedTextDto> parseLocales(String key) {
      final raw = json[key] as List<dynamic>? ?? const <dynamic>[];
      return raw
          .map(BackendLocalizedTextDto.fromJson)
          .toList(growable: false);
    }

    return BackendPracticeDto(
      id: '${json['id'] ?? ''}',
      lessonId: '${json['lesson_id'] ?? ''}',
      position: (json['position'] as num?)?.round() ?? 0,
      title: BackendLocalizedTextDto.fromJson(json['title']),
      summary: BackendLocalizedTextDto.fromJson(json['summary']),
      brief: BackendLocalizedTextDto.fromJson(json['brief']),
      starterCode: json['starter_code'] as String? ?? '',
      successCriteria: parseLocales('success_criteria'),
      knowledgeChecks: parseLocales('knowledge_checks'),
      promptSuggestion: BackendLocalizedTextDto.fromJson(
        json['prompt_suggestion'],
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
