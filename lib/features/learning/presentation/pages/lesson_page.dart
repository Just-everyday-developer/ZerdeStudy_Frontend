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

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({
    super.key,
    required this.lessonId,
  });

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
    final requirementsMet = catalog.lessonRequirementsMet(state, widget.lessonId);
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
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: [
                    _Pill(label: '${lesson.durationMinutes} ${l10n.text('minutes')}'),
                    _Pill(label: '${lesson.xpReward} XP'),
                    _Pill(
                      label: '${lesson.quizzes.length} ${l10n.text('lesson_quizzes_count')} | '
                          '${lesson.codeTrainers.length} ${l10n.text('lesson_labs_count')}',
                    ),
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
                    type:
                        correct ? AppNoticeType.success : AppNoticeType.error,
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
                    type:
                        isCorrect ? AppNoticeType.success : AppNoticeType.error,
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
              controller.sendAiMessage(
                lesson.promptSuggestion.resolve(state.locale),
              );
              context.go(AppRoutes.ai);
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
    return GlowCard(
      accent: context.appColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('lesson_output_quiz'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            quiz.prompt.resolve(locale),
            style: TextStyle(
              color: context.appColors.textSecondary,
              height: 1.35,
            ),
          ),
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

    return GlowCard(
      accent: colors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('lesson_memory_lab'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            trainer.instruction.resolve(locale),
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
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
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (trainer.kind == CodeTrainerKind.reorderLines)
            _ReorderTrainerView(
              trainer: trainer,
              selectedSequence: selectedSequence,
              onSequenceChanged: onSequenceChanged,
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
            onPressed: completed ||
                    (trainer.kind == CodeTrainerKind.reorderLines
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
    required this.selectedSequence,
    required this.onSequenceChanged,
  });

  final CodeTrainer trainer;
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
          children: remaining.map((option) {
            return ActionChip(
              label: Text(option.label.ru),
              onPressed: () =>
                  onSequenceChanged(<String>[...selectedSequence, option.id]),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 12),
        Text(
          'Your sequence',
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
              option.label.ru,
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
