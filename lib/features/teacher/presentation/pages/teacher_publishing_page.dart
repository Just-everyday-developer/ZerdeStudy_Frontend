import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherPublishingPage extends ConsumerWidget {
  const TeacherPublishingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;

    return TeacherPageScrollView(
      children: [
        TeacherSectionCard(
          title: _heroTitle.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
          accent: colors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  TeacherTag(
                    label: _tagOne.resolve(locale),
                    accent: colors.primary,
                  ),
                  TeacherTag(
                    label: _tagTwo.resolve(locale),
                    accent: colors.success,
                  ),
                  TeacherTag(
                    label: _tagThree.resolve(locale),
                    accent: colors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppButton.primary(
                      label: _primaryAction.resolve(locale),
                      icon: Icons.publish_rounded,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.secondary(
                      label: _secondaryAction.resolve(locale),
                      icon: Icons.visibility_rounded,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _checklistTitle.resolve(locale),
          subtitle: _checklistSubtitle.resolve(locale),
          accent: colors.success,
          child: Column(children: _checklistRows(locale, colors)),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _releaseTitle.resolve(locale),
          subtitle: _releaseSubtitle.resolve(locale),
          accent: colors.accent,
          child: Column(children: _releaseRows(locale, colors)),
        ),
      ],
    );
  }

  List<Widget> _checklistRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _checkOneTitle.resolve(locale),
        _checkOneSubtitle.resolve(locale),
        _checkOneStatus.resolve(locale),
        colors.success,
      ),
      (
        _checkTwoTitle.resolve(locale),
        _checkTwoSubtitle.resolve(locale),
        _checkTwoStatus.resolve(locale),
        colors.accent,
      ),
      (
        _checkThreeTitle.resolve(locale),
        _checkThreeSubtitle.resolve(locale),
        _checkThreeStatus.resolve(locale),
        colors.primary,
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

  List<Widget> _releaseRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _releaseOneTitle.resolve(locale),
        _releaseOneSubtitle.resolve(locale),
        _releaseOneStatus.resolve(locale),
        colors.primary,
      ),
      (
        _releaseTwoTitle.resolve(locale),
        _releaseTwoSubtitle.resolve(locale),
        _releaseTwoStatus.resolve(locale),
        colors.accent,
      ),
      (
        _releaseThreeTitle.resolve(locale),
        _releaseThreeSubtitle.resolve(locale),
        _releaseThreeStatus.resolve(locale),
        colors.success,
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
  ru: 'Publishing / Preview',
  en: 'Publishing / Preview',
  kk: 'Publishing / Preview',
);
final _heroSubtitle = teacherText(
  ru: 'Перед публикацией преподаватель должен увидеть курс глазами студента, проверить release rules и убедиться, что сертификаты и дедлайны настроены.',
  en: 'Before publishing, a teacher should preview the course as a learner, verify release rules, and confirm certificate and deadline settings.',
  kk: 'Жариялау алдында оқытушы курсты студент көзімен көріп, release rules, сертификат және дедлайн баптауларын тексеруі керек.',
);
final _tagOne = teacherText(
  ru: 'Student preview',
  en: 'Student preview',
  kk: 'Student preview',
);
final _tagTwo = teacherText(
  ru: 'Release schedule',
  en: 'Release schedule',
  kk: 'Release schedule',
);
final _tagThree = teacherText(
  ru: 'Certificate rules',
  en: 'Certificate rules',
  kk: 'Certificate rules',
);
final _primaryAction = teacherText(
  ru: 'Подготовить публикацию',
  en: 'Prepare publishing',
  kk: 'Жариялауды дайындау',
);
final _secondaryAction = teacherText(
  ru: 'Открыть preview',
  en: 'Open preview',
  kk: 'Preview ашу',
);
final _checklistTitle = teacherText(
  ru: 'Checklist перед публикацией',
  en: 'Pre-publish checklist',
  kk: 'Жариялау алдындағы checklist',
);
final _checklistSubtitle = teacherText(
  ru: 'Контрольный список должен быть виден прямо в интерфейсе, чтобы релиз курса был предсказуемым.',
  en: 'The checklist should live in the interface so course releases stay predictable.',
  kk: 'Checklist интерфейстің өзінде болуы керек, сонда курс релизі болжамды болады.',
);
final _checkOneTitle = teacherText(
  ru: 'Контент завершен',
  en: 'Content is complete',
  kk: 'Контент толық',
);
final _checkOneSubtitle = teacherText(
  ru: 'У каждого модуля есть lesson content, knowledge check и следующий шаг.',
  en: 'Every module includes lesson content, a knowledge check, and a next step.',
  kk: 'Әр модульде lesson content, knowledge check және келесі қадам бар.',
);
final _checkOneStatus = teacherText(ru: 'OK', en: 'OK', kk: 'OK');
final _checkTwoTitle = teacherText(
  ru: 'Preview на мобильном',
  en: 'Mobile preview',
  kk: 'Mobile preview',
);
final _checkTwoSubtitle = teacherText(
  ru: 'Нужно убедиться, что lesson blocks не ломаются в компактном виде.',
  en: 'Verify that lesson blocks do not break in the compact/mobile layout.',
  kk: 'Lesson blocks ықшам көріністе бұзылмайтынын тексеру керек.',
);
final _checkTwoStatus = teacherText(
  ru: 'Проверить',
  en: 'Verify',
  kk: 'Тексеру',
);
final _checkThreeTitle = teacherText(
  ru: 'Badge / certificate rules',
  en: 'Badge / certificate rules',
  kk: 'Badge / certificate rules',
);
final _checkThreeSubtitle = teacherText(
  ru: 'Условия завершения и выдачи сертификата должны совпадать с rubric and scoring.',
  en: 'Completion and certificate rules must match the rubric and scoring model.',
  kk: 'Аяқтау мен сертификат шарттары rubric және scoring моделіне сәйкес болуы керек.',
);
final _checkThreeStatus = teacherText(
  ru: 'Согласовано',
  en: 'Aligned',
  kk: 'Сәйкес',
);
final _releaseTitle = teacherText(
  ru: 'Release strategy',
  en: 'Release strategy',
  kk: 'Release strategy',
);
final _releaseSubtitle = teacherText(
  ru: 'Учебный курс редко публикуется одной кнопкой: чаще нужен staged rollout и понятный publish plan.',
  en: 'Courses rarely ship in one step; they usually need a staged rollout and a clear publish plan.',
  kk: 'Курс көбіне бір батырмамен жарияланбайды: staged rollout және анық publish plan керек.',
);
final _releaseOneTitle = teacherText(
  ru: 'Private beta',
  en: 'Private beta',
  kk: 'Private beta',
);
final _releaseOneSubtitle = teacherText(
  ru: 'Сначала курс открывается для пилотной группы, чтобы проверить friction points.',
  en: 'Release first to a pilot group to identify friction points.',
  kk: 'Алдымен friction points-ті табу үшін курс пилоттық топқа ашылады.',
);
final _releaseOneStatus = teacherText(ru: 'Pilot', en: 'Pilot', kk: 'Pilot');
final _releaseTwoTitle = teacherText(
  ru: 'Scheduled modules',
  en: 'Scheduled modules',
  kk: 'Scheduled modules',
);
final _releaseTwoSubtitle = teacherText(
  ru: 'Модули открываются по неделям, а не сразу все вместе.',
  en: 'Modules unlock week by week instead of all at once.',
  kk: 'Модульдер бірден емес, апта сайын ашылады.',
);
final _releaseTwoStatus = teacherText(
  ru: 'Drip mode',
  en: 'Drip mode',
  kk: 'Drip mode',
);
final _releaseThreeTitle = teacherText(
  ru: 'Announcements and reminders',
  en: 'Announcements and reminders',
  kk: 'Announcements and reminders',
);
final _releaseThreeSubtitle = teacherText(
  ru: 'Автоматические напоминания снижают drop-off при старте нового модуля.',
  en: 'Automated reminders reduce drop-off when a new module starts.',
  kk: 'Автоматты еске салғыштар жаңа модуль басталғандағы drop-off-ты азайтады.',
);
final _releaseThreeStatus = teacherText(
  ru: 'Retention support',
  en: 'Retention support',
  kk: 'Retention support',
);
