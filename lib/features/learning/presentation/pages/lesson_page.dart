import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../ai/presentation/providers/ai_chat_controller.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  final Map<String, String> _selectedQuizAnswers = <String, String>{};
  final Map<String, String> _selectedTrainerAnswers = <String, String>{};
  final Map<String, List<String>> _trainerSequences = <String, List<String>>{};

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

    return AppPageScaffold(
      title: lesson.title.resolve(state.locale),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: catalog.trackById(lesson.trackId).color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.summary.resolve(state.locale),
                  style: TextStyle(color: colors.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: [
                    _Pill(
                      label:
                          '${lesson.durationMinutes} ${l10n.text('minutes')}',
                    ),
                    _Pill(label: '${lesson.xpReward} XP'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.outcome.resolve(state.locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                ...lesson.keyPoints.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.adjust_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            point.resolve(state.locale),
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (lesson.theoryContent.resolve(locale).isNotEmpty) ...[
            const SizedBox(height: 16),
            GlowCard(
              accent: const Color(0xFFFFA726),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: colors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.text('lesson_theory'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...lesson.theoryContent
                      .resolve(locale)
                      .split('\n\n')
                      .map(
                        (paragraph) =>
                            _TheoryParagraph(text: paragraph, colors: colors),
                      ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('lesson_code_example'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.backgroundElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lesson.codeSnippet,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontFamily: 'monospace',
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.text('lesson_expected_output')}: ${lesson.exampleOutput}',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...lesson.quizzes.map(
            (quiz) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _QuizCard(
                quiz: quiz,
                locale: locale,
                selectedOptionId: _selectedQuizAnswers[quiz.id],
                completed: state.completedQuizIds.contains(quiz.id),
                onOptionSelected: (optionId) =>
                    setState(() => _selectedQuizAnswers[quiz.id] = optionId),
                onSubmit: () {
                  final selected = _selectedQuizAnswers[quiz.id];
                  if (selected == null) {
                    return;
                  }
                  final correct = selected == quiz.correctOptionId;
                  controller.completeQuiz(quiz.id, isCorrect: correct);
                  AppNotice.show(
                    context,
                    message: correct
                        ? l10n.text('lesson_quiz_correct')
                        : l10n.text('lesson_quiz_retry'),
                    type: correct ? AppNoticeType.success : AppNoticeType.error,
                  );
                },
              ),
            ),
          ),
          ...lesson.codeTrainers.map(
            (trainer) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TrainerCard(
                trainer: trainer,
                locale: locale,
                selectedOptionId: _selectedTrainerAnswers[trainer.id],
                selectedSequence: _trainerSequences[trainer.id] ?? <String>[],
                completed: state.completedTrainerIds.contains(trainer.id),
                onOptionSelected: (optionId) => setState(
                  () => _selectedTrainerAnswers[trainer.id] = optionId,
                ),
                onSequenceChanged: (sequence) =>
                    setState(() => _trainerSequences[trainer.id] = sequence),
                onSubmit: () {
                  final isCorrect = _isTrainerCorrect(trainer);
                  if (isCorrect) {
                    controller.completeTrainer(trainer.id);
                  }
                  AppNotice.show(
                    context,
                    message: isCorrect
                        ? l10n.text('lesson_memory_completed')
                        : l10n.text('lesson_memory_retry'),
                    type: isCorrect
                        ? AppNoticeType.success
                        : AppNoticeType.error,
                  );
                },
              ),
            ),
          ),
          AppButton.primary(
            label: completed
                ? l10n.text('status_completed')
                : l10n.text('complete_lesson'),
            icon: completed ? Icons.check_circle_rounded : Icons.done_rounded,
            onPressed: completed || !requirementsMet
                ? null
                : () {
                    controller.completeLesson(widget.lessonId);
                    AppNotice.show(
                      context,
                      message: '+${lesson.xpReward} XP',
                      type: AppNoticeType.success,
                    );
                  },
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: l10n.text('ask_ai'),
            icon: Icons.smart_toy_rounded,
            onPressed: () {
              controller.focusLesson(widget.lessonId);
              context.go(AppRoutes.ai);
              unawaited(
                ref
                    .read(aiChatControllerProvider.notifier)
                    .sendMessage(lesson.promptSuggestion.resolve(state.locale)),
              );
            },
          ),
        ],
      ),
    );
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
