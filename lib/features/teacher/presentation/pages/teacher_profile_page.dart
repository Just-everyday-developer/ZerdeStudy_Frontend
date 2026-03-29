import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherProfilePage extends ConsumerWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoState = ref.watch(demoAppControllerProvider);
    final locale = demoState.locale;
    final colors = context.appColors;
    final user = demoState.user;
    final initial = (user?.name ?? 'T').trim().isEmpty
        ? 'T'
        : (user!.name.trim().substring(0, 1)).toUpperCase();

    return TeacherPageScrollView(
      children: [
        TeacherSectionCard(
          title: _heroTitle.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
          accent: colors.primary,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: colors.primary.withValues(alpha: 0.16),
                child: Text(
                  initial,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Talgat O.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? 'teacher@zerdestudy.app',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        TeacherTag(
                          label: _roleTag.resolve(locale),
                          accent: colors.primary,
                        ),
                        TeacherTag(
                          label: _focusTag.resolve(locale),
                          accent: colors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 860;
            final metrics = [
              TeacherMetricTile(
                label: _metricOneLabel.resolve(locale),
                value: '9',
                hint: _metricOneHint.resolve(locale),
                icon: Icons.menu_book_rounded,
                accent: colors.primary,
              ),
              TeacherMetricTile(
                label: _metricTwoLabel.resolve(locale),
                value: '4',
                hint: _metricTwoHint.resolve(locale),
                icon: Icons.groups_2_rounded,
                accent: colors.success,
              ),
              TeacherMetricTile(
                label: _metricThreeLabel.resolve(locale),
                value: '32h',
                hint: _metricThreeHint.resolve(locale),
                icon: Icons.schedule_rounded,
                accent: colors.accent,
              ),
            ];

            if (compact) {
              return Column(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    metrics[i],
                    if (i != metrics.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < metrics.length; i++) ...[
                  Expanded(child: metrics[i]),
                  if (i != metrics.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _profileFocusTitle.resolve(locale),
          subtitle: _profileFocusSubtitle.resolve(locale),
          accent: colors.success,
          child: Column(children: _focusRows(locale, colors)),
        ),
      ],
    );
  }

  List<Widget> _focusRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _focusOneTitle.resolve(locale),
        _focusOneSubtitle.resolve(locale),
        _focusOneStatus.resolve(locale),
        colors.primary,
      ),
      (
        _focusTwoTitle.resolve(locale),
        _focusTwoSubtitle.resolve(locale),
        _focusTwoStatus.resolve(locale),
        colors.success,
      ),
      (
        _focusThreeTitle.resolve(locale),
        _focusThreeSubtitle.resolve(locale),
        _focusThreeStatus.resolve(locale),
        colors.accent,
      ),
    ];

    return [
      for (var i = 0; i < rows.length; i++) ...[
        TeacherStatusRow(
          title: rows[i].$1,
          subtitle: rows[i].$2,
          status: rows[i].$3,
          accent: rows[i].$4,
        ),
        if (i != rows.length - 1) const SizedBox(height: 12),
      ],
    ];
  }
}

final _heroTitle = teacherText(
  ru: 'Профиль преподавателя',
  en: 'Teacher profile',
  kk: 'Оқытушы профилі',
);
final _heroSubtitle = teacherText(
  ru: 'Личный профиль объединяет identity преподавателя, нагрузку, фокус на текущий семестр и рабочие настройки панели.',
  en: 'The profile brings together teacher identity, workload, semester focus, and workspace settings.',
  kk: 'Профиль оқытушының identity-сін, жүктемесін, семестрлік фокусын және жұмыс кеңістігі баптауларын біріктіреді.',
);
final _roleTag = teacherText(
  ru: 'Learning architect',
  en: 'Learning architect',
  kk: 'Learning architect',
);
final _focusTag = teacherText(
  ru: 'Focus · course quality',
  en: 'Focus · course quality',
  kk: 'Focus · course quality',
);
final _metricOneLabel = teacherText(
  ru: 'Курсов в работе',
  en: 'Courses in flight',
  kk: 'Жұмыстағы курстар',
);
final _metricOneHint = teacherText(
  ru: 'Опубликованные и черновые курсы под одним преподавателем.',
  en: 'Published and in-progress courses owned by this teacher.',
  kk: 'Осы оқытушыға тиесілі жарияланған және жасалып жатқан курстар.',
);
final _metricTwoLabel = teacherText(
  ru: 'Активные потоки',
  en: 'Active cohorts',
  kk: 'Белсенді топтар',
);
final _metricTwoHint = teacherText(
  ru: 'Текущие группы, которые сейчас идут по программе.',
  en: 'The cohorts that are currently moving through the program.',
  kk: 'Қазір бағдарлама бойынша өтіп жатқан топтар.',
);
final _metricThreeLabel = teacherText(
  ru: 'Время на review',
  en: 'Time in review',
  kk: 'Review уақыты',
);
final _metricThreeHint = teacherText(
  ru: 'Средняя недельная нагрузка на проверку и Q&A.',
  en: 'Average weekly load for reviews and Q&A.',
  kk: 'Review және Q&A бойынша апталық орташа жүктеме.',
);
final _profileFocusTitle = teacherText(
  ru: 'Текущие приоритеты',
  en: 'Current priorities',
  kk: 'Ағымдағы приоритеттер',
);
final _profileFocusSubtitle = teacherText(
  ru: 'Эти блоки полезны, чтобы teacher profile был не только про биографию, но и про рабочий контекст.',
  en: 'These blocks help the profile speak to real working context, not just biography.',
  kk: 'Бұл блоктар профильді тек биография емес, нақты жұмыс контексті ретінде көрсетеді.',
);
final _focusOneTitle = teacherText(
  ru: 'Improve course completion',
  en: 'Improve course completion',
  kk: 'Improve course completion',
);
final _focusOneSubtitle = teacherText(
  ru: 'Главная цель семестра — довести completion SQL-трека выше 80%.',
  en: 'The main semester goal is to push SQL track completion above 80%.',
  kk: 'Семестрдің басты мақсаты — SQL трегінің completion көрсеткішін 80%-дан асыру.',
);
final _focusOneStatus = teacherText(
  ru: 'Outcome',
  en: 'Outcome',
  kk: 'Outcome',
);
final _focusTwoTitle = teacherText(
  ru: 'Ship the teacher panel MVP',
  en: 'Ship the teacher panel MVP',
  kk: 'Teacher panel MVP шығару',
);
final _focusTwoSubtitle = teacherText(
  ru: 'Generator, builder, assessment и analytics должны выглядеть как единая система.',
  en: 'Generator, builder, assessment, and analytics should feel like one system.',
  kk: 'Generator, builder, assessment және analytics бір жүйе сияқты көрінуі керек.',
);
final _focusTwoStatus = teacherText(
  ru: 'Product',
  en: 'Product',
  kk: 'Product',
);
final _focusThreeTitle = teacherText(
  ru: 'Mentor response SLA',
  en: 'Mentor response SLA',
  kk: 'Mentor response SLA',
);
final _focusThreeSubtitle = teacherText(
  ru: 'Цель — отвечать на критичные вопросы студентов максимум за 24 часа.',
  en: 'The target is to answer critical learner questions within 24 hours.',
  kk: 'Мақсат — студенттердің маңызды сұрақтарына 24 сағат ішінде жауап беру.',
);
final _focusThreeStatus = teacherText(
  ru: 'Support',
  en: 'Support',
  kk: 'Support',
);
