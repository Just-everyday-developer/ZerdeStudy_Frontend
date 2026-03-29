import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherAnalyticsPage extends ConsumerWidget {
  const TeacherAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;

    return TeacherPageScrollView(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 860;
            final metrics = [
              TeacherMetricTile(
                label: _metricOneLabel.resolve(locale),
                value: '84%',
                hint: _metricOneHint.resolve(locale),
                icon: Icons.play_circle_outline_rounded,
                accent: colors.primary,
              ),
              TeacherMetricTile(
                label: _metricTwoLabel.resolve(locale),
                value: '61%',
                hint: _metricTwoHint.resolve(locale),
                icon: Icons.trending_down_rounded,
                accent: colors.accent,
              ),
              TeacherMetricTile(
                label: _metricThreeLabel.resolve(locale),
                value: '4.7/5',
                hint: _metricThreeHint.resolve(locale),
                icon: Icons.star_outline_rounded,
                accent: colors.success,
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
          title: _insightsTitle.resolve(locale),
          subtitle: _insightsSubtitle.resolve(locale),
          accent: colors.primary,
          child: Column(children: _insightRows(locale, colors)),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _recommendedTitle.resolve(locale),
          subtitle: _recommendedSubtitle.resolve(locale),
          accent: colors.accent,
          child: Column(children: _recommendedRows(locale, colors)),
        ),
      ],
    );
  }

  List<Widget> _insightRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _insightOneTitle.resolve(locale),
        _insightOneSubtitle.resolve(locale),
        _insightOneStatus.resolve(locale),
        colors.accent,
      ),
      (
        _insightTwoTitle.resolve(locale),
        _insightTwoSubtitle.resolve(locale),
        _insightTwoStatus.resolve(locale),
        colors.success,
      ),
      (
        _insightThreeTitle.resolve(locale),
        _insightThreeSubtitle.resolve(locale),
        _insightThreeStatus.resolve(locale),
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

  List<Widget> _recommendedRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _recommendedOneTitle.resolve(locale),
        _recommendedOneSubtitle.resolve(locale),
        _recommendedOneStatus.resolve(locale),
        colors.primary,
      ),
      (
        _recommendedTwoTitle.resolve(locale),
        _recommendedTwoSubtitle.resolve(locale),
        _recommendedTwoStatus.resolve(locale),
        colors.success,
      ),
      (
        _recommendedThreeTitle.resolve(locale),
        _recommendedThreeSubtitle.resolve(locale),
        _recommendedThreeStatus.resolve(locale),
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

final _metricOneLabel = teacherText(
  ru: 'Activation rate',
  en: 'Activation rate',
  kk: 'Activation rate',
);
final _metricOneHint = teacherText(
  ru: 'Сколько записавшихся реально открыли первый урок.',
  en: 'How many enrolled learners actually opened the first lesson.',
  kk: 'Жазылғандардың қаншасы бірінші сабақты шын мәнінде ашты.',
);
final _metricTwoLabel = teacherText(
  ru: 'Доходят до capstone',
  en: 'Reach the capstone',
  kk: 'Capstone-ға жетеді',
);
final _metricTwoHint = teacherText(
  ru: 'Самая чувствительная метрика удержания курса.',
  en: 'The most sensitive metric for course retention.',
  kk: 'Курсты ұстап қалудың ең сезімтал метрикасы.',
);
final _metricThreeLabel = teacherText(
  ru: 'Оценка курса',
  en: 'Course satisfaction',
  kk: 'Курс бағасы',
);
final _metricThreeHint = teacherText(
  ru: 'Средняя оценка после последних двух итераций.',
  en: 'Average learner rating after the last two iterations.',
  kk: 'Соңғы екі итерациядан кейінгі орташа рейтинг.',
);
final _insightsTitle = teacherText(
  ru: 'Главные инсайты',
  en: 'Top insights',
  kk: 'Негізгі инсайттар',
);
final _insightsSubtitle = teacherText(
  ru: 'Не просто графики, а выводы, на которые преподаватель может отреагировать.',
  en: 'Not just charts, but conclusions a teacher can act on.',
  kk: 'Жай график емес, оқытушы әрекет ете алатын қорытындылар.',
);
final _insightOneTitle = teacherText(
  ru: 'Drop-off after lesson 4',
  en: 'Drop-off after lesson 4',
  kk: 'Drop-off after lesson 4',
);
final _insightOneSubtitle = teacherText(
  ru: 'На lesson 4 резко растет время прохождения и падает accuracy по quiz.',
  en: 'Lesson 4 shows a time spike and a drop in quiz accuracy.',
  kk: '4-сабақта уақыт күрт өсіп, quiz accuracy төмендейді.',
);
final _insightOneStatus = teacherText(
  ru: 'Friction point',
  en: 'Friction point',
  kk: 'Friction point',
);
final _insightTwoTitle = teacherText(
  ru: 'Discussion boosts completion',
  en: 'Discussion boosts completion',
  kk: 'Discussion boosts completion',
);
final _insightTwoSubtitle = teacherText(
  ru: 'Группы, где преподаватель отвечает в Q&A в течение 24 часов, завершают курс заметно чаще.',
  en: 'Cohorts with teacher replies inside 24 hours complete far more often.',
  kk: 'Оқытушы 24 сағат ішінде жауап берген топтар курсты жиірек аяқтайды.',
);
final _insightTwoStatus = teacherText(
  ru: 'Positive signal',
  en: 'Positive signal',
  kk: 'Positive signal',
);
final _insightThreeTitle = teacherText(
  ru: 'Assignment rubric mismatch',
  en: 'Assignment rubric mismatch',
  kk: 'Assignment rubric mismatch',
);
final _insightThreeSubtitle = teacherText(
  ru: 'Высокий процент пересдач говорит, что ожидания задачи объяснены не до конца.',
  en: 'The high resubmission rate suggests the task expectations are not explicit enough.',
  kk: 'Қайта тапсыру пайызы жоғары болса, тапсырма күтулері жеткілікті түсіндірілмеген.',
);
final _insightThreeStatus = teacherText(
  ru: 'Needs rubric fix',
  en: 'Needs rubric fix',
  kk: 'Rubric түзету керек',
);
final _recommendedTitle = teacherText(
  ru: 'Рекомендуемые действия',
  en: 'Recommended actions',
  kk: 'Ұсынылған әрекеттер',
);
final _recommendedSubtitle = teacherText(
  ru: 'Аналитика должна подсказывать учителю, что менять дальше, а не просто показывать цифры.',
  en: 'Analytics should recommend the next teacher action, not just display numbers.',
  kk: 'Аналитика тек сандарды емес, келесі мұғалім әрекетін де ұсынуы керек.',
);
final _recommendedOneTitle = teacherText(
  ru: 'Сделать bridge-lesson',
  en: 'Add a bridge lesson',
  kk: 'Bridge-lesson қосу',
);
final _recommendedOneSubtitle = teacherText(
  ru: 'Короткий вводный блок между theory и practice уменьшит cognitive jump.',
  en: 'A short bridge between theory and practice should reduce the cognitive jump.',
  kk: 'Theory мен practice арасындағы қысқа блок cognitive jump-ты азайтады.',
);
final _recommendedOneStatus = teacherText(
  ru: 'Content fix',
  en: 'Content fix',
  kk: 'Контент түзету',
);
final _recommendedTwoTitle = teacherText(
  ru: 'Автоматизировать reminders',
  en: 'Automate reminders',
  kk: 'Reminders автоматтандыру',
);
final _recommendedTwoSubtitle = teacherText(
  ru: 'Push/email напоминания перед дедлайном повышают submission rate.',
  en: 'Push/email reminders before a deadline improve submission rate.',
  kk: 'Дедлайн алдындағы push/email reminders submission rate-ты көтереді.',
);
final _recommendedTwoStatus = teacherText(
  ru: 'Operational',
  en: 'Operational',
  kk: 'Operational',
);
final _recommendedThreeTitle = teacherText(
  ru: 'Пересмотреть question difficulty',
  en: 'Revisit question difficulty',
  kk: 'Question difficulty қайта қарау',
);
final _recommendedThreeSubtitle = teacherText(
  ru: 'Три вопроса подряд с fail-rate выше 60% ломают ритм проверки знаний.',
  en: 'Three consecutive questions above 60% fail rate break the knowledge-check rhythm.',
  kk: '60%-дан жоғары fail-rate бар үш сұрақ қатар келсе, тексеру ырғағы бұзылады.',
);
final _recommendedThreeStatus = teacherText(
  ru: 'Assessment tuning',
  en: 'Assessment tuning',
  kk: 'Assessment tuning',
);
