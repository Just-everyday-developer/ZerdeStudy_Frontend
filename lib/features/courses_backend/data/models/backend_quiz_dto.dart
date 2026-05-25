import 'backend_lesson_dto.dart';

class BackendQuizOptionDto {
  const BackendQuizOptionDto({
    required this.id,
    required this.position,
    required this.text,
  });

  final String id;
  final int position;
  final BackendLocalizedTextDto text;

  factory BackendQuizOptionDto.fromJson(Map<String, dynamic> json) {
    return BackendQuizOptionDto(
      id: '${json['id'] ?? ''}',
      position: (json['position'] as num?)?.round() ?? 0,
      text: BackendLocalizedTextDto.fromJson(json['text']),
    );
  }
}

class BackendQuizDto {
  const BackendQuizDto({
    required this.id,
    required this.lessonId,
    required this.position,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.correctOptionId,
    required this.explanation,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String lessonId;
  final int position;
  final BackendLocalizedTextDto question;
  final List<BackendQuizOptionDto> options;
  final int correctAnswerIndex;
  final String correctOptionId;
  final BackendLocalizedTextDto explanation;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BackendQuizDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? const <dynamic>[];

    return BackendQuizDto(
      id: '${json['id'] ?? ''}',
      lessonId: '${json['lesson_id'] ?? ''}',
      position: (json['position'] as num?)?.round() ?? 0,
      question: BackendLocalizedTextDto.fromJson(json['question']),
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(BackendQuizOptionDto.fromJson)
          .toList(growable: false),
      correctAnswerIndex: (json['correct_answer_index'] as num?)?.round() ?? 0,
      correctOptionId: '${json['correct_option_id'] ?? ''}',
      explanation: BackendLocalizedTextDto.fromJson(json['explanation']),
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class BackendQuizAnswerResultDto {
  const BackendQuizAnswerResultDto({
    required this.quizId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.correctAnswerIndex,
    required this.correctOptionId,
    required this.explanation,
  });

  final String quizId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final int correctAnswerIndex;
  final String correctOptionId;
  final BackendLocalizedTextDto explanation;

  factory BackendQuizAnswerResultDto.fromJson(Map<String, dynamic> json) {
    return BackendQuizAnswerResultDto(
      quizId: '${json['quiz_id'] ?? ''}',
      selectedAnswerIndex:
          (json['selected_answer_index'] as num?)?.round() ?? 0,
      isCorrect: json['is_correct'] as bool? ?? false,
      correctAnswerIndex:
          (json['correct_answer_index'] as num?)?.round() ?? 0,
      correctOptionId: '${json['correct_option_id'] ?? ''}',
      explanation: BackendLocalizedTextDto.fromJson(json['explanation']),
    );
  }
}
