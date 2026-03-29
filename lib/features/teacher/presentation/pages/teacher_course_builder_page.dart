import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherCourseBuilderPage extends ConsumerWidget {
  const TeacherCourseBuilderPage({super.key});

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
              AppButton.primary(
                label: _primaryAction.resolve(locale),
                icon: Icons.edit_note_rounded,
                onPressed: () {},
                maxWidth: 320,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _outlineTitle.resolve(locale),
          subtitle: _outlineSubtitle.resolve(locale),
          accent: colors.accent,
          child: Column(children: _outlineRows(locale, colors)),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _editingTitle.resolve(locale),
          subtitle: _editingSubtitle.resolve(locale),
          accent: colors.success,
          child: Column(children: _editingRows(locale, colors)),
        ),
      ],
    );
  }

  List<Widget> _outlineRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _moduleOneTitle.resolve(locale),
        _moduleOneSubtitle.resolve(locale),
        _moduleOneStatus.resolve(locale),
        colors.primary,
      ),
      (
        _moduleTwoTitle.resolve(locale),
        _moduleTwoSubtitle.resolve(locale),
        _moduleTwoStatus.resolve(locale),
        colors.accent,
      ),
      (
        _moduleThreeTitle.resolve(locale),
        _moduleThreeSubtitle.resolve(locale),
        _moduleThreeStatus.resolve(locale),
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

  List<Widget> _editingRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _toolOneTitle.resolve(locale),
        _toolOneSubtitle.resolve(locale),
        _toolOneStatus.resolve(locale),
        colors.success,
      ),
      (
        _toolTwoTitle.resolve(locale),
        _toolTwoSubtitle.resolve(locale),
        _toolTwoStatus.resolve(locale),
        colors.primary,
      ),
      (
        _toolThreeTitle.resolve(locale),
        _toolThreeSubtitle.resolve(locale),
        _toolThreeStatus.resolve(locale),
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
  ru: 'Course Builder',
  en: 'Course Builder',
  kk: 'Course Builder',
);
final _heroSubtitle = teacherText(
  ru: 'Собирайте программу по модулям и урокам, редактируйте структуру знаний и настраивайте release logic без выхода из панели.',
  en: 'Build the syllabus by modules and lessons, tune the knowledge flow, and control release logic in one place.',
  kk: 'Бағдарламаны модульдер мен сабақтар бойынша құрып, білім логикасын және release flow-ды бір жерден басқарыңыз.',
);
final _tagOne = teacherText(
  ru: 'Drag-and-drop outline',
  en: 'Drag-and-drop outline',
  kk: 'Drag-and-drop outline',
);
final _tagTwo = teacherText(
  ru: 'Student preview ready',
  en: 'Student preview ready',
  kk: 'Student preview ready',
);
final _tagThree = teacherText(
  ru: 'Version history tracked',
  en: 'Version history tracked',
  kk: 'Version history tracked',
);
final _primaryAction = teacherText(
  ru: 'Открыть текущую сборку курса',
  en: 'Open the current course build',
  kk: 'Ағымдағы курс жинағын ашу',
);
final _outlineTitle = teacherText(
  ru: 'Текущая структура курса',
  en: 'Current course outline',
  kk: 'Ағымдағы курс құрылымы',
);
final _outlineSubtitle = teacherText(
  ru: 'Преподаватель видит, какие модули уже собраны, какие блоки еще пустые и где нужен AI assist.',
  en: 'See which modules are ready, which blocks are still empty, and where AI assist is needed.',
  kk: 'Қай модульдер дайын, қай блоктар бос және қай жерде AI assist керек екенін көріңіз.',
);
final _moduleOneTitle = teacherText(
  ru: 'Module 1 · Foundations and context',
  en: 'Module 1 · Foundations and context',
  kk: 'Module 1 · Foundations and context',
);
final _moduleOneSubtitle = teacherText(
  ru: '3 урока, вводный quiz и карта терминов уже готовы.',
  en: '3 lessons, an intro quiz, and the glossary map are already complete.',
  kk: '3 сабақ, intro quiz және терминдер картасы дайын.',
);
final _moduleOneStatus = teacherText(ru: 'Собрано', en: 'Built', kk: 'Жиналды');
final _moduleTwoTitle = teacherText(
  ru: 'Module 2 · Guided practice',
  en: 'Module 2 · Guided practice',
  kk: 'Module 2 · Guided practice',
);
final _moduleTwoSubtitle = teacherText(
  ru: 'Нужно добавить worked example и контрольные вопросы перед assignment.',
  en: 'Add a worked example and knowledge checks before the assignment.',
  kk: 'Assignment алдында worked example және knowledge checks қосу керек.',
);
final _moduleTwoStatus = teacherText(
  ru: 'В работе',
  en: 'In progress',
  kk: 'Жұмыста',
);
final _moduleThreeTitle = teacherText(
  ru: 'Module 3 · Capstone delivery',
  en: 'Module 3 · Capstone delivery',
  kk: 'Module 3 · Capstone delivery',
);
final _moduleThreeSubtitle = teacherText(
  ru: 'Финальный проект создан, но release зависит от rubric и publish rules.',
  en: 'The capstone exists, but release still depends on rubric and publish rules.',
  kk: 'Финалдық жоба жасалған, бірақ release әлі rubric пен publish rules-қа тәуелді.',
);
final _moduleThreeStatus = teacherText(
  ru: 'Заблокировано',
  en: 'Blocked',
  kk: 'Бұғатталған',
);
final _editingTitle = teacherText(
  ru: 'Инструменты редактирования',
  en: 'Editing tools',
  kk: 'Өңдеу құралдары',
);
final _editingSubtitle = teacherText(
  ru: 'Главные возможности конструктора, на которые мы потом можем опереть UX детальнее.',
  en: 'The key builder capabilities we can later turn into richer UX.',
  kk: 'Кейін UX-ті тереңдетуге болатын негізгі конструктор мүмкіндіктері.',
);
final _toolOneTitle = teacherText(
  ru: 'Block editor',
  en: 'Block editor',
  kk: 'Block editor',
);
final _toolOneSubtitle = teacherText(
  ru: 'Текст, видео, quiz, assignment, discussion и AI hint как единые блоки урока.',
  en: 'Text, video, quiz, assignment, discussion, and AI hint blocks in one lesson.',
  kk: 'Text, video, quiz, assignment, discussion және AI hint блоктары бір сабақта.',
);
final _toolOneStatus = teacherText(
  ru: 'Core tool',
  en: 'Core tool',
  kk: 'Core tool',
);
final _toolTwoTitle = teacherText(
  ru: 'Knowledge tree mapping',
  en: 'Knowledge tree mapping',
  kk: 'Knowledge tree mapping',
);
final _toolTwoSubtitle = teacherText(
  ru: 'Привязка уроков к prerequisite-узлам и outcomes для адаптивного пути.',
  en: 'Attach lessons to prerequisite nodes and outcomes for adaptive flow.',
  kk: 'Сабақтарды prerequisite түйіндері мен outcomes-қа байлау.',
);
final _toolTwoStatus = teacherText(
  ru: 'Curriculum logic',
  en: 'Curriculum logic',
  kk: 'Curriculum logic',
);
final _toolThreeTitle = teacherText(
  ru: 'Version timeline',
  en: 'Version timeline',
  kk: 'Version timeline',
);
final _toolThreeSubtitle = teacherText(
  ru: 'Черновики, публикации и rollback points для безопасного обновления курса.',
  en: 'Drafts, publish points, and rollback checkpoints for safe course updates.',
  kk: 'Курсты қауіпсіз жаңарту үшін drafts, publish points және rollback checkpoints.',
);
final _toolThreeStatus = teacherText(
  ru: 'Must-have',
  en: 'Must-have',
  kk: 'Маңызды',
);
