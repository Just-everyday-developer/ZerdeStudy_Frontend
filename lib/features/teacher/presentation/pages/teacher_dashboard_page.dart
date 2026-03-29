import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

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
                    label: _heroTagOne.resolve(locale),
                    accent: colors.primary,
                  ),
                  TeacherTag(
                    label: _heroTagTwo.resolve(locale),
                    accent: colors.success,
                  ),
                  TeacherTag(
                    label: _heroTagThree.resolve(locale),
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
                      icon: Icons.auto_fix_high_rounded,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.secondary(
                      label: _secondaryAction.resolve(locale),
                      icon: Icons.remove_red_eye_outlined,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 860;
            final tiles = [
              TeacherMetricTile(
                label: _metricCoursesLabel.resolve(locale),
                value: '12',
                hint: _metricCoursesHint.resolve(locale),
                icon: Icons.library_books_rounded,
                accent: colors.primary,
              ),
              TeacherMetricTile(
                label: _metricLearnersLabel.resolve(locale),
                value: '684',
                hint: _metricLearnersHint.resolve(locale),
                icon: Icons.groups_rounded,
                accent: colors.success,
              ),
              TeacherMetricTile(
                label: _metricCompletionLabel.resolve(locale),
                value: '78%',
                hint: _metricCompletionHint.resolve(locale),
                icon: Icons.insights_rounded,
                accent: colors.accent,
              ),
            ];

            if (compact) {
              return Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    tiles[i],
                    if (i != tiles.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  Expanded(child: tiles[i]),
                  if (i != tiles.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _focusTitle.resolve(locale),
          subtitle: _focusSubtitle.resolve(locale),
          accent: colors.success,
          child: Column(children: _todayRows(locale, colors)),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _healthTitle.resolve(locale),
          subtitle: _healthSubtitle.resolve(locale),
          accent: colors.accent,
          child: Column(children: _healthRows(locale, colors)),
        ),
      ],
    );
  }

  List<Widget> _todayRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _todayOneTitle.resolve(locale),
        _todayOneSubtitle.resolve(locale),
        _todayOneStatus.resolve(locale),
        colors.primary,
      ),
      (
        _todayTwoTitle.resolve(locale),
        _todayTwoSubtitle.resolve(locale),
        _todayTwoStatus.resolve(locale),
        colors.success,
      ),
      (
        _todayThreeTitle.resolve(locale),
        _todayThreeSubtitle.resolve(locale),
        _todayThreeStatus.resolve(locale),
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

  List<Widget> _healthRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _healthOneTitle.resolve(locale),
        _healthOneSubtitle.resolve(locale),
        _healthOneStatus.resolve(locale),
        colors.accent,
      ),
      (
        _healthTwoTitle.resolve(locale),
        _healthTwoSubtitle.resolve(locale),
        _healthTwoStatus.resolve(locale),
        colors.success,
      ),
      (
        _healthThreeTitle.resolve(locale),
        _healthThreeSubtitle.resolve(locale),
        _healthThreeStatus.resolve(locale),
        colors.danger,
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
  ru: 'Панель преподавателя',
  en: 'Teacher workspace',
  kk: 'Оқытушы панелі',
);
final _heroSubtitle = teacherText(
  ru: 'Следите за курсами, запускайте новые AI-черновики и быстро находите группы риска по вовлеченности.',
  en: 'Track live courses, launch new AI drafts, and quickly spot engagement risks.',
  kk: 'Белсенді курстарды бақылап, AI-нобайларды іске қосып, тәуекел топтарын тез табыңыз.',
);
final _heroTagOne = teacherText(
  ru: '3 курса требуют обновления',
  en: '3 courses need updates',
  kk: '3 курс жаңартуды қажет етеді',
);
final _heroTagTwo = teacherText(
  ru: '14 новых вопросов от студентов',
  en: '14 new learner questions',
  kk: 'Студенттерден 14 жаңа сұрақ',
);
final _heroTagThree = teacherText(
  ru: '2 AI-черновика готовы к публикации',
  en: '2 AI drafts are ready to publish',
  kk: '2 AI-нобай жариялауға дайын',
);
final _primaryAction = teacherText(
  ru: 'Создать новый курс',
  en: 'Create a new course',
  kk: 'Жаңа курс құру',
);
final _secondaryAction = teacherText(
  ru: 'Предпросмотр ученика',
  en: 'Student preview',
  kk: 'Студент көрінісі',
);
final _metricCoursesLabel = teacherText(
  ru: 'Активные курсы',
  en: 'Active courses',
  kk: 'Белсенді курстар',
);
final _metricCoursesHint = teacherText(
  ru: '9 опубликованы, 3 остаются в черновике.',
  en: '9 published, 3 still in draft.',
  kk: '9 курс жарияланған, 3-еуі әлі нобайда.',
);
final _metricLearnersLabel = teacherText(
  ru: 'Учащиеся в потоках',
  en: 'Learners across cohorts',
  kk: 'Топтардағы оқушылар',
);
final _metricLearnersHint = teacherText(
  ru: 'На этой неделе активность выросла на 9%.',
  en: 'Weekly learner activity is up by 9%.',
  kk: 'Осы аптада белсенділік 9%-ға өсті.',
);
final _metricCompletionLabel = teacherText(
  ru: 'Среднее завершение',
  en: 'Average completion',
  kk: 'Орташа аяқтау',
);
final _metricCompletionHint = teacherText(
  ru: 'Лучший курс удерживает 91% до последнего модуля.',
  en: 'The strongest course keeps 91% through the final module.',
  kk: 'Ең мықты курс соңғы модульге дейін 91% ұстап тұр.',
);
final _focusTitle = teacherText(
  ru: 'Что важно сегодня',
  en: 'What matters today',
  kk: 'Бүгінгі фокус',
);
final _focusSubtitle = teacherText(
  ru: 'Короткий рабочий список, чтобы день начинался с понятного next step.',
  en: 'A short operating list so the day starts with a clear next step.',
  kk: 'Күнді нақты келесі қадаммен бастауға арналған қысқа жұмыс тізімі.',
);
final _todayOneTitle = teacherText(
  ru: 'SQL for Analysts',
  en: 'SQL for Analysts',
  kk: 'SQL for Analysts',
);
final _todayOneSubtitle = teacherText(
  ru: 'После модуля про joins заметен резкий drop-off. Нужен более мягкий bridge-lesson.',
  en: 'A steep drop-off appears after the joins module. It needs a softer bridge lesson.',
  kk: 'Joins модулінен кейін күрт төмендеу бар. Жұмсақ bridge-сабақ керек.',
);
final _todayOneStatus = teacherText(
  ru: 'Требует ревизии',
  en: 'Needs revision',
  kk: 'Қайта қарау керек',
);
final _todayTwoTitle = teacherText(
  ru: 'Frontend Sprint Bootcamp',
  en: 'Frontend Sprint Bootcamp',
  kk: 'Frontend Sprint Bootcamp',
);
final _todayTwoSubtitle = teacherText(
  ru: 'AI-черновик нового модуля уже собран и готов к ручному редактированию.',
  en: 'The AI draft for the new module is ready for manual editing.',
  kk: 'Жаңа модульдің AI-нобайы қолмен өңдеуге дайын.',
);
final _todayTwoStatus = teacherText(
  ru: 'Готово к сборке',
  en: 'Ready to build',
  kk: 'Құрастыруға дайын',
);
final _todayThreeTitle = teacherText(
  ru: 'Discrete Math Core',
  en: 'Discrete Math Core',
  kk: 'Discrete Math Core',
);
final _todayThreeSubtitle = teacherText(
  ru: 'У студентов выросло число вопросов к практике. Стоит обновить rubric и примеры.',
  en: 'Practice questions are growing. Update the rubric and worked examples.',
  kk: 'Практикаға сұрақтар көбейді. Rubric пен мысалдарды жаңарту қажет.',
);
final _todayThreeStatus = teacherText(
  ru: 'Нужно ответить',
  en: 'Reply needed',
  kk: 'Жауап беру керек',
);
final _healthTitle = teacherText(
  ru: 'Здоровье курсов',
  en: 'Course health',
  kk: 'Курс денсаулығы',
);
final _healthSubtitle = teacherText(
  ru: 'Ключевые сигналы, по которым преподаватель видит, где курс теряет темп.',
  en: 'Signals that show where a course is losing momentum.',
  kk: 'Курстың қай жерде қарқынын жоғалтып жатқанын көрсететін сигналдар.',
);
final _healthOneTitle = teacherText(
  ru: 'Drop-off alert: Git & Collaboration',
  en: 'Drop-off alert: Git & Collaboration',
  kk: 'Drop-off alert: Git & Collaboration',
);
final _healthOneSubtitle = teacherText(
  ru: '26% учащихся не доходят до второго задания. Рекомендуется shorter recap before the assignment.',
  en: '26% of learners do not reach the second assignment. Add a shorter recap first.',
  kk: 'Оқушылардың 26%-ы екінші тапсырмаға жетпейді. Алдымен қысқа recap қосыңыз.',
);
final _healthOneStatus = teacherText(
  ru: 'Риск удержания',
  en: 'Retention risk',
  kk: 'Ұстап қалу тәуекелі',
);
final _healthTwoTitle = teacherText(
  ru: 'High confidence: CSS Layout Lab',
  en: 'High confidence: CSS Layout Lab',
  kk: 'High confidence: CSS Layout Lab',
);
final _healthTwoSubtitle = teacherText(
  ru: 'Quiz accuracy держится на 88%, а feedback по уроку стабильно положительный.',
  en: 'Quiz accuracy holds at 88% and lesson feedback stays consistently positive.',
  kk: 'Quiz accuracy 88% деңгейінде, ал сабақ пікірі тұрақты түрде оң.',
);
final _healthTwoStatus = teacherText(
  ru: 'Сильный модуль',
  en: 'Strong module',
  kk: 'Күшті модуль',
);
final _healthThreeTitle = teacherText(
  ru: 'Escalation: API Security Clinic',
  en: 'Escalation: API Security Clinic',
  kk: 'Escalation: API Security Clinic',
);
final _healthThreeSubtitle = teacherText(
  ru: 'Слишком много однотипных вопросов в Q&A. Контенту нужен clarifying walkthrough.',
  en: 'Too many repeated Q&A threads. The content needs a clarifying walkthrough.',
  kk: 'Q&A ішінде қайталанатын сұрақтар көп. Контентке түсіндіретін walkthrough керек.',
);
final _healthThreeStatus = teacherText(
  ru: 'Контент неясен',
  en: 'Content friction',
  kk: 'Контент түсініксіз',
);
