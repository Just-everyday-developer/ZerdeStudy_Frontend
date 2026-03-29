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

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({super.key, required this.practiceId});

  final String practiceId;

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  final Set<int> _checkedKnowledgeItems = <int>{};
  late final TextEditingController _codeController;
  late final ScrollController _codeScrollController;
  late final TextEditingController _commentController;
  final List<PracticeComment> _draftComments = <PracticeComment>[];

  String? _activePracticeId;
  String? _draftOutput;
  bool? _submissionPassed;
  String? _submissionMessage;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeScrollController = ScrollController();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeScrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final practice = catalog.practiceById(widget.practiceId);
    _syncPracticeState(practice);

    final completed = state.completedPracticeIds.contains(widget.practiceId);
    final checksComplete =
        _checkedKnowledgeItems.length == practice.knowledgeChecks.length;
    final colors = context.appColors;
    final locale = state.locale;
    final comments = <PracticeComment>[..._draftComments, ...practice.comments];

    return AppPageScaffold(
      title: practice.title.resolve(locale),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: colors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  practice.summary.resolve(locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  practice.brief.resolve(locale),
                  style: TextStyle(color: colors.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (practice.codeChallenge != null)
            _SandboxCard(
              locale: locale,
              colors: colors,
              challenge: practice.codeChallenge!,
              codeController: _codeController,
              codeScrollController: _codeScrollController,
              draftOutput: _draftOutput,
              submissionPassed: _submissionPassed,
              submissionMessage: _submissionMessage,
            )
          else
            _InfoSectionCard(
              accent: colors.primary,
              title: _practiceText(
                locale,
                ru: 'Starter Code',
                en: 'Starter Code',
                kk: 'Starter Code',
              ),
              child: _CodeBlock(code: practice.starterCode, colors: colors),
            ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            accent: colors.success,
            title: _practiceText(
              locale,
              ru: 'Success Criteria',
              en: 'Success Criteria',
              kk: 'Success Criteria',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final criterion in practice.successCriteria)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: colors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            criterion.resolve(locale),
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            accent: colors.primary,
            title: _practiceText(
              locale,
              ru: 'Quick check',
              en: 'Quick check',
              kk: 'Quick check',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in practice.knowledgeChecks.asMap().entries)
                  CheckboxListTile(
                    value: _checkedKnowledgeItems.contains(entry.key),
                    onChanged: completed
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                _checkedKnowledgeItems.add(entry.key);
                              } else {
                                _checkedKnowledgeItems.remove(entry.key);
                              }
                            });
                          },
                    title: Text(
                      entry.value.resolve(locale),
                      style: TextStyle(color: colors.textPrimary),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (practice.codeChallenge != null) ...[
            AppButton.secondary(
              label: _practiceText(
                locale,
                ru: 'Run draft',
                en: 'Run draft',
                kk: 'Run draft',
              ),
              icon: Icons.play_arrow_rounded,
              onPressed: () => _runDraft(practice.codeChallenge!, locale),
            ),
            const SizedBox(height: 12),
            AppButton.primary(
              label: completed
                  ? _practiceText(
                      locale,
                      ru: 'Submitted',
                      en: 'Submitted',
                      kk: 'Submitted',
                    )
                  : _practiceText(
                      locale,
                      ru: 'Submit for review',
                      en: 'Submit for review',
                      kk: 'Submit for review',
                    ),
              icon: completed
                  ? Icons.check_circle_rounded
                  : Icons.verified_rounded,
              onPressed: completed
                  ? null
                  : () => _submitForReview(
                      practice: practice,
                      locale: locale,
                      controller: controller,
                      completed: completed,
                      checksComplete: checksComplete,
                    ),
            ),
          ] else ...[
            AppButton.primary(
              label: completed
                  ? context.l10n.text('status_completed')
                  : context.l10n.text('complete_practice'),
              icon: completed ? Icons.check_circle_rounded : Icons.code_rounded,
              onPressed: completed || !checksComplete
                  ? null
                  : () {
                      controller.completePractice(widget.practiceId);
                      AppNotice.show(
                        context,
                        message: '+${practice.xpReward} XP',
                        type: AppNoticeType.success,
                      );
                    },
            ),
          ],
          const SizedBox(height: 12),
          AppButton.secondary(
            label: context.l10n.text('ask_ai'),
            icon: Icons.smart_toy_rounded,
            onPressed: () {
              controller.focusPractice(widget.practiceId);
              context.go(AppRoutes.ai);
              unawaited(
                ref
                    .read(aiChatControllerProvider.notifier)
                    .sendMessage(practice.promptSuggestion.resolve(locale)),
              );
            },
          ),
          if (practice.codeChallenge != null || comments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _CommentsCard(
              locale: locale,
              colors: colors,
              comments: comments,
              commentController: _commentController,
              onSend: () => _addComment(locale, state.user),
            ),
          ],
        ],
      ),
    );
  }

  void _syncPracticeState(PracticeTask practice) {
    if (_activePracticeId == practice.id) {
      return;
    }

    _activePracticeId = practice.id;
    _checkedKnowledgeItems.clear();
    _draftComments.clear();
    _draftOutput = null;
    _submissionPassed = null;
    _submissionMessage = null;
    _codeController.text = practice.starterCode;
    _commentController.clear();
  }

  void _runDraft(PracticeCodeChallenge challenge, AppLocale locale) {
    final evaluation = _evaluateChallenge(challenge, locale);
    setState(() {
      _draftOutput = evaluation.output;
      _submissionPassed = null;
      _submissionMessage = null;
    });
  }

  void _submitForReview({
    required PracticeTask practice,
    required AppLocale locale,
    required DemoAppController controller,
    required bool completed,
    required bool checksComplete,
  }) {
    final challenge = practice.codeChallenge;
    if (challenge == null) {
      return;
    }

    final evaluation = _evaluateChallenge(challenge, locale);
    final passed = evaluation.passed && checksComplete;
    final quickCheckMessage = _practiceText(
      locale,
      ru: 'Complete every quick check item before the final submission.',
      en: 'Complete every quick check item before the final submission.',
      kk: 'Complete every quick check item before the final submission.',
    );

    final message = passed
        ? challenge.successMessage.resolve(locale)
        : checksComplete
        ? challenge.retryMessage.resolve(locale)
        : quickCheckMessage;

    setState(() {
      _draftOutput = evaluation.output;
      _submissionPassed = passed;
      _submissionMessage = passed
          ? message
          : evaluation.missingSnippets.isEmpty
          ? message
          : '$message\n\n${_missingSnippetsLabel(locale)}\n- ${evaluation.missingSnippets.join('\n- ')}';
    });

    if (passed && !completed) {
      controller.completePractice(practice.id);
      AppNotice.show(
        context,
        message: challenge.successMessage.resolve(locale),
        type: AppNoticeType.success,
      );
      return;
    }

    AppNotice.show(context, message: message, type: AppNoticeType.error);
  }

  _ChallengeEvaluation _evaluateChallenge(
    PracticeCodeChallenge challenge,
    AppLocale locale,
  ) {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      return _ChallengeEvaluation(
        passed: false,
        output: _practiceText(
          locale,
          ru: 'Write code in the editor before running the draft console.',
          en: 'Write code in the editor before running the draft console.',
          kk: 'Write code in the editor before running the draft console.',
        ),
        missingSnippets: const <String>[],
      );
    }

    final normalized = code.toLowerCase();
    final missingSnippets = challenge.requiredSnippets
        .where((snippet) => !normalized.contains(snippet.toLowerCase()))
        .toList(growable: false);

    if (missingSnippets.isEmpty) {
      return _ChallengeEvaluation(
        passed: true,
        output: challenge.expectedOutput,
        missingSnippets: const <String>[],
      );
    }

    return _ChallengeEvaluation(
      passed: false,
      output:
          '${_practiceText(locale, ru: 'Draft runner found a few missing OOP pieces:', en: 'Draft runner found a few missing OOP pieces:', kk: 'Draft runner found a few missing OOP pieces:')}\n- ${missingSnippets.join('\n- ')}',
      missingSnippets: missingSnippets,
    );
  }

  void _addComment(AppLocale locale, DemoUser? user) {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _draftComments.insert(
        0,
        PracticeComment(
          id: 'draft_comment_${DateTime.now().microsecondsSinceEpoch}',
          authorName:
              user?.name ??
              _practiceText(locale, ru: 'You', en: 'You', kk: 'You'),
          role: _sameLocalized(user?.role ?? 'Student'),
          message: _sameLocalized(message),
        ),
      );
      _commentController.clear();
    });
  }

  String _missingSnippetsLabel(AppLocale locale) {
    return _practiceText(
      locale,
      ru: 'Missing snippets',
      en: 'Missing snippets',
      kk: 'Missing snippets',
    );
  }
}

class _SandboxCard extends StatelessWidget {
  const _SandboxCard({
    required this.locale,
    required this.colors,
    required this.challenge,
    required this.codeController,
    required this.codeScrollController,
    required this.draftOutput,
    required this.submissionPassed,
    required this.submissionMessage,
  });

  final AppLocale locale;
  final AppThemeColors colors;
  final PracticeCodeChallenge challenge;
  final TextEditingController codeController;
  final ScrollController codeScrollController;
  final String? draftOutput;
  final bool? submissionPassed;
  final String? submissionMessage;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.title.resolve(locale),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            challenge.instructions.resolve(locale),
            style: TextStyle(color: colors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: colors.backgroundElevated,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.divider),
            ),
            padding: const EdgeInsets.all(14),
            child: Scrollbar(
              controller: codeScrollController,
              thumbVisibility: true,
              child: TextField(
                controller: codeController,
                scrollController: codeScrollController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'monospace',
                  height: 1.45,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _practiceText(
              locale,
              ru: 'Expected draft output',
              en: 'Expected draft output',
              kk: 'Expected draft output',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.divider),
            ),
            child: SelectableText(
              challenge.expectedOutput,
              style: TextStyle(
                color: colors.textPrimary,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
          if (draftOutput != null) ...[
            const SizedBox(height: 14),
            Text(
              _practiceText(
                locale,
                ru: 'Draft console',
                en: 'Draft console',
                kk: 'Draft console',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _ConsoleOutputBox(
              colors: colors,
              output: draftOutput!,
              accent: submissionPassed == null
                  ? colors.accent
                  : submissionPassed!
                  ? colors.success
                  : colors.danger,
            ),
          ],
          if (submissionMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    (submissionPassed == true ? colors.success : colors.danger)
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      (submissionPassed == true
                              ? colors.success
                              : colors.danger)
                          .withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                submissionMessage!,
                style: TextStyle(
                  color: colors.textPrimary,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentsCard extends StatelessWidget {
  const _CommentsCard({
    required this.locale,
    required this.colors,
    required this.comments,
    required this.commentController,
    required this.onSend,
  });

  final AppLocale locale;
  final AppThemeColors colors;
  final List<PracticeComment> comments;
  final TextEditingController commentController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: colors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _practiceText(
              locale,
              ru: 'Comments',
              en: 'Comments',
              kk: 'Comments',
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            _practiceText(
              locale,
              ru: 'Use the thread to leave notes, ask for a review, or capture what helped during the OOP submission.',
              en: 'Use the thread to leave notes, ask for a review, or capture what helped during the OOP submission.',
              kk: 'Use the thread to leave notes, ask for a review, or capture what helped during the OOP submission.',
            ),
            style: TextStyle(color: colors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          if (comments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceSoft.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.divider),
              ),
              child: Text(
                _practiceText(
                  locale,
                  ru: 'No comments yet. Start the discussion from here.',
                  en: 'No comments yet. Start the discussion from here.',
                  kk: 'No comments yet. Start the discussion from here.',
                ),
                style: TextStyle(color: colors.textSecondary),
              ),
            )
          else
            ...comments.map(
              (comment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PracticeCommentTile(
                  colors: colors,
                  locale: locale,
                  comment: comment,
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _practiceText(
                locale,
                ru: 'Write a comment for the midterm thread',
                en: 'Write a comment for the midterm thread',
                kk: 'Write a comment for the midterm thread',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
              label: Text(
                _practiceText(
                  locale,
                  ru: 'Send comment',
                  en: 'Send comment',
                  kk: 'Send comment',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeCommentTile extends StatelessWidget {
  const _PracticeCommentTile({
    required this.colors,
    required this.locale,
    required this.comment,
  });

  final AppThemeColors colors;
  final AppLocale locale;
  final PracticeComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.accent.withValues(alpha: 0.18),
            child: Text(
              comment.authorName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: colors.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.role.resolve(locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comment.message.resolve(locale),
                  style: TextStyle(color: colors.textPrimary, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleOutputBox extends StatelessWidget {
  const _ConsoleOutputBox({
    required this.colors,
    required this.output,
    required this.accent,
  });

  final AppThemeColors colors;
  final String output;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          output,
          style: TextStyle(
            color: colors.textPrimary,
            fontFamily: 'monospace',
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.accent,
    required this.title,
    required this.child,
  });

  final Color accent;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code, required this.colors});

  final String code;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: colors.textPrimary,
          fontFamily: 'monospace',
          height: 1.45,
        ),
      ),
    );
  }
}

class _ChallengeEvaluation {
  const _ChallengeEvaluation({
    required this.passed,
    required this.output,
    required this.missingSnippets,
  });

  final bool passed;
  final String output;
  final List<String> missingSnippets;
}

String _practiceText(
  AppLocale locale, {
  required String ru,
  required String en,
  required String kk,
}) {
  switch (locale) {
    case AppLocale.ru:
      return ru;
    case AppLocale.en:
      return en;
    case AppLocale.kk:
      return kk;
  }
}

LocalizedText _sameLocalized(String value) {
  return LocalizedText(ru: value, en: value, kk: value);
}
