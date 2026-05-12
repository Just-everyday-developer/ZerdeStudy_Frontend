import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

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
              practice: practice,
              codeController: _codeController,
              codeScrollController: _codeScrollController,
              draftOutput: _draftOutput,
              submissionPassed: _submissionPassed,
              submissionMessage: _submissionMessage,
              completed: completed,
              onRun: () => _runDraft(practice.codeChallenge!, locale),
              onSubmit: () => _submitForReview(
                practice: practice,
                locale: locale,
                controller: controller,
                completed: completed,
                checksComplete: true, // We can always treat quick checks as completed/read now since they are theoretical
              ),
            )
          else ...[
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
            AppButton.primary(
              label: completed
                  ? context.l10n.text('status_completed')
                  : context.l10n.text('complete_practice'),
              icon: completed ? Icons.check_circle_rounded : Icons.code_rounded,
              onPressed: completed
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
              ref.read(aiChatControllerProvider.notifier).createNewChat(
                practice.title.resolve(locale),
              );
              context.go(AppRoutes.ai);
              unawaited(
                ref
                    .read(aiChatControllerProvider.notifier)
                    .sendMessage(practice.promptSuggestion.resolve(locale)),
              );
            },
          ),
          if (practice.knowledgeChecks.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSectionCard(
              accent: colors.accent,
              title: _practiceText(
                locale,
                ru: 'Теория для размышления (Quick Check)',
                en: 'Quick Check (Theory to consider)',
                kk: 'Ойлануға арналған теория',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in practice.knowledgeChecks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: colors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.resolve(locale),
                              style: TextStyle(
                                color: colors.textPrimary,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (practice.codeChallenge != null || comments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _CommentsCard(
              locale: locale,
              colors: colors,
              comments: comments,
              commentController: _commentController,
              challenge: practice.codeChallenge ?? practice.codeChallenge!, // Fallback but mostly safe for coding sandbox tasks
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

  Future<void> _runDraft(PracticeCodeChallenge challenge, AppLocale locale) async {
    setState(() {
      _draftOutput = _practiceText(locale, ru: 'Запуск кода...', en: 'Running code...', kk: 'Код орындалуда...');
      _submissionPassed = null;
      _submissionMessage = null;
    });

    final evaluation = await _evaluateChallenge(challenge, locale);
    if (!mounted) return;

    setState(() {
      _draftOutput = evaluation.output;
      _submissionPassed = null;
      _submissionMessage = null;
    });
  }

  Future<void> _submitForReview({
    required PracticeTask practice,
    required AppLocale locale,
    required DemoAppController controller,
    required bool completed,
    required bool checksComplete,
  }) async {
    final challenge = practice.codeChallenge;
    if (challenge == null) {
      return;
    }

    setState(() {
      _draftOutput = _practiceText(locale, ru: 'Запуск кода...', en: 'Running code...', kk: 'Код орындалуда...');
      _submissionPassed = null;
      _submissionMessage = null;
    });

    final evaluation = await _evaluateChallenge(challenge, locale);
    if (!mounted) return;

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

  Future<_ChallengeEvaluation> _evaluateChallenge(
    PracticeCodeChallenge challenge,
    AppLocale locale,
  ) async {
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

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8091/run'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'language': 'java', 'code': code}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final output = (data['output'] as String?) ?? '';
        final error = data['error'] as String?;
        
        final hasExecutionError = error != null && error.isNotEmpty;
        final finalOutput = hasExecutionError ? '$output\nError: $error' : output;
        
        final isOutputMatching = finalOutput.trim().contains(challenge.expectedOutput.trim());

        if (missingSnippets.isEmpty && !hasExecutionError && isOutputMatching) {
          return _ChallengeEvaluation(
            passed: true,
            output: finalOutput,
            missingSnippets: const <String>[],
          );
        }

        return _ChallengeEvaluation(
          passed: false,
          output: missingSnippets.isEmpty 
              ? finalOutput 
              : '${_practiceText(locale, ru: 'Draft runner found a few missing OOP pieces:', en: 'Draft runner found a few missing OOP pieces:', kk: 'Draft runner found a few missing OOP pieces:')}\n- ${missingSnippets.join('\n- ')}\n\nOutput:\n$finalOutput',
          missingSnippets: missingSnippets,
        );
      } else {
        return _ChallengeEvaluation(
          passed: false,
          output: 'Server returned ${response.statusCode}: ${response.body}',
          missingSnippets: missingSnippets,
        );
      }
    } catch (e) {
      return _ChallengeEvaluation(
        passed: false,
        output: 'Failed to run code. Is the code-runner service running?\nError: $e',
        missingSnippets: missingSnippets,
      );
    }
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

class _SandboxCard extends StatefulWidget {
  const _SandboxCard({
    required this.locale,
    required this.colors,
    required this.challenge,
    required this.practice,
    required this.codeController,
    required this.codeScrollController,
    required this.draftOutput,
    required this.submissionPassed,
    required this.submissionMessage,
    required this.completed,
    required this.onRun,
    required this.onSubmit,
  });

  final AppLocale locale;
  final AppThemeColors colors;
  final PracticeCodeChallenge challenge;
  final PracticeTask practice;
  final TextEditingController codeController;
  final ScrollController codeScrollController;
  final String? draftOutput;
  final bool? submissionPassed;
  final String? submissionMessage;
  final bool completed;
  final VoidCallback onRun;
  final VoidCallback onSubmit;

  @override
  State<_SandboxCard> createState() => _SandboxCardState();
}

class _SandboxCardState extends State<_SandboxCard> {
  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final colors = widget.colors;
    final challenge = widget.challenge;
    final draftOutput = widget.draftOutput;
    final submissionPassed = widget.submissionPassed;
    final submissionMessage = widget.submissionMessage;

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
          // --- TEST DATA (Always displayed, as requested) ---
          Text(
            _practiceText(
              locale,
              ru: 'Тестовые данные',
              en: 'Test Data',
              kk: 'Тест мәліметтері',
            ),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test #1',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Input Data:\n(No input)',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Expected Output:\n${challenge.expectedOutput}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // --- CRITERIA (Success Criteria, as requested) ---
          Text(
            _practiceText(
              locale,
              ru: 'Критерии успеха',
              en: 'Success Criteria',
              kk: 'Табыс критерийлері',
            ),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final criterion in widget.practice.successCriteria)
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
          Container(
            height: 380,
            clipBehavior: Clip.antiAlias, // Anti-aliased clipping to prevent cursor/scrollbar bleed
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Editor dark background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  GestureBinding.instance.pointerSignalResolver.register(pointerSignal, (event) {
                    final controller = widget.codeScrollController;
                    if (controller.hasClients) {
                      final newOffset = controller.offset + (event as PointerScrollEvent).scrollDelta.dy;
                      final maxScroll = controller.position.maxScrollExtent;
                      controller.jumpTo(newOffset.clamp(0.0, maxScroll));
                    }
                  });
                }
              },
              child: Scrollbar(
                controller: widget.codeScrollController,
                thumbVisibility: true,
                child: TextField(
                  controller: widget.codeController,
                  scrollController: widget.codeScrollController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    color: Color(0xFFD4D4D4), // Editor light text
                    fontFamily: 'monospace',
                    height: 1.5,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.all(16), // Padding inside the scroll area
                  ),
                  cursorColor: colors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // --- EXPECTED OUTPUT (Always displayed in sandbox, as requested) ---
          Text(
            _practiceText(
              locale,
              ru: 'Ожидаемый вывод',
              en: 'Expected output',
              kk: 'Күтілетін нәтиже',
            ),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
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
                ru: 'Консоль',
                en: 'Draft console',
                kk: 'Консоль',
              ),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _ConsoleOutputBox(
              colors: colors,
              output: draftOutput,
              accent: submissionPassed == null
                  ? colors.accent
                  : submissionPassed
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
                color: (submissionPassed == true ? colors.success : colors.danger).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (submissionPassed == true ? colors.success : colors.danger).withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                submissionMessage,
                style: TextStyle(
                  color: colors.textPrimary,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // --- ACTION BUTTONS (Run and Submit, inside sandbox card, as requested) ---
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: _practiceText(
                    locale,
                    ru: 'Запустить',
                    en: 'Run',
                    kk: 'Іске қосу',
                  ),
                  icon: Icons.play_arrow_rounded,
                  onPressed: widget.onRun,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.primary(
                  label: widget.completed
                      ? _practiceText(
                          locale,
                          ru: 'Отправлено',
                          en: 'Submitted',
                          kk: 'Жіберілді',
                        )
                      : _practiceText(
                          locale,
                          ru: 'Отправить решение',
                          en: 'Submit',
                          kk: 'Шешімді жіберу',
                        ),
                  icon: widget.completed ? Icons.check_circle_rounded : Icons.verified_rounded,
                  onPressed: widget.completed ? null : widget.onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? colors.primary : colors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? colors.primary : colors.textSecondary,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StudentSolution {
  _StudentSolution({
    required this.id,
    required this.user,
    required this.date,
    required this.dateParsed,
    required this.score,
    required this.code,
    required this.likes,
    required this.likedByMe,
    required this.comments,
  });

  final String id;
  final String user;
  final String date;
  final DateTime dateParsed;
  final int score;
  final String code;
  int likes;
  bool likedByMe;
  final List<String> comments;
}

class _SolutionDetailCard extends StatefulWidget {
  const _SolutionDetailCard({
    required this.solution,
    required this.colors,
    required this.locale,
  });

  final _StudentSolution solution;
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  State<_SolutionDetailCard> createState() => _SolutionDetailCardState();
}

class _SolutionDetailCardState extends State<_SolutionDetailCard> {
  bool _isExpanded = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sol = widget.solution;
    final colors = widget.colors;
    final locale = widget.locale;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                  child: Text(
                    sol.user.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            sol.user,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              for (int i = 0; i < sol.score; i++)
                                Icon(Icons.star_rounded, size: 14, color: colors.accent),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            sol.id,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${sol.date}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Like Button
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (sol.likedByMe) {
                        sol.likes--;
                        sol.likedByMe = false;
                      } else {
                        sol.likes++;
                        sol.likedByMe = true;
                      }
                    });
                  },
                  icon: Row(
                    children: [
                      Icon(
                        sol.likedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: sol.likedByMe ? Colors.redAccent : colors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sol.likes.toString(),
                        style: TextStyle(
                          color: sol.likedByMe ? Colors.redAccent : colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Code block and review toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceSoft.withValues(alpha: 0.5),
                border: Border(
                  top: BorderSide(color: colors.divider),
                  bottom: BorderSide(color: colors.divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isExpanded 
                        ? _practiceText(locale, ru: 'Скрыть код решения', en: 'Hide solution code', kk: 'Шешім кодын жасыру')
                        : _practiceText(locale, ru: 'Показать код решения', en: 'Show solution code', kk: 'Шешім кодын көрсету'),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            // Code block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: const Color(0xFF1E1E1E),
              child: SelectableText(
                sol.code,
                style: const TextStyle(
                  color: Color(0xFFD4D4D4),
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
            // Inline peer reviews
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceSoft.withValues(alpha: 0.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.forum_outlined, size: 16, color: colors.accent),
                      const SizedBox(width: 8),
                      Text(
                        _practiceText(
                          locale,
                          ru: 'Внутренние отзывы (${sol.comments.length}):',
                          en: 'Peer Reviews (${sol.comments.length}):',
                          kk: 'Пікірлер (${sol.comments.length}):',
                        ),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final peerComment in sol.comments)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.backgroundElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.subdirectory_arrow_right_rounded, size: 14, color: colors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              peerComment,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Form to write inline review
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(color: colors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: _practiceText(
                              locale,
                              ru: 'Написать отзыв к решению...',
                              en: 'Add a peer review comment...',
                              kk: 'Шешімге пікір қалдыру...',
                            ),
                            hintStyle: TextStyle(color: colors.textSecondary, fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colors.divider),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () {
                          final text = _commentController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              sol.comments.add(text);
                              _commentController.clear();
                            });
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? colors.accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? colors.accent : colors.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? colors.accent : colors.textSecondary,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CommentsCard extends StatefulWidget {
  const _CommentsCard({
    required this.locale,
    required this.colors,
    required this.comments,
    required this.commentController,
    required this.onSend,
    required this.challenge,
  });

  final AppLocale locale;
  final AppThemeColors colors;
  final List<PracticeComment> comments;
  final TextEditingController commentController;
  final VoidCallback onSend;
  final PracticeCodeChallenge challenge;

  @override
  State<_CommentsCard> createState() => _CommentsCardState();
}

class _CommentsCardState extends State<_CommentsCard> {
  int _currentTab = 0; // 0: Comments, 1: Solutions
  String _sortBy = 'likes'; // 'likes' or 'date'

  late final List<_StudentSolution> _solutions;

  @override
  void initState() {
    super.initState();
    _solutions = [
      _StudentSolution(
        id: '#955099846',
        user: 'Alexey V.',
        date: '2 дня назад',
        dateParsed: DateTime.now().subtract(const Duration(days: 2)),
        score: 5,
        code: '''class StudentProfile {
    public final String name;
    public StudentProfile(String name) { this.name = name; }
    public String summary() { return "Student: " + name; }
}
class BootcampStudent extends StudentProfile {
    public final int points;
    public BootcampStudent(String name, int points) {
        super(name);
        this.points = points;
    }
    @Override
    public String summary() {
        return name + " finished OOP Midterm with " + points + " points.";
    }
}
class Main {
    public static void main(String[] args) {
        BootcampStudent student = new BootcampStudent("Aida", 86);
        System.out.println(student.summary());
    }
}''',
        likes: 18,
        likedByMe: false,
        comments: [
          'Отличное и лаконичное решение! Использование super() полностью корректно.',
          'Почему бы не использовать String.format для форматирования?',
        ],
      ),
      _StudentSolution(
        id: '#954932111',
        user: 'Maria K.',
        date: '1 неделю назад',
        dateParsed: DateTime.now().subtract(const Duration(days: 7)),
        score: 5,
        code: '''class StudentProfile {
    public final String name;
    public StudentProfile(String name) { this.name = name; }
    public String summary() { return String.format("Student: %s", name); }
}
class BootcampStudent extends StudentProfile {
    public final int points;
    public BootcampStudent(String name, int points) {
        super(name);
        this.points = points;
    }
    @Override
    public String summary() {
        return String.format("%s finished OOP Midterm with %d points.", name, points);
    }
}
class Main {
    public static void main(String[] args) {
        BootcampStudent student = new BootcampStudent("Aida", 86);
        System.out.println(student.summary());
    }
}''',
        likes: 42,
        likedByMe: false,
        comments: [
          'Красиво с форматированием строк!',
          'String.format работает чуть медленнее обычной конкатенации, но выглядит очень премиально.',
        ],
      ),
      _StudentSolution(
        id: '#943110992',
        user: 'Timur D.',
        date: '1 месяц назад',
        dateParsed: DateTime.now().subtract(const Duration(days: 30)),
        score: 4,
        code: '''class StudentProfile {
    public final String name;
    public StudentProfile(String name) { this.name = name; }
    public String summary() { return "Student: " + this.name; }
}
class BootcampStudent extends StudentProfile {
    public final int points;
    public BootcampStudent(String name, int points) {
        super(name);
        this.points = points;
    }
    @Override
    public String summary() {
        return name + " finished OOP Midterm with " + points + " points.";
    }
}
class Main {
    public static void main(String[] args) {
        System.out.println(new BootcampStudent("Aida", 86).summary());
    }
}''',
        likes: 5,
        likedByMe: false,
        comments: [
          'Можно было сохранить инстанс студента в локальную переменную, но в целом тоже отлично.',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final locale = widget.locale;
    final comments = widget.comments;
    final commentController = widget.commentController;
    final onSend = widget.onSend;

    return GlowCard(
      accent: colors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TabButton(
                label: _practiceText(
                  locale,
                  ru: 'Комментарии',
                  en: 'Comments',
                  kk: 'Пікірлер',
                ),
                isActive: _currentTab == 0,
                onTap: () => setState(() => _currentTab = 0),
                colors: colors,
              ),
              const SizedBox(width: 8),
              _TabButton(
                label: _practiceText(
                  locale,
                  ru: 'Решения',
                  en: 'Solutions',
                  kk: 'Шешімдер',
                ),
                isActive: _currentTab == 1,
                onTap: () => setState(() => _currentTab = 1),
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_currentTab == 0) ...[
            Text(
              _practiceText(
                locale,
                ru: 'Обсуждение',
                en: 'Comments',
                kk: 'Талқылау',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              _practiceText(
                locale,
                ru: 'Задайте вопрос менторам или поделитесь инсайтами по выполнению этого задания.',
                en: 'Use the thread to leave notes, ask for a review, or capture what helped during the OOP submission.',
                kk: 'Тәлімгерлерден сұраңыз немесе осы тапсырманы орындау бойынша түсініктермен бөлісіңіз.',
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
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.divider),
                ),
                child: Text(
                  _practiceText(
                    locale,
                    ru: 'Комментариев пока нет. Начните обсуждение!',
                    en: 'No comments yet. Start the discussion from here.',
                    kk: 'Пікірлер әлі жоқ. Талқылауды бастаңыз!',
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
                  ru: 'Написать комментарий к заданию...',
                  en: 'Write a comment for the midterm thread',
                  kk: 'Тапсырмаға пикиріңізді жазыңыз...',
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
                    ru: 'Отправить комментарий',
                    en: 'Send comment',
                    kk: 'Пікір жіберу',
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _practiceText(
                    locale,
                    ru: 'Готовые решения',
                    en: 'Student Solutions',
                    kk: 'Дайын шешімдер',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                // Sorting options
                Row(
                  children: [
                    _SortButton(
                      label: _practiceText(
                        locale,
                        ru: 'Лайки',
                        en: 'Likes',
                        kk: 'Лайктар',
                      ),
                      isActive: _sortBy == 'likes',
                      onTap: () => setState(() => _sortBy = 'likes'),
                      colors: colors,
                    ),
                    const SizedBox(width: 8),
                    _SortButton(
                      label: _practiceText(
                        locale,
                        ru: 'Дата',
                        en: 'Date',
                        kk: 'Күні',
                      ),
                      isActive: _sortBy == 'date',
                      onTap: () => setState(() => _sortBy = 'date'),
                      colors: colors,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _practiceText(
                locale,
                ru: 'Посмотрите, как решили эту задачу другие студенты, чтобы сравнить архитектурные подходы.',
                en: 'Compare different object-oriented architecture patterns from other student submissions.',
                kk: 'Сәулеттік тәсілдерді салыстыру үшін басқа студенттердің бұл мәселені қалай шешкенін көріңіз.',
              ),
              style: TextStyle(color: colors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 16),
            ...() {
              final sorted = List<_StudentSolution>.from(_solutions);
              if (_sortBy == 'likes') {
                sorted.sort((a, b) => b.likes.compareTo(a.likes));
              } else {
                sorted.sort((a, b) => b.dateParsed.compareTo(a.dateParsed));
              }
              return sorted.map((sol) => _SolutionDetailCard(
                solution: sol,
                colors: colors,
                locale: locale,
              )).toList();
            }(),
          ],
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
    final hasError = output.toLowerCase().contains('error');
    final textColor = hasError ? Colors.redAccent.shade100 : Colors.greenAccent.shade100;

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F), // Terminal pure dark
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          output,
          style: TextStyle(
            color: textColor,
            fontFamily: 'monospace',
            height: 1.5,
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
