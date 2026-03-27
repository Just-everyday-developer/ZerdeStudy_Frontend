class AuthRole {
  const AuthRole({
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
}
