/// Role returned by GET /api/v1/roles and embedded in user/user_roles payloads.
class AdminRoleDto {
  const AdminRoleDto({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.isDefault,
    required this.isPrivileged,
    required this.isSupport,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final bool isDefault;
  final bool isPrivileged;
  final bool isSupport;

  factory AdminRoleDto.fromJson(Map<String, dynamic> json) {
    return AdminRoleDto(
      id: '${json['id'] ?? ''}',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      isPrivileged: json['is_privileged'] as bool? ?? false,
      isSupport: json['is_support'] as bool? ?? false,
    );
  }
}
