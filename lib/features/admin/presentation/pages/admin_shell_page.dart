import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import 'admin_course_review_page.dart';
import 'admin_roles_page.dart';
import 'admin_users_page.dart';

enum AdminSection { users, roles, courseReview }

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
    final locale = context.l10n.locale;
    final currentLocale = ref.watch(demoAppControllerProvider.select((s) => s.locale));

    void onLocaleSelected(AppLocale l) =>
        ref.read(demoAppControllerProvider.notifier).changeLocale(l);

    final adminPanelLabel = switch (locale) {
      AppLocale.ru => 'Админ-панель',
      AppLocale.kk => 'Әкімші панелі',
      _ => 'Admin Panel',
    };
    final logoutLabel = switch (locale) {
      AppLocale.ru => 'Выйти',
      AppLocale.kk => 'Шығу',
      _ => 'Log out',
    };
    final usersLabel = switch (locale) {
      AppLocale.ru => 'Пользователи',
      AppLocale.kk => 'Пайдаланушылар',
      _ => 'Users',
    };
    final rolesLabel = switch (locale) {
      AppLocale.ru => 'Роли',
      AppLocale.kk => 'Рөлдер',
      _ => 'Roles',
    };
    final courseReviewLabel = switch (locale) {
      AppLocale.ru => 'Курсы',
      AppLocale.kk => 'Курстар',
      _ => 'Courses',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        if (isMobile) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.surface,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _kViolet.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.security_rounded, color: _kViolet, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    adminPanelLabel,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<AppLocale>(
                  tooltip: 'Язык',
                  initialValue: currentLocale,
                  offset: const Offset(0, 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: colors.surface,
                  onSelected: onLocaleSelected,
                  itemBuilder: (context) => AppLocale.values
                      .map((l) => PopupMenuItem<AppLocale>(
                            value: l,
                            child: Row(children: [
                              Icon(
                                Icons.language_rounded,
                                size: 18,
                                color: l == currentLocale ? _kViolet : colors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l.label,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: l == currentLocale ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ]),
                          ))
                      .toList(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language_rounded, size: 18, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(currentLocale.label,
                            style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout_rounded, color: colors.textSecondary),
                  tooltip: logoutLabel,
                  onPressed: () async {
                    await authController.logout();
                    if (!context.mounted) return;
                    context.go(AppRoutes.welcome);
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: switch (section) {
              AdminSection.users => const AdminUsersPage(),
              AdminSection.roles => const AdminRolesPage(),
              AdminSection.courseReview => const AdminCourseReviewPage(),
            },
            bottomNavigationBar: NavigationBar(
              selectedIndex: section.index,
              onDestinationSelected: (i) => context.go(
                switch (i) {
                  0 => AppRoutes.admin,
                  1 => AppRoutes.adminRoles,
                  _ => AppRoutes.adminCourseReview,
                },
              ),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.people_alt_outlined),
                  selectedIcon: const Icon(Icons.people_alt_rounded),
                  label: usersLabel,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.shield_outlined),
                  selectedIcon: const Icon(Icons.shield_rounded),
                  label: rolesLabel,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.rate_review_outlined),
                  selectedIcon: const Icon(Icons.rate_review_rounded),
                  label: courseReviewLabel,
                ),
              ],
            ),
          );
        }

        // Desktop: sidebar layout
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
                                adminPanelLabel,
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
                          label: usersLabel,
                          selected: section == AdminSection.users,
                          colors: colors,
                          onTap: () => context.go(AppRoutes.admin),
                        ),
                        _AdminNavItem(
                          icon: Icons.shield_rounded,
                          label: rolesLabel,
                          selected: section == AdminSection.roles,
                          colors: colors,
                          onTap: () => context.go(AppRoutes.adminRoles),
                        ),
                        _AdminNavItem(
                          icon: Icons.rate_review_rounded,
                          label: courseReviewLabel,
                          selected: section == AdminSection.courseReview,
                          colors: colors,
                          onTap: () => context.go(AppRoutes.adminCourseReview),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: PopupMenuButton<AppLocale>(
                      tooltip: 'Язык',
                      initialValue: currentLocale,
                      offset: const Offset(0, 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      color: colors.surface,
                      onSelected: onLocaleSelected,
                      itemBuilder: (context) => AppLocale.values
                          .map((l) => PopupMenuItem<AppLocale>(
                                value: l,
                                child: Row(children: [
                                  Icon(
                                    Icons.language_rounded,
                                    size: 18,
                                    color: l == currentLocale ? _kViolet : colors.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l.label,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontWeight:
                                          l == currentLocale ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                ]),
                              ))
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.divider),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.language_rounded, color: colors.textSecondary, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              currentLocale.label,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_drop_down_rounded,
                                color: colors.textSecondary, size: 18),
                          ],
                        ),
                      ),
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
                              logoutLabel,
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
                  AdminSection.courseReview => const AdminCourseReviewPage(),
                },
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 1100) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: 1100, child: body),
          );
        }
        return Scaffold(backgroundColor: colors.background, body: body);
      },
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
