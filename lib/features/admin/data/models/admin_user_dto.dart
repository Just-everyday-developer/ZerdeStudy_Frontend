import 'admin_role_dto.dart';

/// User returned by GET /api/v1/users and PATCH /api/v1/users/status.
class AdminUserDto {
  const AdminUserDto({
    required this.id,
    required this.email,
    required this.login,
    required this.name,
    required this.bio,
    required this.photoUrl,
    required this.streak,
    required this.maxStreak,
    required this.xp,
    required this.level,
    required this.roles,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String login;
  final String name;
  final String bio;
  final String photoUrl;
  final int streak;
  final int maxStreak;
  final int xp;
  final int level;
  final List<AdminRoleDto> roles;
  final bool isActive;
  final DateTime createdAt;

  /// Best display name: explicit name, else login, else email local-part.
  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    if (login.trim().isNotEmpty) return login.trim();
    final local = email.split('@').first.trim();
    return local.isEmpty ? email : local;
  }

  factory AdminUserDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] as List<dynamic>? ?? const <dynamic>[];
    return AdminUserDto(
      id: '${json['id'] ?? ''}',
      email: json['email'] as String? ?? '',
      login: json['login'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      maxStreak: (json['max_streak'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      roles: rawRoles
          .whereType<Map<String, dynamic>>()
          .map(AdminRoleDto.fromJson)
          .toList(growable: false),
      isActive: json['is_active'] as bool? ?? false,
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
