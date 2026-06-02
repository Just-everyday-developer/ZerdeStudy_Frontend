import 'backend_lesson_dto.dart';

/// Achievement returned by GET /api/v1/achievements.
/// Progress and unlock state are computed server-side from the user's metrics
/// (completed lessons, passed quizzes, streak, XP, etc.).
class BackendAchievementDto {
  const BackendAchievementDto({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.goal,
    required this.progress,
    required this.unlocked,
  });

  final String id;
  final BackendLocalizedTextDto title;
  final BackendLocalizedTextDto description;
  final String iconKey;
  final int goal;
  final int progress;
  final bool unlocked;

  factory BackendAchievementDto.fromJson(Map<String, dynamic> json) {
    return BackendAchievementDto(
      id: '${json['id'] ?? ''}',
      title: BackendLocalizedTextDto.fromJson(json['title']),
      description: BackendLocalizedTextDto.fromJson(json['description']),
      iconKey: json['icon_key'] as String? ?? '',
      goal: (json['goal'] as num?)?.round() ?? 0,
      progress: (json['progress'] as num?)?.round() ?? 0,
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }
}
