import '../../domain/entities/auth_user.dart';
import 'auth_role_dto.dart';

class AuthUserDto {
  const AuthUserDto({
    required this.id,
    required this.email,
    required this.roles,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String email;
  final List<AuthRoleDto> roles;
  final bool isActive;
  final DateTime createdAt;

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      roles: roles.map((role) => role.toDomain()).toList(growable: false),
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'roles': roles.map((role) => role.toJson()).toList(growable: false),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] as List<dynamic>? ?? const <dynamic>[];
    return AuthUserDto(
      id: '${json['id'] ?? ''}',
      email: json['email'] as String? ?? '',
      roles: rawRoles
          .whereType<Map<String, dynamic>>()
          .map(AuthRoleDto.fromJson)
          .toList(growable: false),
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
