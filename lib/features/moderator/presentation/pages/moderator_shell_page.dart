import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_experience.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_moderator_controller.dart';
import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import 'admin_pages.dart';
import 'moderator_comments_page.dart';
import 'moderator_community_page.dart';
import 'moderator_courses_page.dart';
import 'moderator_dashboard_page.dart';
import 'moderator_faq_page.dart';
import 'moderator_reports_page.dart';

class ModeratorShellPage extends ConsumerWidget {
  const ModeratorShellPage({super.key, this.initialTab = 0});

  final int initialTab;

  static const _kOrange = Color(0xFFFF6B35);
  static const _kAdminViolet = Color(0xFF8E24AA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final authController = ref.read(authControllerProvider.notifier);
    final demoState = ref.watch(demoAppControllerProvider);
    final isAdmin = demoState.activeExperience == AppExperience.admin;

    final accentColor = isAdmin ? _kAdminViolet : _kOrange;

    final unansweredFaqCount = ref
        .watch(demoModeratorFaqProvider)
        .where((question) => question.answer.isEmpty)
        .length;
    final pendingCommentCount = ref
        .watch(demoModeratorCommentsProvider)
        .where((item) => item.status == ModCommentStatus.needsReview)
        .length;
    final flaggedCommunityCount = ref
        .watch(demoModeratorCommunityProvider)
        .where(
          (item) =>
              item.status == ModCommunityContentStatus.needsReview ||
              item.status == ModCommunityContentStatus.limited,
        )
        .length;

    return Scaffold(
      backgroundColor: colors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1100;
          final minWidth = constraints.maxWidth < 1320
              ? 1320.0
              : constraints.maxWidth;

          Widget body = Row(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isAdmin
                                      ? Icons.security_rounded
                                      : Icons.admin_panel_settings_rounded,
                                  color: accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAdmin ? 'Админ-панель' : 'Модерация',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    Text(
                                      isAdmin
                                          ? 'Full System Control'
                                          : 'ZerdeStudy moderation',
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
                          const SizedBox(height: 16),
                          Text(
                            isAdmin
                                ? 'Управление платформой, пользователями и системными ресурсами.'
                                : 'Контроль комментариев, жалоб, community-контента и учебных публикаций.',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              height: 1.5,
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
                          _NavItem(
                            icon: Icons.dashboard_rounded,
                            label: 'Дашборд',
                            selected: initialTab == 0,
                            accentColor: accentColor,
                            onTap: () => context.go(AppRoutes.moderator),
                            colors: colors,
                          ),
                          if (isAdmin) ...[
                            _NavItem(
                              icon: Icons.people_alt_rounded,
                              label: 'Пользователи',
                              selected: initialTab == 6,
                              accentColor: accentColor,
                              onTap: () => context.go(AppRoutes.moderatorUsers),
                              colors: colors,
                            ),
                            _NavItem(
                              icon: Icons.analytics_rounded,
                              label: 'Система',
                              selected: initialTab == 7,
                              accentColor: accentColor,
                              onTap: () =>
                                  context.go(AppRoutes.moderatorSystem),
                              colors: colors,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              child: Divider(),
                            ),
                          ],
                          _NavItem(
                            icon: Icons.rate_review_rounded,
                            label: 'Проверка курсов',
                            selected: initialTab == 1,
                            badge: '${kModPendingCourses.length}',
                            accentColor: accentColor,
                            onTap: () => context.go(AppRoutes.moderatorCourses),
                            colors: colors,
                          ),
                          _NavItem(
                            icon: Icons.flag_rounded,
                            label: 'Жалобы и баны',
                            selected: initialTab == 2,
                            badge: '${kModReports.length}',
                            accentColor: accentColor,
                            onTap: () => context.go(AppRoutes.moderatorReports),
                            colors: colors,
                          ),
                          _NavItem(
                            icon: Icons.comment_bank_rounded,
                            label: 'Комментарии',
                            selected: initialTab == 3,
                            badge: '$pendingCommentCount',
                            accentColor: accentColor,
                            onTap: () =>
                                context.go(AppRoutes.moderatorComments),
                            colors: colors,
                          ),
                          _NavItem(
                            icon: Icons.groups_rounded,
                            label: 'Community',
                            selected: initialTab == 4,
                            badge: '$flaggedCommunityCount',
                            accentColor: accentColor,
                            onTap: () =>
                                context.go(AppRoutes.moderatorCommunity),
                            colors: colors,
                          ),
                          _NavItem(
                            icon: Icons.help_outline_rounded,
                            label: 'FAQ',
                            selected: initialTab == 5,
                            badge: '$unansweredFaqCount',
                            accentColor: accentColor,
                            onTap: () => context.go(AppRoutes.moderatorFaq),
                            colors: colors,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () async {
                          await authController.logout();
                          if (!context.mounted) {
                            return;
                          }
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
                  child: switch (initialTab) {
                    0 => const ModeratorDashboardPage(),
                    1 => const ModeratorCoursesPage(),
                    2 => const ModeratorReportsPage(),
                    3 => const ModeratorCommentsPage(),
                    4 => const ModeratorCommunityPage(),
                    5 => const ModeratorFaqPage(),
                    6 => const AdminUsersPage(),
                    7 => const AdminSystemPage(),
                    _ => const ModeratorDashboardPage(),
                  },
                ),
              ),
            ],
          );

          if (isCompact) {
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.accentColor,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppThemeColors colors;
  final Color accentColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? accentColor.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? accentColor : colors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? accentColor : colors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: selected
                        ? accentColor.withValues(alpha: 0.18)
                        : colors.surfaceSoft,
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? accentColor : colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
