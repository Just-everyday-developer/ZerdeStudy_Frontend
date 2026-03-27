import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import 'moderator_dashboard_page.dart';
import 'moderator_courses_page.dart';
import 'moderator_reports_page.dart';
import 'moderator_faq_page.dart';

class ModeratorShellPage extends ConsumerStatefulWidget {
  const ModeratorShellPage({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<ModeratorShellPage> createState() => _ModeratorShellPageState();
}

class _ModeratorShellPageState extends ConsumerState<ModeratorShellPage> {
  late int _tab;

  static const _kOrange = Color(0xFFFF6B35);

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          // ── Sidebar ───────────────────────────────
          Container(
            width: 220,
            color: colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                          color: _kOrange.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: _kOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Модерация',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'ZerdeStudy Admin',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Nav items
                const SizedBox(height: 12),
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Дашборд',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                  colors: colors,
                ),
                _NavItem(
                  icon: Icons.rate_review_rounded,
                  label: 'Проверка курсов',
                  selected: _tab == 1,
                  badge: '$kModPendingCoursesCount',
                  onTap: () => setState(() => _tab = 1),
                  colors: colors,
                ),
                _NavItem(
                  icon: Icons.flag_rounded,
                  label: 'Жалобы и баны',
                  selected: _tab == 2,
                  badge: '45',
                  onTap: () => setState(() => _tab = 2),
                  colors: colors,
                ),
                _NavItem(
                  icon: Icons.help_outline_rounded,
                  label: 'FAQ',
                  selected: _tab == 3,
                  badge: '8',
                  onTap: () => setState(() => _tab = 3),
                  colors: colors,
                ),
                const Spacer(),
                // Exit
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
                          Icon(Icons.logout_rounded,
                              color: colors.textSecondary, size: 18),
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
          // ── Content ──────────────────────────────
          Expanded(
            child: switch (_tab) {
              0 => const ModeratorDashboardPage(),
              1 => const ModeratorCoursesPage(),
              2 => const ModeratorReportsPage(),
              3 => const ModeratorFaqPage(),
              _ => const ModeratorDashboardPage(),
            },
          ),
        ],
      ),
    );
  }
}

int get kModPendingCoursesCount => 5; // matches demo data length

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    this.badge,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppThemeColors colors;
  final String? badge;
  static const _kOrange = Color(0xFFFF6B35);

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
                ? _kOrange.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? _kOrange : colors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? _kOrange : colors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: selected
                        ? _kOrange.withValues(alpha: 0.18)
                        : colors.surfaceSoft,
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? _kOrange : colors.textSecondary,
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
