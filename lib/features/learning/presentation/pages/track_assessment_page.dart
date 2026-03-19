import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/theme/app_theme_colors.dart';

class TrackAssessmentPage extends ConsumerStatefulWidget {
  const TrackAssessmentPage({
    super.key,
    required this.trackId,
  });

  final String trackId;

  @override
  ConsumerState<TrackAssessmentPage> createState() => _TrackAssessmentPageState();
}

class _TrackAssessmentPageState extends ConsumerState<TrackAssessmentPage> {
  final Map<String, String> _selectedOptionIds = <String, String>{};
  TrackAssessmentResult? _submittedResult;

  void _submit() {
    final catalog = ref.read(demoCatalogProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final assessment = catalog.assessmentForTrack(widget.trackId);

    if (_selectedOptionIds.length != assessment.questions.length) {
      AppNotice.show(
        context,
        message: 'Answer all 10 questions before submitting the assessment.',
        type: AppNoticeType.error,
      );
      return;
    }

    final result = controller.submitTrackAssessment(
      trackId: widget.trackId,
      selectedOptionIds: _selectedOptionIds,
    );
    setState(() {
      _submittedResult = result;
    });
    AppNotice.show(
      context,
      message: result.lastPassed
          ? 'Assessment completed: ${result.lastPercent}%'
          : 'Assessment saved: ${result.lastPercent}%',
      type: result.lastPassed ? AppNoticeType.success : AppNoticeType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final track = catalog.trackById(widget.trackId);
    final assessment = catalog.assessmentForTrack(widget.trackId);
    final savedResult =
        _submittedResult ?? catalog.assessmentResultFor(state, widget.trackId);
    final colors = context.appColors;

    return AppPageScaffold(
      title: '${track.title.resolve(state.locale)} assessment',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: track.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment.summary.resolve(state.locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      label: 'Questions',
                      value: '${assessment.questions.length}',
                    ),
                    _InfoPill(
                      label: 'Pass',
                      value: '${assessment.passPercent}%',
                    ),
                    _InfoPill(
                      label: 'Best',
                      value: savedResult == null ? '0%' : '${savedResult.bestPercent}%',
                    ),
                    _InfoPill(
                      label: 'Attempts',
                      value: savedResult == null ? '0' : '${savedResult.attemptCount}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (savedResult != null) ...[
            const SizedBox(height: 16),
            _ResultCard(
              result: savedResult,
              totalQuestions: assessment.questions.length,
            ),
          ],
          const SizedBox(height: 16),
          ...assessment.questions.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _AssessmentQuestionCard(
                index: entry.key + 1,
                question: entry.value,
                locale: state.locale,
                selectedOptionId: _selectedOptionIds[entry.value.id],
                submitted: _submittedResult != null,
                onSelected: (optionId) {
                  if (_submittedResult != null) {
                    return;
                  }
                  setState(() {
                    _selectedOptionIds[entry.value.id] = optionId;
                  });
                },
              ),
            ),
          ),
          AppButton.primary(
            label: _submittedResult == null
                ? 'Submit assessment'
                : 'Start another attempt',
            icon: Icons.assignment_turned_in_rounded,
            onPressed: () {
              if (_submittedResult != null) {
                setState(() {
                  _submittedResult = null;
                  _selectedOptionIds.clear();
                });
                return;
              }
              _submit();
            },
          ),
        ],
      ),
    );
  }
}

class _AssessmentQuestionCard extends StatelessWidget {
  const _AssessmentQuestionCard({
    required this.index,
    required this.question,
    required this.locale,
    required this.selectedOptionId,
    required this.submitted,
    required this.onSelected,
  });

  final int index;
  final TrackAssessmentQuestion question;
  final AppLocale locale;
  final String? selectedOptionId;
  final bool submitted;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isCorrect = selectedOptionId == question.correctOptionId;
    final accent = submitted
        ? (isCorrect ? colors.success : colors.danger)
        : colors.primary;

    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $index',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.prompt.resolve(locale),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          ...question.options.map(
            (option) {
              final selected = option.id == selectedOptionId;
              final showCorrect = submitted && option.id == question.correctOptionId;
              final showWrong = submitted &&
                  selected &&
                  option.id != question.correctOptionId;
              final tileAccent = showCorrect
                  ? colors.success
                  : showWrong
                      ? colors.danger
                      : selected
                          ? colors.primary
                          : colors.divider;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: submitted ? null : () => onSelected(option.id),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: colors.surfaceSoft,
                      border: Border.all(color: tileAccent.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 10, left: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: tileAccent,
                              width: 2,
                            ),
                            color: selected
                                ? tileAccent.withValues(alpha: 0.16)
                                : Colors.transparent,
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: tileAccent,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              option.label.resolve(locale),
                              style: TextStyle(
                                color: colors.textPrimary,
                                height: 1.35,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        if (showCorrect)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: colors.success,
                            ),
                          ),
                        if (showWrong)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.cancel_rounded,
                              color: colors.danger,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (submitted) ...[
            const SizedBox(height: 4),
            Text(
              question.explanation.resolve(locale),
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.totalQuestions,
  });

  final TrackAssessmentResult result;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = result.lastPassed ? colors.success : colors.accent;

    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.lastPassed ? 'Passed' : 'Keep going',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${result.lastCorrectAnswers}/$totalQuestions correct | ${result.lastPercent}%',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Best score: ${result.bestPercent}%  •  Attempts: ${result.attemptCount}',
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
