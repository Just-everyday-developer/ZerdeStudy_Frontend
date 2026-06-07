import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import 'admin_roles_page.dart';
import 'admin_users_page.dart';

enum AdminSection { users, roles }

/// Standalone admin workspace (RBAC). Connected to the backend via
/// admin_providers; no moderation/mock content.
class AdminShellPage extends ConsumerWidget {
  const AdminShellPage({super.key, this.section = AdminSection.users});

  final AdminSection section;

  static const Color _kViolet = Color(0xFF8E24AA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minWidth = constraints.maxWidth < 1100
              ? 1100.0
              : constraints.maxWidth;

          final body = Row(
            children: [
              Container(
                width: 260,
                color: colors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: colors.divider, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _kViolet.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.security_rounded,
                              color: _kViolet,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Админ-панель',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Full System Control',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _AdminNavItem(
                            icon: Icons.people_alt_rounded,
                            label: 'Пользователи',
                            selected: section == AdminSection.users,
                            colors: colors,
                            onTap: () => context.go(AppRoutes.admin),
                          ),
                          _AdminNavItem(
                            icon: Icons.shield_rounded,
                            label: 'Роли',
                            selected: section == AdminSection.roles,
                            colors: colors,
                            onTap: () => context.go(AppRoutes.adminRoles),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () async {
                          await authController.logout();
                          if (!context.mounted) return;
                          context.go(AppRoutes.welcome);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: colors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Выйти',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: colors.background,
                  child: switch (section) {
                    AdminSection.users => const AdminUsersPage(),
                    AdminSection.roles => const AdminRolesPage(),
                  },
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 1100) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: minWidth, child: body),
            );
          }
          return body;
        },
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppThemeColors colors;

  static const Color _kViolet = Color(0xFF8E24AA);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? _kViolet.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color: selected ? _kViolet.withValues(alpha: 0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? _kViolet : colors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: selected ? colors.textPrimary : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
