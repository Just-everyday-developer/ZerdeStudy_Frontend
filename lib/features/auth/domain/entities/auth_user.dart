import 'auth_role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.roles,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String email;
  final List<AuthRole> roles;
  final bool isActive;
  final DateTime createdAt;

  List<String> get roleCodes {
    return roles.map((role) => role.code).toList(growable: false);
  }

  bool get isModerator {
    return roleCodes.any(
      (roleCode) => roleCode == 'manager' || roleCode == 'admin',
    );
  }

  String get displayName {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Student';
    }

    final normalized = localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    if (normalized.isEmpty) {
      return 'Student';
    }

    final words = normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) {
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .toList(growable: false);

    return words.isEmpty ? 'Student' : words.join(' ');
  }
}
