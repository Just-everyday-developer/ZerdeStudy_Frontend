import '../../domain/entities/auth_role.dart';

class AuthRoleDto {
  const AuthRoleDto({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.isDefault,
    required this.isPrivileged,
    required this.isSupport,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final bool isDefault;
  final bool isPrivileged;
  final bool isSupport;
  final DateTime createdAt;

  AuthRole toDomain() {
    return AuthRole(
      id: id,
      code: code,
      name: name,
      description: description,
      isDefault: isDefault,
      isPrivileged: isPrivileged,
      isSupport: isSupport,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'is_default': isDefault,
      'is_privileged': isPrivileged,
      'is_support': isSupport,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuthRoleDto.fromJson(Map<String, dynamic> json) {
    return AuthRoleDto(
      id: '${json['id'] ?? ''}',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      isPrivileged: json['is_privileged'] as bool? ?? false,
      isSupport: json['is_support'] as bool? ?? false,
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
