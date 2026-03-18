import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

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
    final l10n = context.l10n;

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
                Text(lesson.summary.resolve(state.locale), style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: [
                    _Pill(label: '${lesson.durationMinutes} ${l10n.text('minutes')}'),
                    _Pill(label: '${lesson.xpReward} XP'),
                    _Pill(label: '${lesson.quizzes.length} quiz • ${lesson.codeTrainers.length} lab'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.outcome.resolve(state.locale), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                ...lesson.keyPoints.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(Icons.adjust_rounded, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(point.resolve(state.locale), style: const TextStyle(color: AppColors.textSecondary, height: 1.4))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: AppColors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code Example', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lesson.codeSnippet,
                    style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', height: 1.45),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Expected output: ${lesson.exampleOutput}', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...lesson.quizzes.map((quiz) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _QuizCard(
                  quiz: quiz,
                  selectedOptionId: _selectedQuizAnswers[quiz.id],
                  completed: state.completedQuizIds.contains(quiz.id),
                  onOptionSelected: (optionId) => setState(() => _selectedQuizAnswers[quiz.id] = optionId),
                  onSubmit: () {
                    final selected = _selectedQuizAnswers[quiz.id];
                    if (selected == null) {
                      return;
                    }
                    final correct = selected == quiz.correctOptionId;
                    controller.completeQuiz(quiz.id, isCorrect: correct);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(correct ? 'Correct answer' : 'Try again: check the final state change')),
                    );
                  },
                ),
              )),
          ...lesson.codeTrainers.map((trainer) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _TrainerCard(
                  trainer: trainer,
                  selectedOptionId: _selectedTrainerAnswers[trainer.id],
                  selectedSequence: _trainerSequences[trainer.id] ?? <String>[],
                  completed: state.completedTrainerIds.contains(trainer.id),
                  onOptionSelected: (optionId) => setState(() => _selectedTrainerAnswers[trainer.id] = optionId),
                  onSequenceChanged: (sequence) => setState(() => _trainerSequences[trainer.id] = sequence),
                  onSubmit: () {
                    final isCorrect = _isTrainerCorrect(trainer);
                    if (isCorrect) {
                      controller.completeTrainer(trainer.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isCorrect ? 'Memory lab completed' : 'Re-check the structure and try again')),
                    );
                  },
                ),
              )),
          AppButton.primary(
            label: completed ? l10n.text('status_completed') : l10n.text('complete_lesson'),
            icon: completed ? Icons.check_circle_rounded : Icons.done_rounded,
            onPressed: completed || !requirementsMet
                ? null
                : () {
                    controller.completeLesson(widget.lessonId);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+${lesson.xpReward} XP')));
                  },
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: l10n.text('ask_ai'),
            icon: Icons.smart_toy_rounded,
            onPressed: () {
              controller.focusLesson(widget.lessonId);
              controller.sendAiMessage(lesson.promptSuggestion.resolve(state.locale));
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
    required this.selectedOptionId,
    required this.completed,
    required this.onOptionSelected,
    required this.onSubmit,
  });

  final LessonQuiz quiz;
  final String? selectedOptionId;
  final bool completed;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Output Quiz', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(quiz.prompt.ru, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
          const SizedBox(height: 12),
          ...quiz.options.map((option) => _OptionTile(
                label: option.label.ru,
                selected: selectedOptionId == option.id,
                enabled: !completed,
                onTap: () => onOptionSelected(option.id),
              )),
          AppButton.primary(
            label: completed ? 'Solved' : 'Check answer',
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
    required this.selectedOptionId,
    required this.selectedSequence,
    required this.completed,
    required this.onOptionSelected,
    required this.onSequenceChanged,
    required this.onSubmit,
  });

  final CodeTrainer trainer;
  final String? selectedOptionId;
  final List<String> selectedSequence;
  final bool completed;
  final ValueChanged<String> onOptionSelected;
  final ValueChanged<List<String>> onSequenceChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Code Memory Lab', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(trainer.instruction.ru, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
          const SizedBox(height: 12),
          if (trainer.template != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(trainer.template!, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace')),
            ),
          if (trainer.prompt.isNotEmpty) ...[
            if (trainer.template != null) const SizedBox(height: 10),
            Text(trainer.prompt, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
          ],
          const SizedBox(height: 12),
          if (trainer.kind == CodeTrainerKind.reorderLines)
            _ReorderTrainerView(
              trainer: trainer,
              selectedSequence: selectedSequence,
              onSequenceChanged: onSequenceChanged,
            )
          else
            ...trainer.options.map((option) => _OptionTile(
                  label: option.label.ru,
                  selected: selectedOptionId == option.id,
                  enabled: !completed,
                  onTap: () => onOptionSelected(option.id),
                )),
          AppButton.primary(
            label: completed ? 'Solved' : 'Complete lab',
            icon: completed ? Icons.check_circle_rounded : Icons.memory_rounded,
            onPressed: completed ||
                    (trainer.kind == CodeTrainerKind.reorderLines
                        ? selectedSequence.length != trainer.correctSequence.length
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
    final remaining = trainer.options.where((option) => !selectedSequence.contains(option.id)).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: remaining.map((option) {
            return ActionChip(
              label: Text(option.label.ru),
              onPressed: () => onSequenceChanged(<String>[...selectedSequence, option.id]),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 12),
        Text('Your sequence', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...selectedSequence.map((id) {
          final option = trainer.options.firstWhere((item) => item.id == id);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
            title: Text(option.label.ru, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace')),
            trailing: IconButton(
              onPressed: () => onSequenceChanged(selectedSequence.where((value) => value != id).toList(growable: false)),
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
            color: selected ? AppColors.primary.withValues(alpha: 0.14) : AppColors.surfaceSoft,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
    );
  }
}
