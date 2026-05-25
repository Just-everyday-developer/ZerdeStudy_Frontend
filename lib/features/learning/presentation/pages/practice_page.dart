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
import '../../../../core/theme/app_theme_colors.dart';
import '../../../ai/presentation/providers/ai_chat_controller.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/data/models/backend_practice_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../../domain/models/code_execution.dart';
import '../widgets/premium_code_editor.dart';

/// Legacy demo exam flow kept for fallback when the catalog practice is missing.
const String kMockJavaExamPracticeId = 'demo_java_certification_exam';

bool _looksLikeUuid(String value) {
  return RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(value.trim());
}

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({super.key, required this.practiceId});

  final String practiceId;

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  final TextEditingController _commentController = TextEditingController();
  final Set<int> _selectedKnowledgeChecks = <int>{};
  final List<String> _userComments = <String>[];
  String? _draftOutput;
  String _editorCode = '';

  final int _currentExamTaskIndex = 0;
  final Set<int> _completedExamTaskIndexes = <int>{};
  final Map<int, String> _examTaskOutputs = <int, String>{};
  final Map<int, bool> _examTaskSubmitted = <int, bool>{};
  late final List<TextEditingController> _examCodeControllers;

  static const List<_MockExamTask> _mockExamTasks = <_MockExamTask>[
    _MockExamTask(
      title: 'Задание 1: Приветствие',
      description:
          'Напишите программу на Java, которая выводит "Привет, мир!" на экран.',
      expectedOutput: 'Привет, мир!',
      starterCode:
          'public class Main {\n    public static void main(String[] args) {\n        \n    }\n}',
    ),
    _MockExamTask(
      title: 'Задание 2: Сумма чисел',
      description:
          'Напишите программу, которая объявляет две переменные a = 5 и b = 3, вычисляет их сумму и выводит результат в формате: "Сумма: 8"',
      expectedOutput: 'Сумма: 8',
      starterCode:
          'public class Main {\n    public static void main(String[] args) {\n        int a = 5;\n        int b = 3;\n        \n    }\n}',
    ),
    _MockExamTask(
      title: 'Задание 3: Четное или нечетное',
      description:
          'Напишите программу с переменной number = 7. Проверьте, является ли число четным или нечетным, и выведите "Число 7 - нечетное".',
      expectedOutput: 'Число 7 - нечетное',
      starterCode:
          'public class Main {\n    public static void main(String[] args) {\n        int number = 7;\n        \n    }\n}',
    ),
    _MockExamTask(
      title: 'Задание 4: Цикл for',
      description:
          'Напишите программу, которая выводит числа от 1 до 5 через пробел в одной строке. Ожидаемый вывод: "1 2 3 4 5"',
      expectedOutput: '1 2 3 4 5',
      starterCode:
          'public class Main {\n    public static void main(String[] args) {\n        \n    }\n}',
    ),
    _MockExamTask(
      title: 'Задание 5: Массив и сумма',
      description:
          'Напишите программу, которая создает массив {10, 20, 30, 40, 50}, вычисляет сумму его элементов и выводит: "Сумма элементов: 150"',
      expectedOutput: 'Сумма элементов: 150',
      starterCode:
          'public class Main {\n    public static void main(String[] args) {\n        int[] numbers = {10, 20, 30, 40, 50};\n        \n    }\n}',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _examCodeControllers = List<TextEditingController>.generate(
      _mockExamTasks.length,
      (index) => TextEditingController(text: _mockExamTasks[index].starterCode),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (final controller in _examCodeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _usesMockExam => widget.practiceId == kMockJavaExamPracticeId;

  PracticeTask _resolvePractice(
    PracticeTask mockPractice,
    BackendPracticeDto? backendPractice,
  ) {
    if (backendPractice == null) {
      return mockPractice;
    }

    return mergePracticeWithBackend(
      mockPractice: mockPractice,
      backendPractice: backendPractice,
      localeCode: ref.read(backendCourseLocaleCodeProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_usesMockExam) {
      return _buildMockExamPage(context);
    }

    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final mockPractice = catalog.practiceById(widget.practiceId);
    final backendPracticeById = ref.watch(
      backendPracticeByIdProvider(widget.practiceId),
    );
    var resolvedBackendPractice = backendPracticeById.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    if (resolvedBackendPractice == null) {
      final backendPracticeByLesson = ref.watch(
        backendPracticeByLessonIdProvider(widget.practiceId),
      );
      resolvedBackendPractice = backendPracticeByLesson.maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
    }
    final practice = _resolvePractice(mockPractice, resolvedBackendPractice);
    final completed = state.completedPracticeIds.contains(practice.id);
    final colors = context.appColors;
    final locale = state.locale;
    final challenge = practice.codeChallenge;

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
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  practice.brief.resolve(locale),
                  style: TextStyle(color: colors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (challenge != null) ...[
            Text(
              challenge.title.resolve(locale),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              challenge.instructions.resolve(locale),
              style: TextStyle(color: colors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Text(
              'Interactive code lab',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete the starter code, run a draft, then submit your solution.',
              style: TextStyle(color: colors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 16),
          ],
          PremiumCodeEditor(
            key: ValueKey<String>('${practice.id}:${practice.starterCode}'),
            initialCode: _editorCode.isEmpty
                ? practice.starterCode
                : _editorCode,
            onCodeChanged: (code) => _editorCode = code,
            onResult: (CodeExecutionResult result) {
              _applyDraftOutput(practice, result);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: 'Run draft',
                  icon: Icons.play_arrow_rounded,
                  onPressed: completed
                      ? null
                      : () => _runDraft(practice, locale),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.primary(
                  label: 'Submit',
                  icon: Icons.send_rounded,
                  onPressed: completed
                      ? null
                      : () => _runDraft(practice, locale),
                ),
              ),
            ],
          ),
          if (_draftOutput != null) ...[
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
                  Text(
                    'Draft console',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _draftOutput!,
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
          const SizedBox(height: 18),
          Text(
            'Knowledge checks',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(practice.knowledgeChecks.length, (index) {
            final check = practice.knowledgeChecks[index];
            final selected = _selectedKnowledgeChecks.contains(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: completed
                    ? null
                    : () {
                        setState(() {
                          if (selected) {
                            _selectedKnowledgeChecks.remove(index);
                          } else {
                            _selectedKnowledgeChecks.add(index);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.accent.withValues(alpha: 0.12)
                        : colors.surfaceSoft.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? colors.accent : colors.divider,
                    ),
                  ),
                  child: Text(
                    check.resolve(locale),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          if (practice.successCriteria.isNotEmpty) ...[
            Text(
              'Success criteria',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...practice.successCriteria.map(
              (criterion) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: colors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        criterion.resolve(locale),
                        style: TextStyle(
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          AppButton.primary(
            label: completed ? 'Submitted' : 'Submit for review',
            icon: completed
                ? Icons.check_circle_rounded
                : Icons.verified_rounded,
            onPressed: completed
                ? null
                : () => _submitPractice(
                    practice,
                    locale,
                    resolvedBackendPractice,
                  ),
          ),
          if (completed) ...[
            const SizedBox(height: 12),
            Text(
              challenge?.successMessage.resolve(locale) ??
                  '+${practice.xpReward} XP earned.',
              style: TextStyle(
                color: colors.success,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Comments', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...practice.comments.map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
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
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment.message.resolve(locale),
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ..._userComments.map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceSoft.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.divider),
                ),
                child: Text(
                  comment,
                  style: TextStyle(color: colors.textSecondary, height: 1.35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('practice_comment_field'),
            controller: _commentController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share a note about this practice...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          AppButton.secondary(
            label: 'Send comment',
            icon: Icons.send_rounded,
            onPressed: () {
              final message = _commentController.text.trim();
              if (message.isEmpty) {
                return;
              }
              setState(() {
                _userComments.add(message);
                _commentController.clear();
              });
            },
          ),
          const SizedBox(height: 16),
          AppButton.secondary(
            label: 'Ask AI',
            icon: Icons.smart_toy_rounded,
            onPressed: () {
              ref
                  .read(aiChatControllerProvider.notifier)
                  .createNewChat(practice.title.resolve(locale));
              context.go(AppRoutes.ai);
              unawaited(
                ref
                    .read(aiChatControllerProvider.notifier)
                    .sendMessage(practice.promptSuggestion.resolve(locale)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _runDraft(PracticeTask practice, AppLocale locale) {
    final code = _editorCode.isEmpty ? practice.starterCode : _editorCode;
    final challenge = practice.codeChallenge;
    final normalizedCode = code.toLowerCase();

    if (challenge != null) {
      final hasStructure = challenge.requiredSnippets.every(
        (snippet) => normalizedCode.contains(snippet.toLowerCase()),
      );
      setState(() {
        _draftOutput = hasStructure
            ? challenge.expectedOutput
            : 'Draft console is empty. Add the missing class structure and run again.';
      });
      return;
    }

    setState(() {
      _draftOutput = code.trim().isEmpty
          ? 'Draft console is empty.'
          : 'Draft ready for review.';
    });
  }

  void _applyDraftOutput(PracticeTask practice, CodeExecutionResult result) {
    final output = [
      if (result.stdout.trim().isNotEmpty) result.stdout.trim(),
      if (result.stderr.trim().isNotEmpty) result.stderr.trim(),
      if (result.error.trim().isNotEmpty) result.error.trim(),
    ].join('\n');

    final challenge = practice.codeChallenge;
    final code = _editorCode.isEmpty ? practice.starterCode : _editorCode;
    final normalizedCode = code.toLowerCase();
    final simulatedOutput =
        challenge != null &&
            challenge.requiredSnippets.every(
              (snippet) => normalizedCode.contains(snippet.toLowerCase()),
            )
        ? challenge.expectedOutput
        : null;

    setState(() {
      _draftOutput =
          simulatedOutput ??
          (output.isEmpty
              ? 'Draft console is empty. Add a print statement and run again.'
              : output);
    });
  }

  Future<void> _submitPractice(
    PracticeTask practice,
    AppLocale locale,
    BackendPracticeDto? backendPractice,
  ) async {
    final code = _editorCode.isEmpty ? practice.starterCode : _editorCode;
    final challenge = practice.codeChallenge;
    final normalizedCode = code.toLowerCase();

    if (challenge != null) {
      final missingSnippets = challenge.requiredSnippets
          .where((snippet) => !normalizedCode.contains(snippet.toLowerCase()))
          .toList(growable: false);

      if (missingSnippets.isNotEmpty) {
        AppNotice.show(
          context,
          message: challenge.retryMessage.resolve(locale),
          type: AppNoticeType.error,
        );
        return;
      }

      final draftMatches = (_draftOutput ?? '').toLowerCase().contains(
        challenge.expectedOutput.toLowerCase(),
      );
      if (!draftMatches) {
        AppNotice.show(
          context,
          message: challenge.retryMessage.resolve(locale),
          type: AppNoticeType.error,
        );
        return;
      }
    }

    if (_selectedKnowledgeChecks.length < practice.knowledgeChecks.length) {
      AppNotice.show(
        context,
        message: 'Answer all knowledge checks before submitting.',
        type: AppNoticeType.error,
      );
      return;
    }

    ref.read(demoAppControllerProvider.notifier).completePractice(practice.id);

    final accessToken = ref.read(backendCourseAccessTokenProvider)?.trim();
    final userId = ref
        .read(authControllerProvider.select((state) => state.session?.user.id))
        ?.trim();
    final lessonId = backendPractice?.lessonId.trim();

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        userId != null &&
        _looksLikeUuid(userId) &&
        lessonId != null &&
        _looksLikeUuid(lessonId)) {
      try {
        final remote = ref.read(backendCourseRemoteDataSourceProvider);
        await remote.createCoursePoint(
          accessToken: accessToken,
          body: <String, dynamic>{
            'lesson_id': lessonId,
            'user_id': userId,
            'xp': practice.xpReward,
          },
        );
      } catch (_) {
        // Backend unavailable — silently continue
      }
    }

    ref.invalidate(backendStreakProvider);

    if (!mounted) {
      return;
    }

    AppNotice.show(
      context,
      message:
          challenge?.successMessage.resolve(locale) ??
          '+${practice.xpReward} XP',
      type: AppNoticeType.success,
    );
  }

  Widget _buildMockExamPage(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final practice = catalog.practiceById(widget.practiceId);
    final completed = state.completedPracticeIds.contains(widget.practiceId);
    final colors = context.appColors;
    final locale = state.locale;
    final allTasksComplete =
        _completedExamTaskIndexes.length == _mockExamTasks.length;

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
                Row(
                  children: [
                    Icon(
                      Icons.assignment_rounded,
                      color: colors.accent,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Экзамен (mock)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Всего заданий: ${_mockExamTasks.length} | Выполнено: ${_completedExamTaskIndexes.length}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildExamTaskCard(
            _mockExamTasks[_currentExamTaskIndex],
            _currentExamTaskIndex,
            colors,
          ),
          const SizedBox(height: 16),
          if (allTasksComplete && !completed)
            AppButton.primary(
              label: 'Завершить экзамен',
              icon: Icons.celebration_rounded,
              onPressed: () {
                controller.completePractice(widget.practiceId);
                AppNotice.show(
                  context,
                  message: '+${practice.xpReward} XP - Экзамен сдан!',
                  type: AppNoticeType.success,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExamTaskCard(
    _MockExamTask task,
    int index,
    AppThemeColors colors,
  ) {
    final codeController = _examCodeControllers[index];
    final isCompleted = _completedExamTaskIndexes.contains(index);
    final taskOutput = _examTaskOutputs[index];

    return GlowCard(
      accent: isCompleted ? colors.success : colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            task.description,
            style: TextStyle(color: colors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          PremiumCodeEditor(
            key: ValueKey<String>('exam-$index'),
            initialCode: codeController.text,
            onCodeChanged: (code) => codeController.text = code,
            onResult: (CodeExecutionResult result) {
              setState(() {
                _examTaskOutputs[index] = result.stdout.trim().isEmpty
                    ? result.stderr
                    : result.stdout;
              });
            },
          ),
          if (taskOutput != null) ...[
            const SizedBox(height: 12),
            SelectableText(
              taskOutput,
              style: TextStyle(
                color: colors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ],
          const SizedBox(height: 12),
          AppButton.primary(
            label: isCompleted ? 'Отправлено' : 'Submit',
            icon: Icons.verified_rounded,
            onPressed: isCompleted
                ? null
                : () {
                    final code = codeController.text.toLowerCase();
                    if (code.contains(task.expectedOutput.toLowerCase())) {
                      setState(() {
                        _completedExamTaskIndexes.add(index);
                        _examTaskSubmitted[index] = true;
                      });
                    } else {
                      AppNotice.show(
                        context,
                        message: 'Проверьте код и попробуйте снова',
                        type: AppNoticeType.error,
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _MockExamTask {
  const _MockExamTask({
    required this.title,
    required this.description,
    required this.expectedOutput,
    required this.starterCode,
  });

  final String title;
  final String description;
  final String expectedOutput;
  final String starterCode;
}
