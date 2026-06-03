/// Profile returned by GET /api/v1/profiles/me.
/// Contains server-computed XP, level, streak and max_streak alongside
/// editable fields (bio, photo_url) that are the canonical server values.
class BackendProfileDto {
  const BackendProfileDto({
    required this.id,
    required this.email,
    required this.login,
    required this.bio,
    required this.photoUrl,
    required this.streak,
    required this.maxStreak,
    required this.xp,
    required this.level,
  });

  final String id;
  final String email;
  final String login;
  final String bio;
  final String photoUrl;
  final int streak;
  final int maxStreak;
  final int xp;
  final int level;

  factory BackendProfileDto.fromJson(Map<String, dynamic> json) {
    return BackendProfileDto(
      id: '${json['id'] ?? ''}',
      email: json['email'] as String? ?? '',
      login: json['login'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      maxStreak: (json['max_streak'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
    );
  }
}
