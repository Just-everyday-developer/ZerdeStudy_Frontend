import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherAiGeneratorPage extends ConsumerWidget {
  const TeacherAiGeneratorPage({super.key});

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
                    accent: colors.accent,
                  ),
                  TeacherTag(
                    label: _tagThree.resolve(locale),
                    accent: colors.success,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: _generateAction.resolve(locale),
                icon: Icons.auto_awesome_rounded,
                onPressed: () {},
                maxWidth: 280,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _promptTitle.resolve(locale),
          subtitle: _promptSubtitle.resolve(locale),
          accent: colors.accent,
          child: Column(children: _promptRows(locale, colors)),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _draftsTitle.resolve(locale),
          subtitle: _draftsSubtitle.resolve(locale),
          accent: colors.success,
          child: Column(children: _draftRows(locale, colors)),
        ),
      ],
    );
  }

  List<Widget> _promptRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _promptOneTitle.resolve(locale),
        _promptOneSubtitle.resolve(locale),
        _promptOneStatus.resolve(locale),
        colors.primary,
      ),
      (
        _promptTwoTitle.resolve(locale),
        _promptTwoSubtitle.resolve(locale),
        _promptTwoStatus.resolve(locale),
        colors.accent,
      ),
      (
        _promptThreeTitle.resolve(locale),
        _promptThreeSubtitle.resolve(locale),
        _promptThreeStatus.resolve(locale),
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

  List<Widget> _draftRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _draftOneTitle.resolve(locale),
        _draftOneSubtitle.resolve(locale),
        _draftOneStatus.resolve(locale),
        colors.success,
      ),
      (
        _draftTwoTitle.resolve(locale),
        _draftTwoSubtitle.resolve(locale),
        _draftTwoStatus.resolve(locale),
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
          trailing: Icon(
            Icons.arrow_outward_rounded,
            color: rows[i].$4,
            size: 18,
          ),
        ),
        if (i != rows.length - 1) const SizedBox(height: 12),
      ],
    ];
  }
}

final _heroTitle = teacherText(
  ru: 'AI Course Generator',
  en: 'AI Course Generator',
  kk: 'AI Course Generator',
);
final _heroSubtitle = teacherText(
  ru: 'Генерируйте черновик курса по теме, аудитории, длительности и желаемому outcome, а затем сразу отправляйте его в builder.',
  en: 'Generate a course draft from topic, audience, duration, and target outcome, then send it straight into the builder.',
  kk: 'Тақырып, аудитория, ұзақтық және нәтиже бойынша курс нобайын жасап, оны бірден builder-ге жіберіңіз.',
);
final _tagOne = teacherText(
  ru: 'Learning outcomes mapped',
  en: 'Learning outcomes mapped',
  kk: 'Learning outcomes mapped',
);
final _tagTwo = teacherText(
  ru: 'Quiz skeleton included',
  en: 'Quiz skeleton included',
  kk: 'Quiz skeleton included',
);
final _tagThree = teacherText(
  ru: 'Localization-aware draft',
  en: 'Localization-aware draft',
  kk: 'Localization-aware draft',
);
final _generateAction = teacherText(
  ru: 'Сгенерировать новый курс',
  en: 'Generate a new course',
  kk: 'Жаңа курс генерациялау',
);
final _promptTitle = teacherText(
  ru: 'Быстрые шаблоны генерации',
  en: 'Fast generation presets',
  kk: 'Жылдам генерация пресеттері',
);
final _promptSubtitle = teacherText(
  ru: 'Пресеты помогают быстро собирать курсы под конкретный формат работы преподавателя.',
  en: 'Presets help spin up courses around a clear teaching format.',
  kk: 'Пресеттер курсты нақты оқыту форматына тез бейімдеуге көмектеседі.',
);
final _promptOneTitle = teacherText(
  ru: 'Bootcamp in 2 weeks',
  en: 'Bootcamp in 2 weeks',
  kk: 'Bootcamp in 2 weeks',
);
final _promptOneSubtitle = teacherText(
  ru: 'Интенсив с ежедневными уроками, checkpoint quiz и финальным мини-проектом.',
  en: 'An intensive flow with daily lessons, checkpoint quizzes, and a final mini-project.',
  kk: 'Күнделікті сабақтары, checkpoint quiz және финалдық mini-project бар интенсив.',
);
final _promptOneStatus = teacherText(
  ru: 'Интенсив',
  en: 'Intensive',
  kk: 'Интенсив',
);
final _promptTwoTitle = teacherText(
  ru: 'Semester companion',
  en: 'Semester companion',
  kk: 'Semester companion',
);
final _promptTwoSubtitle = teacherText(
  ru: 'Растянутый курс с weekly discussions, домашними заданиями и rubric-based review.',
  en: 'A stretched semester flow with weekly discussions and rubric-based review.',
  kk: 'Weekly discussions және rubric-based review бар семестрлік курс.',
);
final _promptTwoStatus = teacherText(
  ru: 'Семестр',
  en: 'Semester',
  kk: 'Семестр',
);
final _promptThreeTitle = teacherText(
  ru: 'Micro-course for remediation',
  en: 'Micro-course for remediation',
  kk: 'Micro-course for remediation',
);
final _promptThreeSubtitle = teacherText(
  ru: 'Короткая corrective-траектория для студентов, которые застряли на одном модуле.',
  en: 'A short corrective path for learners stuck on a single module.',
  kk: 'Бір модульде тұрып қалған студенттерге арналған қысқа corrective курс.',
);
final _promptThreeStatus = teacherText(
  ru: 'Ремедиация',
  en: 'Remediation',
  kk: 'Ремедиация',
);
final _draftsTitle = teacherText(
  ru: 'Последние AI-черновики',
  en: 'Recent AI drafts',
  kk: 'Соңғы AI-нобайлар',
);
final _draftsSubtitle = teacherText(
  ru: 'Здесь преподаватель быстро видит, что уже готово к редактуре или публикации.',
  en: 'A quick look at what is ready for editing or publishing.',
  kk: 'Өңдеуге немесе жариялауға дайын материалдарды жылдам көруге болады.',
);
final _draftOneTitle = teacherText(
  ru: 'Data Storytelling for Analysts',
  en: 'Data Storytelling for Analysts',
  kk: 'Data Storytelling for Analysts',
);
final _draftOneSubtitle = teacherText(
  ru: '6 модулей, 18 уроков, 2 итоговых задания и onboarding lesson уже собраны.',
  en: '6 modules, 18 lessons, 2 capstones, and an onboarding lesson are already generated.',
  kk: '6 модуль, 18 сабақ, 2 қорытынды тапсырма және onboarding lesson дайын.',
);
final _draftOneStatus = teacherText(
  ru: 'Готов к builder',
  en: 'Ready for builder',
  kk: 'Builder-ге дайын',
);
final _draftTwoTitle = teacherText(
  ru: 'API Observability Sprint',
  en: 'API Observability Sprint',
  kk: 'API Observability Sprint',
);
final _draftTwoSubtitle = teacherText(
  ru: 'Контент собран, но rubric и question bank требуют ручной доработки.',
  en: 'The content is generated, but the rubric and question bank still need manual tuning.',
  kk: 'Контент дайын, бірақ rubric пен question bank әлі қолмен бапталуы керек.',
);
final _draftTwoStatus = teacherText(
  ru: 'Нужна доработка',
  en: 'Needs tuning',
  kk: 'Баптау керек',
);
