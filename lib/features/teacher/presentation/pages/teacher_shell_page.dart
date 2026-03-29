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
import 'teacher_ai_generator_page.dart';
import 'teacher_analytics_page.dart';
import 'teacher_assessment_builder_page.dart';
import 'teacher_course_builder_page.dart';
import 'teacher_dashboard_page.dart';
import 'teacher_profile_page.dart';
import 'teacher_publishing_page.dart';
import 'teacher_qna_page.dart';

enum TeacherSection {
  dashboard,
  generator,
  builder,
  assessments,
  publishing,
  qna,
  analytics,
  profile,
}

class TeacherShellPage extends ConsumerWidget {
  const TeacherShellPage({super.key, required this.section});

  final TeacherSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoState = ref.watch(demoAppControllerProvider);
    final locale = demoState.locale;
    final colors = context.appColors;
    final authController = ref.read(authControllerProvider.notifier);
    final descriptor = _sectionDescriptor(section);
    final compact = MediaQuery.sizeOf(context).width < 980;
    final userName = demoState.user?.name ?? 'Teacher';
    final page = switch (section) {
      TeacherSection.dashboard => const TeacherDashboardPage(),
      TeacherSection.generator => const TeacherAiGeneratorPage(),
      TeacherSection.builder => const TeacherCourseBuilderPage(),
      TeacherSection.assessments => const TeacherAssessmentBuilderPage(),
      TeacherSection.publishing => const TeacherPublishingPage(),
      TeacherSection.qna => const TeacherQnaPage(),
      TeacherSection.analytics => const TeacherAnalyticsPage(),
      TeacherSection.profile => const TeacherProfilePage(),
    };

    return Scaffold(
      backgroundColor: colors.background,
      drawer: compact
          ? Drawer(
              backgroundColor: colors.surface,
              child: _TeacherSidebar(
                current: section,
                locale: locale,
                onSectionSelected: (value) {
                  Navigator.of(context).pop();
                  context.go(_sectionDescriptor(value).route);
                },
                onOpenSettings: () {
                  Navigator.of(context).pop();
                  showAppSettingsPanel(context);
                },
                onLogout: () async {
                  Navigator.of(context).pop();
                  await authController.logout();
                  if (!context.mounted) {
                    return;
                  }
                  context.go(AppRoutes.welcome);
                },
              ),
            )
          : null,
      appBar: compact
          ? AppBar(
              title: Text(descriptor.title.resolve(locale)),
              actions: [
                IconButton(
                  onPressed: () => context.go(AppRoutes.teacherProfile),
                  icon: const Icon(Icons.person_rounded),
                  tooltip: _profileLabel.resolve(locale),
                ),
                IconButton(
                  onPressed: () => showAppSettingsPanel(context),
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: _settingsLabel.resolve(locale),
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!compact)
            SizedBox(
              width: 290,
              child: _TeacherSidebar(
                current: section,
                locale: locale,
                onSectionSelected: (value) =>
                    context.go(_sectionDescriptor(value).route),
                onOpenSettings: () => showAppSettingsPanel(context),
                onLogout: () async {
                  await authController.logout();
                  if (!context.mounted) {
                    return;
                  }
                  context.go(AppRoutes.welcome);
                },
              ),
            ),
          Expanded(
            child: Column(
              children: [
                if (!compact)
                  _TeacherDesktopHeader(
                    title: descriptor.title.resolve(locale),
                    subtitle: descriptor.subtitle.resolve(locale),
                    userName: userName,
                    onProfileTap: () => context.go(AppRoutes.teacherProfile),
                    onSettingsTap: () => showAppSettingsPanel(context),
                    locale: locale,
                  ),
                Expanded(child: page),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherDesktopHeader extends StatelessWidget {
  const _TeacherDesktopHeader({
    required this.title,
    required this.subtitle,
    required this.userName,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.locale,
  });

  final String title;
  final String subtitle;
  final String userName;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initial = userName.trim().isEmpty
        ? 'T'
        : userName.trim().substring(0, 1).toUpperCase();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: onSettingsTap,
              icon: const Icon(Icons.tune_rounded),
              tooltip: _settingsLabel.resolve(locale),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.divider),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: colors.primary.withValues(alpha: 0.16),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherSidebar extends StatelessWidget {
  const _TeacherSidebar({
    required this.current,
    required this.locale,
    required this.onSectionSelected,
    required this.onOpenSettings,
    required this.onLogout,
  });

  final TeacherSection current;
  final AppLocale locale;
  final ValueChanged<TeacherSection> onSectionSelected;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sections = TeacherSection.values;

    return Container(
      color: colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _workspaceLabel.resolve(locale),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _workspaceHint.resolve(locale),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final item = sections[index];
                    final descriptor = _sectionDescriptor(item);
                    final selected = current == item;
                    final accent = selected
                        ? colors.primary
                        : colors.textSecondary;

                    return InkWell(
                      onTap: () => onSectionSelected(item),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: selected
                              ? colors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected ? colors.primary : colors.divider,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(descriptor.icon, color: accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                descriptor.title.resolve(locale),
                                style: TextStyle(
                                  color: selected
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: sections.length,
                ),
              ),
              const SizedBox(height: 12),
              _SidebarAction(
                icon: Icons.tune_rounded,
                label: _settingsLabel.resolve(locale),
                onTap: onOpenSettings,
              ),
              const SizedBox(height: 8),
              _SidebarAction(
                icon: Icons.logout_rounded,
                label: _logoutLabel.resolve(locale),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarAction extends StatelessWidget {
  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.divider),
          color: colors.surfaceSoft.withValues(alpha: 0.9),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.textSecondary, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherSectionDescriptor {
  const _TeacherSectionDescriptor({
    required this.route,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String route;
  final IconData icon;
  final LocalizedText title;
  final LocalizedText subtitle;
}

_TeacherSectionDescriptor _sectionDescriptor(TeacherSection section) {
  return switch (section) {
    TeacherSection.dashboard => _TeacherSectionDescriptor(
      route: AppRoutes.teacher,
      icon: Icons.dashboard_customize_rounded,
      title: _dashboardLabel,
      subtitle: _dashboardSubtitle,
    ),
    TeacherSection.generator => _TeacherSectionDescriptor(
      route: AppRoutes.teacherGenerator,
      icon: Icons.auto_awesome_rounded,
      title: _generatorLabel,
      subtitle: _generatorSubtitle,
    ),
    TeacherSection.builder => _TeacherSectionDescriptor(
      route: AppRoutes.teacherBuilder,
      icon: Icons.view_quilt_rounded,
      title: _builderLabel,
      subtitle: _builderSubtitle,
    ),
    TeacherSection.assessments => _TeacherSectionDescriptor(
      route: AppRoutes.teacherAssessments,
      icon: Icons.assignment_rounded,
      title: _assessmentLabel,
      subtitle: _assessmentSubtitle,
    ),
    TeacherSection.publishing => _TeacherSectionDescriptor(
      route: AppRoutes.teacherPublishing,
      icon: Icons.publish_rounded,
      title: _publishingLabel,
      subtitle: _publishingSubtitle,
    ),
    TeacherSection.qna => _TeacherSectionDescriptor(
      route: AppRoutes.teacherQna,
      icon: Icons.forum_rounded,
      title: _qnaLabel,
      subtitle: _qnaSubtitle,
    ),
    TeacherSection.analytics => _TeacherSectionDescriptor(
      route: AppRoutes.teacherAnalytics,
      icon: Icons.insights_rounded,
      title: _analyticsLabel,
      subtitle: _analyticsSubtitle,
    ),
    TeacherSection.profile => _TeacherSectionDescriptor(
      route: AppRoutes.teacherProfile,
      icon: Icons.person_rounded,
      title: _profileLabel,
      subtitle: _profileSubtitle,
    ),
  };
}

final _workspaceLabel = teacherText(
  ru: 'Teacher Studio',
  en: 'Teacher Studio',
  kk: 'Teacher Studio',
);
final _workspaceHint = teacherText(
  ru: 'Панель для генерации курсов, их сборки, публикации и аналитики.',
  en: 'A workspace for course generation, building, publishing, and analytics.',
  kk: 'Курстарды генерациялау, құрастыру, жариялау және аналитика жасау панелі.',
);
final _settingsLabel = teacherText(
  ru: 'Настройки',
  en: 'Settings',
  kk: 'Баптаулар',
);
final _logoutLabel = teacherText(ru: 'Выйти', en: 'Log out', kk: 'Шығу');
final _dashboardLabel = teacherText(
  ru: 'Dashboard',
  en: 'Dashboard',
  kk: 'Dashboard',
);
final _dashboardSubtitle = teacherText(
  ru: 'Сводка по курсам, загрузке и критичным сигналам.',
  en: 'Course summary, workload, and critical signals.',
  kk: 'Курстар, жүктеме және маңызды сигналдар жиынтығы.',
);
final _generatorLabel = teacherText(
  ru: 'AI Generator',
  en: 'AI Generator',
  kk: 'AI Generator',
);
final _generatorSubtitle = teacherText(
  ru: 'Быстрый запуск AI-черновиков курсов.',
  en: 'Fast creation of AI course drafts.',
  kk: 'AI курс нобайларын жылдам жасау.',
);
final _builderLabel = teacherText(
  ru: 'Course Builder',
  en: 'Course Builder',
  kk: 'Course Builder',
);
final _builderSubtitle = teacherText(
  ru: 'Модули, уроки, блоки и структура знания.',
  en: 'Modules, lessons, blocks, and knowledge structure.',
  kk: 'Модульдер, сабақтар, блоктар және білім құрылымы.',
);
final _assessmentLabel = teacherText(
  ru: 'Assessment',
  en: 'Assessment',
  kk: 'Assessment',
);
final _assessmentSubtitle = teacherText(
  ru: 'Quiz, assignments, rubric и question bank.',
  en: 'Quiz, assignments, rubrics, and the question bank.',
  kk: 'Quiz, assignments, rubrics және question bank.',
);
final _publishingLabel = teacherText(
  ru: 'Publishing',
  en: 'Publishing',
  kk: 'Publishing',
);
final _publishingSubtitle = teacherText(
  ru: 'Preview, release schedule и правила публикации.',
  en: 'Preview, release schedule, and publish rules.',
  kk: 'Preview, release schedule және publish rules.',
);
final _qnaLabel = teacherText(ru: 'Q&A', en: 'Q&A', kk: 'Q&A');
final _qnaSubtitle = teacherText(
  ru: 'Вопросы студентов, объявления и support flow.',
  en: 'Learner questions, announcements, and support flow.',
  kk: 'Студент сұрақтары, хабарландырулар және support flow.',
);
final _analyticsLabel = teacherText(
  ru: 'Analytics',
  en: 'Analytics',
  kk: 'Analytics',
);
final _analyticsSubtitle = teacherText(
  ru: 'Метрики успеха курса и actionable insights.',
  en: 'Course success metrics and actionable insights.',
  kk: 'Курс жетістігі метрикалары және actionable insights.',
);
final _profileLabel = teacherText(ru: 'Профиль', en: 'Profile', kk: 'Профиль');
final _profileSubtitle = teacherText(
  ru: 'Личный профиль и рабочие приоритеты преподавателя.',
  en: 'Teacher identity and current working priorities.',
  kk: 'Оқытушының жеке профилі және жұмыс приоритеттері.',
);
