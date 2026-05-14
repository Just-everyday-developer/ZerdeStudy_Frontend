import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../ai/presentation/providers/ai_chat_controller.dart';
import '../widgets/premium_code_editor.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

enum LessonStepKind { theory, quiz, trainer, code }

class LessonStep {
  const LessonStep({required this.kind, this.quiz, this.trainer, this.id});
  final LessonStepKind kind;
  final LessonQuiz? quiz;
  final CodeTrainer? trainer;
  final String? id;
}

class _LessonPageState extends ConsumerState<LessonPage> {
  final Map<String, String> _selectedQuizAnswers = <String, String>{};
  final Map<String, String> _selectedTrainerAnswers = <String, String>{};
  final Map<String, List<String>> _trainerSequences = <String, List<String>>{};
  final ScrollController _theoryScrollController = ScrollController();
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _theoryScrollController.addListener(_onTheoryScroll);
  }

  @override
  void dispose() {
    _theoryScrollController.dispose();
    super.dispose();
  }

  void _onTheoryScroll() {
    if (_theoryScrollController.position.pixels >= 
        _theoryScrollController.position.maxScrollExtent - 50) {
      final controller = ref.read(demoAppControllerProvider.notifier);
      controller.completeTheoryStep('${widget.lessonId}_theory');
    }
  }

  List<LessonStep> _buildSteps(LessonItem lesson) {
    final steps = <LessonStep>[];
    
    // Step 1: Theory
    steps.add(LessonStep(kind: LessonStepKind.theory, id: '${widget.lessonId}_theory'));

    // 5 Quiz steps
    for (int i = 0; i < 5; i++) {
      final quiz = lesson.quizzes.isNotEmpty 
          ? lesson.quizzes[i % lesson.quizzes.length] 
          : LessonQuiz(
              id: '${widget.lessonId}_quiz_$i',
              title: LocalizedText(ru: 'Вопрос ${i + 1}', en: 'Question ${i + 1}', kk: 'Сұрақ ${i + 1}'),
              prompt: LocalizedText(ru: 'Выберите правильный ответ', en: 'Choose the correct answer', kk: 'Дұрыс жауапты таңдаңыз'),
              options: [
                QuizOption(id: 'a', label: LocalizedText(ru: 'Вариант А', en: 'Option A', kk: 'А нұсқасы')),
                QuizOption(id: 'b', label: LocalizedText(ru: 'Вариант Б', en: 'Option B', kk: 'Б нұсқасы')),
              ],
              correctOptionId: 'a',
              explanation: LocalizedText(ru: 'Объяснение', en: 'Explanation', kk: 'Түсініктеме'),
            );
      steps.add(LessonStep(kind: LessonStepKind.quiz, quiz: quiz, id: quiz.id));
    }

    // 3 Code steps
    for (int i = 0; i < 3; i++) {
      steps.add(LessonStep(kind: LessonStepKind.code, id: '${widget.lessonId}_code_$i'));
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final lesson = catalog.lessonById(widget.lessonId);
    final completed = state.completedLessonIds.contains(widget.lessonId);
    final requirementsMet = catalog.lessonRequirementsMet(
      state,
      widget.lessonId,
    );
    final colors = context.appColors;
    final l10n = context.l10n;
    final locale = state.locale;

    final steps = _buildSteps(lesson);
    final currentStep = steps[_currentStepIndex];

    return AppPageScaffold(
      title: lesson.title.resolve(state.locale),
      expandContent: true, // Allow content to fill available height
      child: Column(
        children: [
          // Step Progress Bar (Stepik style)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(steps.length, (index) {
                  final step = steps[index];
                  final isActive = _currentStepIndex == index;
                  final isStepCompleted = _isStepCompleted(step, state);

                  return GestureDetector(
                    onTap: () => setState(() => _currentStepIndex = index),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? colors.success 
                            : isStepCompleted 
                                ? colors.success.withValues(alpha: 0.4) 
                                : colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isActive ? Colors.white70 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _getStepIcon(step, isActive ? Colors.white : colors.textSecondary),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              controller: currentStep.kind == LessonStepKind.theory ? _theoryScrollController : null,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                _buildStepContent(currentStep, lesson, state, controller, colors, l10n, locale),
                const SizedBox(height: 24),
                // Navigation Buttons
                Row(
                  children: [
                    if (_currentStepIndex > 0)
                      Expanded(
                        child: AppButton.secondary(
                          label: 'Previous',
                          onPressed: () => setState(() => _currentStepIndex--),
                        ),
                      ),
                    if (_currentStepIndex > 0) const SizedBox(width: 12),
                    if (_currentStepIndex < steps.length - 1)
                      Expanded(
                        child: AppButton.primary(
                          label: 'Next Step',
                          onPressed: () => setState(() => _currentStepIndex++),
                        ),
                      )
                    else
                      Expanded(
                        child: AppButton.primary(
                          label: 'Отправить',
                          icon: completed ? Icons.check_circle_rounded : Icons.done_rounded,
                          onPressed: () {
                            controller.completeLesson(widget.lessonId);
                            AppNotice.show(
                              context,
                              message: '+${lesson.xpReward} XP',
                              type: AppNoticeType.success,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStepIcon(LessonStep step, Color color) {
    switch (step.kind) {
      case LessonStepKind.theory:
        return const SizedBox.shrink(); // Empty for theory as requested
      case LessonStepKind.quiz:
        return Text('?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16));
      case LessonStepKind.code:
        return Icon(Icons.code_rounded, size: 16, color: color);
      default:
        return const SizedBox.shrink();
    }
  }

  bool _isStepCompleted(LessonStep step, DemoAppState state) {
    if (step.id == null) return false;
    switch (step.kind) {
      case LessonStepKind.theory:
        return state.completedTheoryIds.contains(step.id);
      case LessonStepKind.quiz:
        return state.completedQuizIds.contains(step.id);
      case LessonStepKind.trainer:
        return state.completedTrainerIds.contains(step.id);
      case LessonStepKind.code:
        return state.completedCodeStepIds.contains(step.id);
    }
  }

  Widget _buildStepContent(
    LessonStep step, 
    LessonItem lesson, 
    DemoAppState state, 
    DemoAppController controller,
    AppThemeColors colors,
    AppLocalizations l10n,
    AppLocale locale,
  ) {
    switch (step.kind) {
      case LessonStepKind.theory:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlowCard(
              accent: colors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_fill_rounded, size: 48, color: colors.primary),
                          const SizedBox(height: 8),
                          const Text('Видео по теме', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lesson.summary.resolve(locale),
                    style: TextStyle(color: colors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: [
                      _Pill(label: '${lesson.durationMinutes} ${l10n.text('minutes')}'),
                      _Pill(label: '${lesson.xpReward} XP'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlowCard(
              accent: const Color(0xFFFFA726),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: colors.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(l10n.text('lesson_theory'), style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...lesson.theoryContent
                      .resolve(locale)
                      .split('\n\n')
                      .map((paragraph) => _TheoryParagraph(text: paragraph, colors: colors)),
                ],
              ),
            ),
          ],
        );
      case LessonStepKind.quiz:
        final quiz = step.quiz!;
        return _QuizCard(
          quiz: quiz,
          locale: locale,
          selectedOptionId: _selectedQuizAnswers[quiz.id],
          completed: state.completedQuizIds.contains(quiz.id),
          onOptionSelected: (optionId) => setState(() => _selectedQuizAnswers[quiz.id] = optionId),
          onSubmit: () {
            final selected = _selectedQuizAnswers[quiz.id];
            if (selected == null) return;
            final correct = selected == quiz.correctOptionId;
            controller.completeQuiz(quiz.id, isCorrect: correct);
            AppNotice.show(
              context,
              message: correct ? l10n.text('lesson_quiz_correct') : l10n.text('lesson_quiz_retry'),
              type: correct ? AppNoticeType.success : AppNoticeType.error,
            );
          },
        );
      case LessonStepKind.trainer:
        final trainer = step.trainer!;
        return _TrainerCard(
          trainer: trainer,
          locale: locale,
          selectedOptionId: _selectedTrainerAnswers[trainer.id],
          selectedSequence: _trainerSequences[trainer.id] ?? <String>[],
          completed: state.completedTrainerIds.contains(trainer.id),
          onOptionSelected: (optionId) => setState(() => _selectedTrainerAnswers[trainer.id] = optionId),
          onSequenceChanged: (sequence) => setState(() => _trainerSequences[trainer.id] = sequence),
          onSubmit: () {
            final isCorrect = _isTrainerCorrect(trainer);
            if (isCorrect) controller.completeTrainer(trainer.id);
            AppNotice.show(
              context,
              message: isCorrect ? l10n.text('lesson_memory_completed') : l10n.text('lesson_memory_retry'),
              type: isCorrect ? AppNoticeType.success : AppNoticeType.error,
            );
          },
        );
      case LessonStepKind.code:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Interactive Lab',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Apply what you\'ve learned in the interactive editor below.',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            PremiumCodeEditor(
              initialCode: lesson.codeSnippet,
              language: 'java', // Defaulting to Java for this MVP
              onResult: (result) {
                if (result.isSuccess) {
                  controller.completeCodeStep('${widget.lessonId}_code');
                  AppNotice.show(context, message: 'Code executed successfully!', type: AppNoticeType.success);
                } else if (result.error.isNotEmpty) {
                  AppNotice.show(context, message: result.error, type: AppNoticeType.error);
                }
              },
            ),
          ],
        );
    }
  }

  bool _isTrainerCorrect(CodeTrainer trainer) {
    if (trainer.kind == CodeTrainerKind.reorderLines) {
      final selected = _trainerSequences[trainer.id] ?? <String>[];
      return selected.join('|') == trainer.correctSequence.join('|');
    }
    if (trainer.kind == CodeTrainerKind.matching) {
      final selected = _trainerSequences[trainer.id] ?? <String>[];
      if (selected.length != trainer.options.length) return false;
      for (var i = 0; i < trainer.options.length; i++) {
        if (i >= selected.length || selected[i] != trainer.correctSequence[i]) {
          return false;
        }
      }
      return true;
    }
    return _selectedTrainerAnswers[trainer.id] == trainer.correctOptionId;
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.quiz,
    required this.locale,
    required this.selectedOptionId,
    required this.completed,
    required this.onOptionSelected,
    required this.onSubmit,
  });

  final LessonQuiz quiz;
  final AppLocale locale;
  final String? selectedOptionId;
  final bool completed;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final title = quiz.prompt.resolve(locale);

    return GlowCard(
      accent: context.appColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...quiz.options.map(
            (option) => _OptionTile(
              label: option.label.resolve(locale),
              selected: selectedOptionId == option.id,
              enabled: !completed,
              onTap: () => onOptionSelected(option.id),
            ),
          ),
          AppButton.primary(
            label: completed
                ? context.l10n.text('lesson_solved')
                : context.l10n.text('lesson_check_answer'),
            icon: completed ? Icons.check_circle_rounded : Icons.quiz_rounded,
            onPressed: completed || selectedOptionId == null ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({
    required this.trainer,
    required this.locale,
    required this.selectedOptionId,
    required this.selectedSequence,
    required this.completed,
    required this.onOptionSelected,
    required this.onSequenceChanged,
    required this.onSubmit,
  });

  final CodeTrainer trainer;
  final AppLocale locale;
  final String? selectedOptionId;
  final List<String> selectedSequence;
  final bool completed;
  final ValueChanged<String> onOptionSelected;
  final ValueChanged<List<String>> onSequenceChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = trainer.prompt.isNotEmpty
        ? trainer.prompt
        : trainer.instruction.resolve(locale);
    final supportingText = trainer.prompt.isNotEmpty
        ? trainer.instruction.resolve(locale)
        : '';

    return GlowCard(
      accent: colors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (supportingText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              supportingText,
              style: TextStyle(color: colors.textSecondary, height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          if (trainer.template != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.backgroundElevated,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trainer.template!,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          if (trainer.prompt.isNotEmpty) ...[
            if (trainer.template != null) const SizedBox(height: 10),
            Text(
              trainer.prompt,
              style: TextStyle(color: colors.textSecondary, height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          if (trainer.kind == CodeTrainerKind.reorderLines)
            _ReorderTrainerView(
              trainer: trainer,
              locale: locale,
              selectedSequence: selectedSequence,
              onSequenceChanged: onSequenceChanged,
            )
          else if (trainer.kind == CodeTrainerKind.matching)
            _MatchingTrainerView(
              trainer: trainer,
              locale: locale,
              selectedPairs: selectedSequence,
              onPairsChanged: onSequenceChanged,
            )
          else
            ...trainer.options.map(
              (option) => _OptionTile(
                label: option.label.resolve(locale),
                selected: selectedOptionId == option.id,
                enabled: !completed,
                onTap: () => onOptionSelected(option.id),
              ),
            ),
          AppButton.primary(
            label: completed
                ? context.l10n.text('lesson_solved')
                : context.l10n.text('lesson_complete_lab'),
            icon: completed ? Icons.check_circle_rounded : Icons.memory_rounded,
            onPressed:
                completed ||
                    (trainer.kind == CodeTrainerKind.reorderLines ||
                            trainer.kind == CodeTrainerKind.matching
                        ? selectedSequence.length !=
                              trainer.correctSequence.length
                        : selectedOptionId == null)
                ? null
                : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _ReorderTrainerView extends StatelessWidget {
  const _ReorderTrainerView({
    required this.trainer,
    required this.locale,
    required this.selectedSequence,
    required this.onSequenceChanged,
  });

  final CodeTrainer trainer;
  final AppLocale locale;
  final List<String> selectedSequence;
  final ValueChanged<List<String>> onSequenceChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final remaining = trainer.options
        .where((option) => !selectedSequence.contains(option.id))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: remaining
              .map((option) {
                return ActionChip(
                  label: Text(option.label.resolve(locale)),
                  onPressed: () => onSequenceChanged(<String>[
                    ...selectedSequence,
                    option.id,
                  ]),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 12),
        Text('Your sequence', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...selectedSequence.map((id) {
          final option = trainer.options.firstWhere((item) => item.id == id);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.drag_handle_rounded,
              color: colors.textSecondary,
            ),
            title: Text(
              option.label.resolve(locale),
              style: TextStyle(
                color: colors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
            trailing: IconButton(
              onPressed: () => onSequenceChanged(
                selectedSequence
                    .where((value) => value != id)
                    .toList(growable: false),
              ),
              icon: const Icon(Icons.close_rounded),
            ),
          );
        }),
      ],
    );
  }
}

class _MatchingTrainerView extends StatelessWidget {
  const _MatchingTrainerView({
    required this.trainer,
    required this.locale,
    required this.selectedPairs,
    required this.onPairsChanged,
  });

  final CodeTrainer trainer;
  final AppLocale locale;
  final List<String> selectedPairs;
  final ValueChanged<List<String>> onPairsChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final definitions = List<String>.from(trainer.correctSequence);
    final currentIndex = selectedPairs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(trainer.options.length, (index) {
          final term = trainer.options[index].label.resolve(locale);
          final matched = index < selectedPairs.length;
          final matchedDef = matched ? selectedPairs[index] : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: matched
                    ? colors.success.withValues(alpha: 0.10)
                    : index == currentIndex
                    ? colors.primary.withValues(alpha: 0.10)
                    : colors.surfaceSoft,
                border: Border.all(
                  color: matched
                      ? colors.success.withValues(alpha: 0.5)
                      : index == currentIndex
                      ? colors.primary
                      : colors.divider,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      term,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      matchedDef ?? '...',
                      style: TextStyle(
                        color: matched ? colors.success : colors.textSecondary,
                        fontStyle: matched
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ),
                  if (matched)
                    IconButton(
                      onPressed: () {
                        final updated = List<String>.from(selectedPairs);
                        updated.removeRange(index, updated.length);
                        onPairsChanged(updated);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                ],
              ),
            ),
          );
        }),
        if (currentIndex < trainer.options.length) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.text('lesson_match_definition'),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: definitions
                .where((def) => !selectedPairs.contains(def))
                .map(
                  (def) => ActionChip(
                    label: Text(def),
                    onPressed: () =>
                        onPairsChanged(<String>[...selectedPairs, def]),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? colors.primary.withValues(alpha: 0.14)
                : colors.surfaceSoft,
            border: Border.all(
              color: selected ? colors.primary : colors.divider,
            ),
          ),
          child: Text(label, style: TextStyle(color: colors.textPrimary)),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TheoryParagraph extends StatelessWidget {
  const _TheoryParagraph({required this.text, required this.colors});

  final String text;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final isHighlight = text.startsWith('►');
    final content = isHighlight ? text.substring(1).trimLeft() : text;

    if (isHighlight) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: colors.textPrimary,
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        content,
        style: TextStyle(
          color: colors.textSecondary,
          height: 1.55,
          fontSize: 14,
        ),
      ),
    );
  }
}
