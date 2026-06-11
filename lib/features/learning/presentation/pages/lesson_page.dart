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
import '../../../../core/network/api_exception.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../ai/presentation/providers/ai_chat_controller.dart';
import '../../../courses_backend/data/models/backend_code_attempt_dto.dart';
import '../../../courses_backend/data/models/backend_lesson_dto.dart';
import '../../../courses_backend/data/models/backend_practice_dto.dart';
import '../../../courses_backend/data/models/backend_practice_submission_dto.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../widgets/premium_code_editor.dart';
import '../../../home/presentation/pages/backend_course_player_page.dart' show oopVideoUrls;

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

enum LessonStepKind { theory, quiz, trainer, code }

class LessonStep {
  const LessonStep({
    required this.kind,
    this.quiz,
    this.trainer,
    this.practice,
    this.id,
  });
  final LessonStepKind kind;
  final LessonQuiz? quiz;
  final CodeTrainer? trainer;

  /// Real backend practice task (curriculum-service `practice_tasks`) backing a
  /// code step. When set, the step renders the task's own title/description and
  /// grades Run/Submit through `/practice/:id/run` instead of a generic editor.
  final BackendPracticeDto? practice;
  final String? id;
}

class _LessonPageState extends ConsumerState<LessonPage> {
  final Map<String, String> _selectedQuizAnswers = <String, String>{};
  final Map<String, String> _selectedTrainerAnswers = <String, String>{};
  final Map<String, List<String>> _trainerSequences = <String, List<String>>{};
  final Map<String, String> _codeTexts = <String, String>{};
  final ScrollController _theoryScrollController = ScrollController();
  final Map<String, bool> _codeStepSubmitted = <String, bool>{};

  /// Per practice-step backend state: in-flight flag, last attempt result and
  /// console text. Keyed by the step id (`practice_<uuid>`).
  final Set<String> _practiceRunning = <String>{};
  final Map<String, BackendCodeAttemptResultDto> _practiceResults =
      <String, BackendCodeAttemptResultDto>{};
  final Map<String, String> _practiceConsole = <String, String>{};

  /// Theory marked on the backend once per lesson so practice prerequisites and
  /// lesson completion can fire without depending on the final button.
  bool _theoryMarkedOnBackend = false;

  /// Id of the last step in the freshly built list (set in [build]); used to
  /// decide when finishing a practice should also finalize the whole lesson.
  String? _lastStepId;
  int _currentStepIndex = 0;

  /// XP reward from the backend lesson. Latched on the first successful load
  /// so the completion notification always shows the real backend value, even
  /// if the provider was still loading when the page first built.
  int? _backendXpReward;

  @override
  void initState() {
    super.initState();
    _theoryScrollController.addListener(_onTheoryScroll);
    // Mark lesson as started when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(demoAppControllerProvider.notifier).startLesson(widget.lessonId);
    });
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

  List<LessonStep> _buildSteps(
    LessonItem lesson,
    List<BackendPracticeDto> practices,
  ) {
    final steps = <LessonStep>[];

    // Step 1: Theory
    steps.add(
      LessonStep(kind: LessonStepKind.theory, id: '${widget.lessonId}_theory'),
    );

    for (final quiz in lesson.quizzes) {
      steps.add(LessonStep(kind: LessonStepKind.quiz, quiz: quiz, id: quiz.id));
    }

    for (final trainer in lesson.codeTrainers) {
      steps.add(
        LessonStep(
          kind: LessonStepKind.trainer,
          trainer: trainer,
          id: trainer.id,
        ),
      );
    }

    if (practices.isNotEmpty) {
      // Real, topic-specific practice tasks from curriculum-service: one
      // graded code step each (Run/Submit go through /practice/:id/run).
      for (final practice in practices) {
        steps.add(
          LessonStep(
            kind: LessonStepKind.code,
            practice: practice,
            id: 'practice_${practice.id}',
          ),
        );
      }
    } else if (!_isBackendId(widget.lessonId) &&
        (lesson.codeSnippet.trim().isNotEmpty ||
            lesson.exampleOutput.trim().isNotEmpty)) {
      // Local demo-catalog lessons keep the lightweight generic editor step.
      steps.add(
        LessonStep(kind: LessonStepKind.code, id: '${widget.lessonId}_code'),
      );
    }

    return steps;

    /*
    // 5 Quiz steps
    for (int i = 0; i < 5; i++) {
      final quiz = lesson.quizzes.isNotEmpty
          ? lesson.quizzes[i % lesson.quizzes.length]
          : LessonQuiz(
              id: '${widget.lessonId}_quiz_$i',
              title: LocalizedText(
                ru: 'Вопрос ${i + 1}',
                en: 'Question ${i + 1}',
                kk: 'Сұрақ ${i + 1}',
              ),
              prompt: LocalizedText(
                ru: 'Выберите правильный ответ',
                en: 'Choose the correct answer',
                kk: 'Дұрыс жауапты таңдаңыз',
              ),
              options: [
                QuizOption(
                  id: 'a',
                  label: LocalizedText(
                    ru: 'Вариант А',
                    en: 'Option A',
                    kk: 'А нұсқасы',
                  ),
                ),
                QuizOption(
                  id: 'b',
                  label: LocalizedText(
                    ru: 'Вариант Б',
                    en: 'Option B',
                    kk: 'Б нұсқасы',
                  ),
                ),
              ],
              correctOptionId: 'a',
              explanation: LocalizedText(
                ru: 'Объяснение',
                en: 'Explanation',
                kk: 'Түсініктеме',
              ),
            );
      steps.add(LessonStep(kind: LessonStepKind.quiz, quiz: quiz, id: quiz.id));
    }

    // 3 Code steps
    for (int i = 0; i < 3; i++) {
      steps.add(
        LessonStep(kind: LessonStepKind.code, id: '${widget.lessonId}_code_$i'),
      );
    }

    return steps;
    */
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);

    // For backend OOP lessons (UUID IDs), fetch from backend provider
    final backendLessonAsync = ref.watch(
      backendOopLessonItemProvider(widget.lessonId),
    );
    final backendLesson = backendLessonAsync.maybeWhen(
      data: (l) => l,
      orElse: () => null,
    );
    final lesson = backendLesson ?? catalog.lessonById(widget.lessonId);

    // Latch the backend xpReward as soon as it arrives so the completion
    // notification always shows the real value, even if the button is pressed
    // before or after the provider rebuild.
    if (backendLesson != null && _backendXpReward == null) {
      // Use addPostFrameCallback to avoid setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _backendXpReward == null) {
          setState(() => _backendXpReward = backendLesson.xpReward);
        }
      });
    }
    // Real practice tasks for this lesson (graded via /practice/:id/run).
    final practices = ref
        .watch(backendPracticesForLessonProvider(widget.lessonId))
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <BackendPracticeDto>[],
        );

    final completed = state.completedLessonIds.contains(widget.lessonId);
    final colors = context.appColors;
    final l10n = context.l10n;
    final locale = state.locale;

    final steps = _buildSteps(lesson, practices);
    _lastStepId = steps.isNotEmpty ? steps.last.id : null;
    final currentStep =
        steps[_currentStepIndex.clamp(0, steps.length - 1)];

    return AppPageScaffold(
      title: lesson.title.resolve(state.locale),
      expandContent: true, // Allow content to fill available height
      child: Column(
        children: [
          // Step progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Per-step color strips
                Row(
                  children: List.generate(steps.length, (i) {
                    final done = _isStepCompleted(steps[i], state);
                    final active = _currentStepIndex == i;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        margin: EdgeInsets.only(
                          right: i < steps.length - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: done
                              ? colors.success
                              : active
                              ? colors.primary
                              : colors.surfaceSoft,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                // Chip row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...List.generate(steps.length, (index) {
                        final step = steps[index];
                        final isActive = _currentStepIndex == index;
                        final isStepCompleted = _isStepCompleted(step, state);
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _currentStepIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? colors.success
                                  : isStepCompleted
                                  ? colors.success.withValues(alpha: 0.3)
                                  : colors.surfaceSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.55)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: _getStepIcon(
                                step,
                                isActive
                                    ? Colors.white
                                    : isStepCompleted
                                    ? colors.success
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                      Text(
                        '${_currentStepIndex + 1} / ${steps.length}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              controller: currentStep.kind == LessonStepKind.theory
                  ? _theoryScrollController
                  : null,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                _buildStepContent(
                  currentStep,
                  lesson,
                  state,
                  controller,
                  colors,
                  l10n,
                  locale,
                ),
                if (currentStep.kind != LessonStepKind.code) ...[
                  const SizedBox(height: 24),
                  // Navigation Buttons
                  Row(
                    children: [
                      if (_currentStepIndex > 0)
                        Expanded(
                          child: AppButton.secondary(
                            label: l10n.text('lesson_step_previous'),
                            onPressed: () =>
                                setState(() => _currentStepIndex--),
                          ),
                        ),
                      if (_currentStepIndex > 0) const SizedBox(width: 12),
                      if (_currentStepIndex < steps.length - 1)
                        Expanded(
                          child: AppButton.primary(
                            label: l10n.text('next_step'),
                            onPressed: () {
                              // Leaving the theory step marks theory complete on
                              // the backend so practices unlock and the lesson
                              // can auto-complete once all tasks are done.
                              if (currentStep.kind == LessonStepKind.theory) {
                                _markTheoryOnBackend();
                              }
                              setState(() => _currentStepIndex++);
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: AppButton.primary(
                            label: l10n.text('lesson_step_submit'),
                            icon: completed
                                ? Icons.check_circle_rounded
                                : Icons.done_rounded,
                            onPressed: () async {
                              controller.completeLesson(widget.lessonId);
                              // Backend: record lesson completion server-side.
                              // Progress, XP and streak are tracked by the
                              // curriculum service via this endpoint. Only real
                              // backend lessons (UUID ids) are synced.
                              try {
                                final accessToken = ref.read(
                                  backendCourseAccessTokenProvider,
                                );
                                if (accessToken != null &&
                                    accessToken.trim().isNotEmpty &&
                                    _isBackendId(widget.lessonId)) {
                                  final remote = ref.read(
                                    backendCourseRemoteDataSourceProvider,
                                  );
                                  await remote.completeLesson(
                                    accessToken: accessToken,
                                    lessonId: widget.lessonId,
                                  );
                                }
                              } catch (_) {
                                // Backend unavailable — keep local progress; the
                                // completion will not be reflected on the server.
                              }
                              ref.invalidate(backendStreakProvider);
                              ref.invalidate(backendOopProgressProvider);
                              ref.invalidate(backendAllProgressProvider);
                              ref.invalidate(backendAchievementsProvider);
                              ref.invalidate(backendProfileProvider);
                              if (!context.mounted) {
                                return;
                              }

                              // Use backend XP if already latched; otherwise
                              // re-read the provider (may have loaded by now).
                              final xp =
                                  _backendXpReward ??
                                  ref
                                      .read(
                                        backendOopLessonItemProvider(
                                          widget.lessonId,
                                        ),
                                      )
                                      .maybeWhen(
                                        data: (l) => l?.xpReward,
                                        orElse: () => null,
                                      ) ??
                                  lesson.xpReward;
                              AppNotice.show(
                                context,
                                message: '+$xp XP',
                                type: AppNoticeType.success,
                              );
                              // Fire an OS notification (Android/iOS/Windows/…)
                              final notifTitle = switch (locale) {
                                AppLocale.ru => 'Урок завершён! 🎉',
                                AppLocale.kk => 'Сабақ аяқталды! 🎉',
                                AppLocale.en => 'Lesson completed! 🎉',
                              };
                              final notifBody = switch (locale) {
                                AppLocale.ru =>
                                  'Вы заработали +$xp XP. Так держать!',
                                AppLocale.kk =>
                                  'Сіз +$xp XP жинадыңыз. Жарайсыз!',
                                AppLocale.en =>
                                  'You earned +$xp XP. Keep it up!',
                              };
                              ref
                                  .read(localNotificationServiceProvider)
                                  .showNotification(
                                    id: 5001,
                                    title: notifTitle,
                                    body: notifBody,
                                    payload: 'lesson:${widget.lessonId}',
                                  );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
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
        return Icon(Icons.menu_book_rounded, size: 15, color: color);
      case LessonStepKind.quiz:
        return Icon(Icons.quiz_rounded, size: 15, color: color);
      case LessonStepKind.trainer:
        return Icon(Icons.memory_rounded, size: 15, color: color);
      case LessonStepKind.code:
        return Icon(Icons.code_rounded, size: 15, color: color);
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
            // Meta: duration + XP
            Row(
              children: [
                _MetaChip(
                  icon: Icons.schedule_outlined,
                  label: '${lesson.durationMinutes} ${l10n.text('minutes')}',
                  colors: colors,
                ),
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.bolt_rounded,
                  label: '${lesson.xpReward} XP',
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 270,
                  width: 670,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF0D1B2A),
                          colors.primary.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.45),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            switch (locale) {
                              AppLocale.ru => 'Видео по теме',
                              AppLocale.kk => 'Тақырып бойынша бейне',
                              _ => 'Topic Video',
                            },
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lesson.summary.resolve(locale).trim().isNotEmpty)
                  Expanded(
                    child: Text(
                      lesson.summary.resolve(locale),
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (_oopVideoUrl(widget.lessonId) != null) ...[
                  if (lesson.summary.resolve(locale).trim().isNotEmpty)
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _oopVideoUrl(widget.lessonId)!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Theory content
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
            const SizedBox(height: 14),
            AppButton.secondary(
              label: context.l10n.text('ask_ai'),
              icon: Icons.smart_toy_rounded,
              onPressed: () {
                final state2 = ref.read(demoAppControllerProvider);
                ref
                    .read(aiChatControllerProvider.notifier)
                    .createNewChat(lesson.title.resolve(state2.locale));
                context.go(AppRoutes.ai);
                unawaited(
                  ref
                      .read(aiChatControllerProvider.notifier)
                      .sendMessage(
                        lesson.promptSuggestion.resolve(state2.locale),
                      ),
                );
              },
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
          onOptionSelected: (optionId) =>
              setState(() => _selectedQuizAnswers[quiz.id] = optionId),
          onSubmit: () async {
            final selected = _selectedQuizAnswers[quiz.id];
            if (selected == null) return;

            // For backend quizzes (UUID ids) the server is the source of
            // truth: we submit the answer and use is_correct + explanation
            // from the response. For local/fallback quizzes we grade locally.
            bool correct;
            String? serverExplanation;

            if (_isBackendId(quiz.id)) {
              try {
                final accessToken = ref.read(backendCourseAccessTokenProvider);
                if (accessToken != null && accessToken.trim().isNotEmpty) {
                  final remote = ref.read(
                    backendCourseRemoteDataSourceProvider,
                  );
                  final selectedIndex = quiz.options.indexWhere(
                    (o) => o.id == selected,
                  );
                  if (selectedIndex >= 0) {
                    final result = await remote.submitQuizAnswer(
                      accessToken: accessToken,
                      quizId: quiz.id,
                      selectedAnswerIndex: selectedIndex,
                    );
                    correct = result.isCorrect;
                    final exp = _resolveBackendText(result.explanation, locale);
                    if (exp.trim().isNotEmpty) serverExplanation = exp;
                  } else {
                    correct = selected == quiz.correctOptionId;
                  }
                } else {
                  correct = selected == quiz.correctOptionId;
                }
              } catch (_) {
                // Backend unavailable — fall back to local check
                correct = selected == quiz.correctOptionId;
              }
            } else {
              correct = selected == quiz.correctOptionId;
            }

            controller.completeQuiz(quiz.id, isCorrect: correct);

            // Invalidate server-side counters so achievements, streak and
            // progress reflect the just-submitted answer immediately.
            if (correct && _isBackendId(quiz.id)) {
              ref.invalidate(backendAchievementsProvider);
              ref.invalidate(backendOopProgressProvider);
              ref.invalidate(backendProfileProvider);
              ref.invalidate(backendAllProgressProvider);
            }

            if (!mounted) return;

            // Show server explanation on wrong answer if available, else
            // fall back to the locally stored explanation.
            final explanationText = !correct
                ? (serverExplanation ?? quiz.explanation.resolve(locale))
                : null;

            AppNotice.show(
              context,
              message: correct
                  ? l10n.text('lesson_quiz_correct')
                  : (explanationText?.isNotEmpty == true
                        ? explanationText!
                        : l10n.text('lesson_quiz_retry')),
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
          onOptionSelected: (optionId) =>
              setState(() => _selectedTrainerAnswers[trainer.id] = optionId),
          onSequenceChanged: (sequence) =>
              setState(() => _trainerSequences[trainer.id] = sequence),
          onSubmit: () {
            final isCorrect = _isTrainerCorrect(trainer);
            if (isCorrect) controller.completeTrainer(trainer.id);
            AppNotice.show(
              context,
              message: isCorrect
                  ? l10n.text('lesson_memory_completed')
                  : l10n.text('lesson_memory_retry'),
              type: isCorrect ? AppNoticeType.success : AppNoticeType.error,
            );
          },
        );
      case LessonStepKind.code:
        // Real backend practice task → graded code step (Run/Submit via
        // /practice/:id/run). Falls back to the generic editor below only for
        // local demo-catalog lessons that have no practice_tasks.
        if (step.practice != null) {
          final isLastStep = step.id == _lastStepId;
          return _buildBackendPracticeStep(
            practice: step.practice!,
            stepId: step.id!,
            isLastStep: isLastStep,
            state: state,
            controller: controller,
            colors: colors,
            locale: locale,
          );
        }

        final stepId = step.id!;

        // Determine initial code: use lesson.codeSnippet or default Java Main class
        String getInitialCode() {
          if (lesson.codeSnippet.isNotEmpty) return lesson.codeSnippet;
          return 'public class Main {\n    public static void main(String[] args) {\n        // Напишите ваш код здесь\n        System.out.println("Hello World");\n    }\n}';
        }

        // Track code text for submission (PremiumCodeEditor manages its own controller)
        String getCodeText() {
          return _codeTexts[stepId] ?? getInitialCode();
        }

        // Define expected output for validation
        final expectedOutput = lesson.exampleOutput.isNotEmpty
            ? lesson.exampleOutput
            : 'Hello, Java!';
        final isCompleted = state.completedCodeStepIds.contains(stepId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Задание ${stepId.split('_').last}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Напишите код, нажмите "Run Code" для проверки, затем "Submit" для отправки.',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
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
                    'Тестовые данные',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Input: (нет ввода)',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expected Output: $expectedOutput',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // PremiumCodeEditor — Submit is handled by the editor's own button.
            PremiumCodeEditor(
              key: ValueKey<String>('${widget.lessonId}_editor_$stepId'),
              initialCode: getCodeText(),
              language: 'java',
              expectedOutput: expectedOutput,
              isSubmitted: isCompleted,
              onCodeChanged: (code) {
                setState(() {
                  _codeTexts[stepId] = code;
                });
              },
              onSubmit: isCompleted
                  ? null
                  : (result) {
                      if (result.error.isNotEmpty) {
                        AppNotice.show(
                          context,
                          message: 'Ошибка выполнения: ${result.error}',
                          type: AppNoticeType.error,
                        );
                        return;
                      }
                      final output = result.stdout.trim();
                      final expected = expectedOutput.trim();
                      final passed =
                          expected.isEmpty ||
                          output == expected ||
                          output.contains(expected);
                      if (passed) {
                        controller.completeCodeStep(stepId);
                        setState(() => _codeStepSubmitted[stepId] = true);
                        final xpPerStep = (lesson.xpReward / 3).round().clamp(
                          5,
                          30,
                        );
                        AppNotice.show(
                          context,
                          message: '+$xpPerStep XP — код принят!',
                          type: AppNoticeType.success,
                        );
                      } else {
                        AppNotice.show(
                          context,
                          message: 'Вывод не совпадает. Ожидалось: "$expected"',
                          type: AppNoticeType.error,
                        );
                      }
                    },
            ),
          ],
        );
    }
  }

  /// Renders a real `practice_tasks` entry: its own title/description + an
  /// editor whose Run/Submit are graded by curriculum-service
  /// (`/practice/:id/run` for auto tasks, teacher review for manual tasks).
  Widget _buildBackendPracticeStep({
    required BackendPracticeDto practice,
    required String stepId,
    required bool isLastStep,
    required DemoAppState state,
    required DemoAppController controller,
    required AppThemeColors colors,
    required AppLocale locale,
  }) {
    final isManual = practice.checkType.trim().toLowerCase() == 'manual';
    final isRunning = _practiceRunning.contains(stepId);
    final isDone =
        state.completedCodeStepIds.contains(stepId) ||
        (_codeStepSubmitted[stepId] ?? false);
    final result = _practiceResults[stepId];
    final console = _practiceConsole[stepId];
    final title = _resolveBackendText(practice.title, locale);
    final description = practice.description.trim();
    final initialCode = _codeTexts[stepId] ?? _practiceInitialCode(practice);
    final submitLabel = isRunning
        ? 'Отправка…'
        : isDone
        ? (isManual ? 'Отправлено' : 'Принято')
        : (isManual ? 'Отправить на ревью' : 'Submit');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.isNotEmpty ? title : 'Практическое задание',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (description.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Text(
              description,
              style: TextStyle(
                color: colors.textPrimary,
                height: 1.45,
                fontFamily: 'monospace',
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              isManual ? Icons.rate_review_rounded : Icons.bolt_rounded,
              size: 16,
              color: isManual ? colors.accent : colors.success,
            ),
            const SizedBox(width: 6),
            Text(
              isManual
                  ? 'Проверяет преподаватель'
                  : 'Авто-проверка по выводу программы',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const Spacer(),
            if (practice.xpReward > 0)
              Text(
                '+${practice.xpReward} XP',
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        PremiumCodeEditor(
          key: ValueKey<String>('${widget.lessonId}_$stepId'),
          initialCode: initialCode,
          language: practice.language.trim().isEmpty
              ? 'java'
              : practice.language.trim(),
          isSubmitted: isDone,
          // Execution is driven by the Run/Submit buttons below (backend
          // /practice/:id/run), so hide the editor's own local Run button.
          showRunButton: false,
          onCodeChanged: (code) => _codeTexts[stepId] = code,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: isRunning ? 'Запуск…' : 'Run code',
                icon: Icons.play_arrow_rounded,
                onPressed: (isRunning || isDone)
                    ? null
                    : () => _runLessonPractice(
                        practice: practice,
                        stepId: stepId,
                        runType: 'run',
                        isLastStep: isLastStep,
                        locale: locale,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.primary(
                label: submitLabel,
                icon: isDone
                    ? Icons.check_circle_rounded
                    : Icons.send_rounded,
                onPressed: (isRunning || isDone)
                    ? null
                    : () => isManual
                          ? _submitManualLessonPractice(
                              practice: practice,
                              stepId: stepId,
                            )
                          : _runLessonPractice(
                              practice: practice,
                              stepId: stepId,
                              runType: 'submit',
                              isLastStep: isLastStep,
                              locale: locale,
                            ),
              ),
            ),
          ],
        ),
        if (console != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Вывод',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (result != null) ...[
                      const SizedBox(width: 10),
                      Icon(
                        result.passed
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        size: 16,
                        color: result.passed ? colors.success : colors.danger,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        result.passed
                            ? 'Пройдено${result.xpAwarded > 0 ? ' · +${result.xpAwarded} XP' : ''}'
                            : 'Не пройдено',
                        style: TextStyle(
                          color: result.passed
                              ? colors.success
                              : colors.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  console,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _practiceInitialCode(BackendPracticeDto practice) {
    if (practice.starterCode.trim().isNotEmpty) return practice.starterCode;
    return 'public class Main {\n    public static void main(String[] args) {\n        // Напишите ваше решение здесь\n    }\n}';
  }

  /// Runs (`run`) or grades (`submit`) a practice through curriculum-service.
  /// On a passing submit the backend records progress, awards XP and may mark
  /// the whole lesson complete — so we refresh the backend providers and, for
  /// the final step, finalize the lesson locally too.
  Future<void> _runLessonPractice({
    required BackendPracticeDto practice,
    required String stepId,
    required String runType,
    required bool isLastStep,
    required AppLocale locale,
  }) async {
    final accessToken = ref.read(backendCourseAccessTokenProvider)?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      AppNotice.show(
        context,
        message: 'Нет соединения с сервером. Войдите снова.',
        type: AppNoticeType.error,
      );
      return;
    }

    // Ensure theory is marked first so the practice prerequisite check passes
    // even if the student jumped straight here via the step chips.
    await _markTheoryOnBackend();

    final code = _codeTexts[stepId] ?? _practiceInitialCode(practice);
    if (!mounted) return;
    setState(() => _practiceRunning.add(stepId));

    try {
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      final result = await remote.runPractice(
        accessToken: accessToken,
        practiceId: practice.id,
        courseId: practice.courseId,
        lessonId: practice.lessonId,
        runType: runType,
        language: practice.language.trim().isEmpty
            ? 'java'
            : practice.language.trim(),
        code: code,
      );

      if (!mounted) return;

      final consoleText = [
        if (result.output.trim().isNotEmpty) result.output.trim(),
        if (result.error.trim().isNotEmpty) result.error.trim(),
      ].join('\n');

      setState(() {
        _practiceRunning.remove(stepId);
        _practiceResults[stepId] = result;
        _practiceConsole[stepId] = consoleText.isEmpty
            ? 'Программа не вывела ничего.'
            : consoleText;
      });

      if (runType != 'submit') return;

      if (result.passed) {
        ref.read(demoAppControllerProvider.notifier).completeCodeStep(stepId);
        ref.invalidate(backendStreakProvider);
        ref.invalidate(backendOopProgressProvider);
        ref.invalidate(backendAllProgressProvider);
        ref.invalidate(backendAchievementsProvider);
        ref.invalidate(backendProfileProvider);
        AppNotice.show(
          context,
          message: result.xpAwarded > 0
              ? '+${result.xpAwarded} XP — задача принята!'
              : 'Задача принята!',
          type: AppNoticeType.success,
        );
        if (isLastStep) _finalizeLessonLocally(locale);
      } else {
        AppNotice.show(
          context,
          message:
              'Вывод не совпал с ожидаемым. Сравните результат и попробуйте снова.',
          type: AppNoticeType.error,
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _practiceRunning.remove(stepId));
      final message = e.code == 'practice_prerequisites_not_met'
          ? 'Сначала пройдите теорию и тесты этого урока, затем отправляйте практику.'
          : (e.message.trim().isNotEmpty
                ? e.message.trim()
                : 'Не удалось выполнить код. Попробуйте ещё раз.');
      AppNotice.show(context, message: message, type: AppNoticeType.error);
    } catch (_) {
      if (!mounted) return;
      setState(() => _practiceRunning.remove(stepId));
      AppNotice.show(
        context,
        message: 'Code runner недоступен. Проверьте соединение.',
        type: AppNoticeType.error,
      );
    }
  }

  /// Sends a manual practice solution to the teacher review queue
  /// (`POST /practice/:id/submissions`). Completion happens after the teacher
  /// approves it, so we only lock the step as "submitted" here.
  Future<void> _submitManualLessonPractice({
    required BackendPracticeDto practice,
    required String stepId,
  }) async {
    final accessToken = ref.read(backendCourseAccessTokenProvider)?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      AppNotice.show(
        context,
        message: 'Нет соединения с сервером. Войдите снова.',
        type: AppNoticeType.error,
      );
      return;
    }

    final code = _codeTexts[stepId] ?? _practiceInitialCode(practice);
    final result = _practiceResults[stepId];
    setState(() => _practiceRunning.add(stepId));

    try {
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      await remote.createPracticeSubmission(
        accessToken: accessToken,
        practiceId: practice.id,
        request: BackendCreatePracticeSubmissionRequest(
          code: code,
          language: practice.language.trim().isEmpty
              ? 'java'
              : practice.language.trim(),
          output: result?.output ?? _practiceConsole[stepId] ?? '',
          error: result?.error ?? '',
          errorType: result?.errorType ?? '',
          durationMs: result?.durationMs,
        ),
      );

      if (!mounted) return;
      setState(() {
        _practiceRunning.remove(stepId);
        _codeStepSubmitted[stepId] = true;
      });
      ref.invalidate(backendOopProgressProvider);
      ref.invalidate(backendAllProgressProvider);
      ref.invalidate(backendMyPracticeSubmissionsProvider);
      AppNotice.show(
        context,
        message: 'Решение отправлено на проверку преподавателю.',
        type: AppNoticeType.success,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _practiceRunning.remove(stepId));
      AppNotice.show(
        context,
        message: 'Не удалось отправить решение. Попробуйте ещё раз.',
        type: AppNoticeType.error,
      );
    }
  }

  /// Marks the lesson's theory complete on the backend (idempotent, once per
  /// lesson). This sets `theory_completed_at`, which unlocks practice runs and
  /// lets the server auto-complete the lesson once every task is done.
  Future<void> _markTheoryOnBackend() async {
    if (_theoryMarkedOnBackend || !_isBackendId(widget.lessonId)) return;
    _theoryMarkedOnBackend = true;
    final accessToken = ref.read(backendCourseAccessTokenProvider)?.trim();
    if (accessToken == null || accessToken.isEmpty) return;
    try {
      await ref
          .read(backendCourseRemoteDataSourceProvider)
          .completeLesson(accessToken: accessToken, lessonId: widget.lessonId);
      ref.invalidate(backendOopProgressProvider);
      ref.invalidate(backendAllProgressProvider);
    } catch (_) {
      // Best-effort; the explicit completion button is still available.
    }
  }

  /// Local + notification bookkeeping when the final practice of a lesson is
  /// accepted (the server already recorded the real completion).
  void _finalizeLessonLocally(AppLocale locale) {
    ref.read(demoAppControllerProvider.notifier).completeLesson(widget.lessonId);
    final notifTitle = switch (locale) {
      AppLocale.ru => 'Урок завершён! 🎉',
      AppLocale.kk => 'Сабақ аяқталды! 🎉',
      AppLocale.en => 'Lesson completed! 🎉',
    };
    ref
        .read(localNotificationServiceProvider)
        .showNotification(
          id: 5001,
          title: notifTitle,
          body: switch (locale) {
            AppLocale.ru => 'Все задания выполнены. Так держать!',
            AppLocale.kk => 'Барлық тапсырма орындалды. Жарайсыз!',
            AppLocale.en => 'All tasks done. Keep it up!',
          },
          payload: 'lesson:${widget.lessonId}',
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

final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// Whether [id] looks like a backend (curriculum-service) UUID, as opposed to
/// a local demo-catalog id. Only backend lessons are synced to the server.
bool _isBackendId(String id) => _uuidPattern.hasMatch(id.trim());

/// Picks the right locale field from a [BackendLocalizedTextDto], falling back
/// to the first non-empty language when the preferred one is empty.
String _resolveBackendText(BackendLocalizedTextDto dto, AppLocale locale) {
  String pick(String preferred, String a, String b) {
    if (preferred.trim().isNotEmpty) return preferred.trim();
    if (a.trim().isNotEmpty) return a.trim();
    return b.trim();
  }

  switch (locale) {
    case AppLocale.ru:
      return pick(dto.ru, dto.en, dto.kk);
    case AppLocale.kk:
      return pick(dto.kk, dto.ru, dto.en);
    case AppLocale.en:
      return pick(dto.en, dto.ru, dto.kk);
  }
}

/// Returns the YouTube URL for an OOP lesson, supporting both backend UUIDs
/// (ee010601-...) and local catalog IDs (oop_lesson_1_6).
String? _oopVideoUrl(String lessonId) {
  if (oopVideoUrls.containsKey(lessonId)) return oopVideoUrls[lessonId];
  final m = RegExp(r'^oop_lesson_(\d+)_(\d+)$').firstMatch(lessonId);
  if (m != null) {
    final mod = m.group(1)!.padLeft(2, '0');
    final les = m.group(2)!.padLeft(2, '0');
    return oopVideoUrls['ee$mod${les}01-0000-0000-0000-000000000000'];
  }
  return null;
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
    final colors = context.appColors;
    final title = quiz.prompt.resolve(locale);
    final explanation = quiz.explanation.resolve(locale).trim();

    return GlowCard(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...quiz.options.map((option) {
            var reveal = _OptionReveal.none;
            if (completed) {
              if (option.id == quiz.correctOptionId) {
                reveal = _OptionReveal.correct;
              } else if (option.id == selectedOptionId) {
                reveal = _OptionReveal.wrong;
              }
            }
            return _OptionTile(
              label: option.label.resolve(locale),
              selected: selectedOptionId == option.id,
              enabled: !completed,
              reveal: reveal,
              onTap: () => onOptionSelected(option.id),
            );
          }),
          if (completed && explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      explanation,
                      style: TextStyle(color: colors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
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

/// Reveal state of a quiz option after the answer was checked.
enum _OptionReveal { none, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.reveal = _OptionReveal.none,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final _OptionReveal reveal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Color bg = selected
        ? colors.primary.withValues(alpha: 0.14)
        : colors.surfaceSoft;
    Color borderColor = selected ? colors.primary : colors.divider;
    Widget? trailing;

    if (reveal == _OptionReveal.correct) {
      bg = colors.success.withValues(alpha: 0.16);
      borderColor = colors.success;
      trailing = Icon(Icons.check_circle_rounded, color: colors.success, size: 20);
    } else if (reveal == _OptionReveal.wrong) {
      bg = colors.danger.withValues(alpha: 0.16);
      borderColor = colors.danger;
      trailing = Icon(Icons.cancel_rounded, color: colors.danger, size: 20);
    }

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
            color: bg,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: TextStyle(color: colors.textPrimary)),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
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
