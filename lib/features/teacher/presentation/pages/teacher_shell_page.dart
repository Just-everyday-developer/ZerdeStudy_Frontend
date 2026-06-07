// Teacher shell page — updated to match the new 5-tab design.
//
// Section list reduced from 8 to 5:
//   Overview · Course Builder · Analytics · Q&A · Profile
//
// The old `generator`, `assessments`, `publishing` (external platforms) and
// `qna`-as-separate-from-overview have been folded into the builder + AI
// surfaces. See MIGRATION.md for the rationale.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_settings_panel.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../teacher_text.dart';
import 'teacher_analytics_page.dart';
import 'teacher_courses_page.dart';
import 'teacher_dashboard_page.dart';
import 'teacher_profile_page.dart';
import 'teacher_qna_page.dart';

enum TeacherSection { dashboard, builder, analytics, qna, profile }

class TeacherShellPage extends ConsumerWidget {
  const TeacherShellPage({super.key, required this.section});

  final TeacherSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoState = ref.watch(demoAppControllerProvider);
    final locale = demoState.locale;
    final colors = context.appColors;
    final authController = ref.read(authControllerProvider.notifier);
    final compact = MediaQuery.sizeOf(context).width < 900;

    final page = switch (section) {
      TeacherSection.dashboard => const TeacherDashboardPage(),
      TeacherSection.builder   => const TeacherCoursesPage(),
      TeacherSection.analytics => const TeacherAnalyticsPage(),
      TeacherSection.qna       => const TeacherQnaPage(),
      TeacherSection.profile   => const TeacherProfilePage(),
    };

    // Compact: bottom-tab nav (mobile / phone web).
    if (compact) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(child: page),
        bottomNavigationBar: _BottomNav(
          current: section,
          locale: locale,
          onTap: (s) => context.go(_descriptor(s).route),
        ),
      );
    }

    // Wide: persistent left rail.
    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          SizedBox(
            width: 248,
            child: _LeftRail(
              current: section,
              locale: locale,
              userName: demoState.user?.name ?? 'Teacher',
              onSectionTap: (s) => context.go(_descriptor(s).route),
              onOpenSettings: () => showAppSettingsPanel(context),
              onLogout: () async {
                await authController.logout();
                if (!context.mounted) return;
                context.go(AppRoutes.welcome);
              },
            ),
          ),
          Expanded(child: page),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section descriptor
// ─────────────────────────────────────────────────────────────────────────────

class _Descriptor {
  const _Descriptor({
    required this.route,
    required this.icon,
    required this.title,
  });
  final String route;
  final IconData icon;
  final LocalizedText title;
}

_Descriptor _descriptor(TeacherSection s) {
  switch (s) {
    case TeacherSection.dashboard:
      return _Descriptor(
        route: AppRoutes.teacher,
        icon: Icons.dashboard_rounded,
        title: teacherText(ru: 'Обзор', en: 'Overview', kk: 'Шолу'),
      );
    case TeacherSection.builder:
      return _Descriptor(
        route: AppRoutes.teacherBuilder,
        icon: Icons.library_books_rounded,
        title: teacherText(
          ru: 'Мои курсы',
          en: 'My Courses',
          kk: 'Менің курстарым',
        ),
      );
    case TeacherSection.analytics:
      return _Descriptor(
        route: AppRoutes.teacherAnalytics,
        icon: Icons.bar_chart_rounded,
        title: teacherText(ru: 'Аналитика', en: 'Analytics', kk: 'Аналитика'),
      );
    case TeacherSection.qna:
      return _Descriptor(
        route: AppRoutes.teacherQna,
        icon: Icons.forum_rounded,
        title: teacherText(ru: 'Вопросы', en: 'Q&A', kk: 'Сұрақтар'),
      );
    case TeacherSection.profile:
      return _Descriptor(
        route: AppRoutes.teacherProfile,
        icon: Icons.person_rounded,
        title: teacherText(ru: 'Профиль', en: 'Profile', kk: 'Профиль'),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left rail (desktop / wide)
// ─────────────────────────────────────────────────────────────────────────────

class _LeftRail extends StatelessWidget {
  const _LeftRail({
    required this.current,
    required this.locale,
    required this.userName,
    required this.onSectionTap,
    required this.onOpenSettings,
    required this.onLogout,
  });
  final TeacherSection current;
  final AppLocale locale;
  final String userName;
  final ValueChanged<TeacherSection> onSectionTap;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        border: Border(right: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Brand(),
            const SizedBox(height: 6),
            for (final s in TeacherSection.values)
              _NavItem(
                section: s,
                active: s == current,
                onTap: () => onSectionTap(s),
                locale: locale,
              ),
            const Spacer(),
            const Divider(height: 1),
            _UserCard(name: userName, onLogout: onLogout),
            ListTile(
              onTap: onOpenSettings,
              leading: Icon(Icons.tune_rounded, color: colors.textSecondary, size: 18),
              title: Text(
                'Settings',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.primary.withValues(alpha: 0.6)],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Text('Z', style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF062623),
              fontSize: 14,
            )),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TEACHER STUDIO',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.04,
                  )),
              Text('ZerdeStudy / v3.2',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 9.5,
                    fontFamily: 'monospace',
                    letterSpacing: 0.14,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.active,
    required this.onTap,
    required this.locale,
  });
  final TeacherSection section;
  final bool active;
  final VoidCallback onTap;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final d = _descriptor(section);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? colors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active
                ? colors.primary.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(d.icon,
                size: 17,
                color: active ? colors.primary : colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                d.title.resolve(locale),
                style: TextStyle(
                  color: active ? colors.textPrimary : colors.textSecondary,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.name, required this.onLogout});
  final String name;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'T';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.accent, colors.accent.withValues(alpha: 0.55)],
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: Text(initial,
                  style: const TextStyle(
                      color: Color(0xFF1b0e02),
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.logout_rounded,
                    color: colors.textSecondary, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav (compact / mobile)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.current,
    required this.locale,
    required this.onTap,
  });
  final TeacherSection current;
  final AppLocale locale;
  final ValueChanged<TeacherSection> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final s in TeacherSection.values)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _descriptor(s).icon,
                            size: 19,
                            color: s == current
                                ? colors.primary
                                : colors.textSecondary,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _descriptor(s).title.resolve(locale),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: s == current
                                  ? colors.textPrimary
                                  : colors.textSecondary,
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
      ),
    );
  }
}
