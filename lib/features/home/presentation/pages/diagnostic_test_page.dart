import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/bubble_progress_bar.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/data/models/backend_diagnostic_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';

/// Maps each diagnostic sphere to the knowledge-tree tracks it recommends.
/// Recommendations and the tree "Recommended" badges are both driven from here,
/// so they always point at real nodes that exist in the knowledge tree.
const Map<String, List<String>> kSphereToTrackIds = <String, List<String>>{
  'backend': ['backend'],
  'algorithms': ['algorithms_data_structures'],
  'oop': ['oop'],
  'databases': ['databases'],
  'data_ai': ['machine_learning', 'ai_theory', 'probability_statistics_analytics'],
  'devops': ['sre_devops', 'system_administration'],
  'security': ['cybersecurity', 'information_security_foundations'],
  'systems': ['operating_systems', 'computer_architecture', 'networking_protocols'],
};

/// Strongest spheres (score > 0) → recommended knowledge-tree track ids.
/// Takes the top [maxSpheres] spheres and their mapped tracks, capped at [cap].
Set<String> recommendedTrackIdsForResult(
  DiagnosticResultDto result, {
  int maxSpheres = 3,
  int cap = 5,
}) {
  final topSlugs = result.spheresByStrength
      .where((s) => s.score > 0)
      .map((s) => s.sphere.slug)
      .take(maxSpheres)
      .toList(growable: false);
  final ids = <String>{};
  for (final slug in topSlugs) {
    for (final id in kSphereToTrackIds[slug] ?? const <String>[]) {
      if (ids.length >= cap) break;
      ids.add(id);
    }
  }
  return ids;
}

/// First-time diagnostic test.
///
/// Loads its questions from the backend (`/student/diagnostic/test`), never
/// reveals which answers are right or wrong, scores entirely on the server
/// and shows a colourful per-sphere breakdown plus recommended courses.
class DiagnosticTestPage extends ConsumerStatefulWidget {
  const DiagnosticTestPage({super.key});

  @override
  ConsumerState<DiagnosticTestPage> createState() => _DiagnosticTestPageState();
}

class _DiagnosticTestPageState extends ConsumerState<DiagnosticTestPage> {
  AppLocale? _overrideLocale;

  int _currentIndex = 0;
  // questionId -> selected option ids
  final Map<String, Set<String>> _answers = <String, Set<String>>{};

  bool _isSubmitting = false;
  String? _submitError;
  DiagnosticResultDto? _result;

  String _t(AppLocale l, String ru, String en, String kk) => switch (l) {
    AppLocale.ru => ru,
    AppLocale.kk => kk,
    AppLocale.en => en,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final riverpodLocale = ref.watch(
      demoAppControllerProvider.select((s) => s.locale),
    );
    final locale = _overrideLocale ?? riverpodLocale;
    final testAsync = ref.watch(backendDiagnosticTestProvider);

    return AppPageScaffold(
      title: _t(
        locale,
        'Диагностический тест',
        'Diagnostic Test',
        'Диагностикалық тест',
      ),
      actions: [_buildLanguageSwitcher(colors, locale)],
      child: testAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _buildLoadError(colors, locale),
        data: (test) {
          if (test == null || test.questions.isEmpty) {
            return _buildLoadError(colors, locale);
          }
          if (_result != null) {
            return _ResultView(
              result: _result!,
              locale: locale,
              colors: colors,
              onRetake: _retake,
            );
          }
          return _buildQuestionFlow(context, test, colors, locale);
        },
      ),
    );
  }

  // ── Question flow ──────────────────────────────────────────────────────────

  Widget _buildQuestionFlow(
    BuildContext context,
    DiagnosticTestDto test,
    AppThemeColors colors,
    AppLocale locale,
  ) {
    final question = test.questions[_currentIndex];
    final total = test.questions.length;
    final isLast = _currentIndex == total - 1;
    final selected = _answers[question.id] ?? const <String>{};
    final canProceed = selected.isNotEmpty && !_isSubmitting;
    final sphere = _sphereFor(test, question.sphereSlug);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: BubbleProgressBar(
                      value: (_currentIndex + 1) / total,
                      height: 8,
                      backgroundColor: colors.surfaceSoft,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${_currentIndex + 1} / $total',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.surface, colors.surfaceSoft],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.surfaceSoft, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (sphere != null) _sphereTag(sphere, locale),
                    if (sphere != null) const SizedBox(height: 16),
                    Text(
                      question.prompt.resolve(locale),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    if (question.isMultipleChoice) ...[
                      const SizedBox(height: 8),
                      Text(
                        _t(
                          locale,
                          '💡 Можно выбрать несколько вариантов',
                          '💡 You can select several options',
                          '💡 Бірнеше нұсқаны таңдауға болады',
                        ),
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    ...question.options.map(
                      (option) => _buildOption(
                        question,
                        option,
                        selected.contains(option.id),
                        colors,
                        locale,
                      ),
                    ),
                  ],
                ),
              ),
              if (_submitError != null) ...[
                const SizedBox(height: 14),
                _buildInlineError(_submitError!, colors),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  if (_currentIndex > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(() => _currentIndex--),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: BorderSide(color: colors.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _t(locale, 'Назад', 'Back', 'Артқа'),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: canProceed
                          ? () => _onProceed(test, isLast)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: colors.surfaceSoft,
                        disabledForegroundColor: colors.textSecondary.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isLast
                                  ? _t(
                                      locale,
                                      'Завершить',
                                      'Finish',
                                      'Аяқтау',
                                    )
                                  : _t(locale, 'Далее', 'Next', 'Келесі'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    DiagnosticQuestionDto question,
    DiagnosticOptionDto option,
    bool isSelected,
    AppThemeColors colors,
    AppLocale locale,
  ) {
    final isMultiple = question.isMultipleChoice;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _isSubmitting ? null : () => _toggleOption(question, option.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.primary : colors.surfaceSoft,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: isMultiple ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isMultiple ? BorderRadius.circular(5) : null,
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.textSecondary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  color: isSelected ? colors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        isMultiple
                            ? Icons.check_rounded
                            : Icons.fiber_manual_record_rounded,
                        size: isMultiple ? 15 : 11,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.label.resolve(locale),
                  style: TextStyle(
                    color: colors.textPrimary.withValues(
                      alpha: isSelected ? 1 : 0.85,
                    ),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sphereTag(DiagnosticSphereDto sphere, AppLocale locale) {
    final accent = _hexColor(sphere.accentColor, Colors.blue);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_sphereIcon(sphere.icon), size: 15, color: accent),
            const SizedBox(width: 7),
            Text(
              sphere.name.resolve(locale),
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleOption(DiagnosticQuestionDto question, String optionId) {
    final set = _answers.putIfAbsent(question.id, () => <String>{});
    setState(() {
      _submitError = null;
      if (question.isMultipleChoice) {
        if (!set.remove(optionId)) {
          set.add(optionId);
        }
      } else {
        set
          ..clear()
          ..add(optionId);
      }
    });
  }

  Future<void> _onProceed(DiagnosticTestDto test, bool isLast) async {
    if (!isLast) {
      setState(() => _currentIndex++);
      return;
    }
    await _submit(test);
  }

  Future<void> _submit(DiagnosticTestDto test) async {
    final accessToken = ref.read(backendCourseAccessTokenProvider)?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        _submitError = 'auth';
      });
      return;
    }

    final answers = test.questions
        .map(
          (q) => DiagnosticAnswerInput(
            questionId: q.id,
            selectedOptionIds: (_answers[q.id] ?? const <String>{}).toList(),
          ),
        )
        .toList(growable: false);

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      final result = await remote.submitDiagnosticResult(
        accessToken: accessToken,
        answers: answers,
      );
      // Drive XP + knowledge-tree recommendations from the sphere result.
      ref
          .read(demoAppControllerProvider.notifier)
          .completeDiagnostics(
            score: result.correctCount,
            recommendedTrackIds: recommendedTrackIdsForResult(result),
          );
      ref.invalidate(backendMyDiagnosticResultProvider);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = 'submit';
      });
    }
  }

  void _retake() {
    setState(() {
      _result = null;
      _currentIndex = 0;
      _answers.clear();
      _submitError = null;
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  DiagnosticSphereDto? _sphereFor(DiagnosticTestDto test, String slug) {
    for (final s in test.spheres) {
      if (s.slug == slug) return s;
    }
    return null;
  }

  Widget _buildInlineError(String kind, AppThemeColors colors) {
    final locale = _overrideLocale ?? ref.read(demoAppControllerProvider).locale;
    final message = kind == 'auth'
        ? _t(
            locale,
            'Войдите в аккаунт, чтобы сохранить результат.',
            'Sign in to save your result.',
            'Нәтижені сақтау үшін аккаунтқа кіріңіз.',
          )
        : _t(
            locale,
            'Не удалось отправить ответы. Проверьте соединение и попробуйте снова.',
            'Could not submit your answers. Check your connection and try again.',
            'Жауаптарды жіберу мүмкін болмады. Байланысты тексеріп, қайталаңыз.',
          );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadError(AppThemeColors colors, AppLocale locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _t(
                locale,
                'Не удалось загрузить тест',
                'Could not load the test',
                'Тестті жүктеу мүмкін болмады',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t(
                locale,
                'Проверьте подключение к интернету и попробуйте снова.',
                'Check your internet connection and try again.',
                'Интернет байланысын тексеріп, қайталап көріңіз.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(backendDiagnosticTestProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_t(locale, 'Повторить', 'Retry', 'Қайталау')),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(AppThemeColors colors, AppLocale activeLocale) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: PopupMenuButton<AppLocale>(
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colors.surfaceSoft,
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language_rounded, color: colors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                activeLocale.label,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: colors.primary,
                size: 16,
              ),
            ],
          ),
        ),
        onSelected: (locale) => setState(() => _overrideLocale = locale),
        itemBuilder: (context) => const [
          PopupMenuItem(value: AppLocale.ru, child: Text('Русский')),
          PopupMenuItem(value: AppLocale.kk, child: Text('Қазақша')),
          PopupMenuItem(value: AppLocale.en, child: Text('English')),
        ],
      ),
    );
  }
}

// ── Result view ────────────────────────────────────────────────────────────

class _ResultView extends ConsumerWidget {
  const _ResultView({
    required this.result,
    required this.locale,
    required this.colors,
    required this.onRetake,
  });

  final DiagnosticResultDto result;
  final AppLocale locale;
  final AppThemeColors colors;
  final VoidCallback onRetake;

  String _t(String ru, String en, String kk) => switch (locale) {
    AppLocale.ru => ru,
    AppLocale.kk => kk,
    AppLocale.en => en,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelMeta = _levelMeta(result.level);
    final strongest = result.spheresByStrength;
    final topSpheres = strongest
        .where((s) => s.score > 0)
        .take(3)
        .toList(growable: false);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLevelHero(levelMeta),
              const SizedBox(height: 22),
              if (topSpheres.isNotEmpty) ...[
                _sectionTitle(
                  _t(
                    'Ваши сильнейшие сферы',
                    'Your strongest spheres',
                    'Сіздің күшті салаларыңыз',
                  ),
                ),
                const SizedBox(height: 12),
                _buildTopSpheres(topSpheres),
                const SizedBox(height: 24),
              ],
              _sectionTitle(
                _t(
                  'Статистика по сферам',
                  'Breakdown by sphere',
                  'Салалар бойынша статистика',
                ),
              ),
              const SizedBox(height: 12),
              ...strongest.map(_buildSphereBar),
              const SizedBox(height: 24),
              _RecommendedCourses(
                result: result,
                locale: locale,
                colors: colors,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRetake,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                        _t('Пройти заново', 'Retake', 'Қайта өту'),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _t(
                          'Вернуться на главную',
                          'Back to home',
                          'Басты бетке',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelHero(_LevelMeta meta) {
    final percent = result.percent;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            meta.color.withValues(alpha: 0.22),
            meta.color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: meta.color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(meta.icon, color: meta.color, size: 40),
          ),
          const SizedBox(height: 14),
          Text(
            _t('Тест завершён', 'Test completed', 'Тест аяқталды'),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meta.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: meta.color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: meta.color.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(meta.color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _heroStat(
                '${(percent * 100).round()}%',
                _t('Общий балл', 'Overall', 'Жалпы балл'),
                meta.color,
              ),
              _heroStat(
                '${result.totalScore} / ${result.maxScore}',
                _t('Очки', 'Points', 'Ұпай'),
                colors.textPrimary,
              ),
              _heroStat(
                '${result.correctCount} / ${result.questionCount}',
                _t('Верно', 'Correct', 'Дұрыс'),
                colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            meta.hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTopSpheres(List<DiagnosticResultSphereDto> spheres) {
    return Row(
      children: [
        for (var i = 0; i < spheres.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _topSphereCard(spheres[i])),
        ],
      ],
    );
  }

  Widget _topSphereCard(DiagnosticResultSphereDto entry) {
    final accent = _hexColor(entry.sphere.accentColor, colors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(_sphereIcon(entry.sphere.icon), color: accent, size: 26),
          const SizedBox(height: 8),
          Text(
            entry.sphere.name.resolve(locale),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(entry.mastery * 100).round()}%',
            style: TextStyle(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSphereBar(DiagnosticResultSphereDto entry) {
    final accent = _hexColor(entry.sphere.accentColor, colors.primary);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_sphereIcon(entry.sphere.icon), size: 16, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.sphere.name.resolve(locale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.score} / ${entry.maxScore}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(entry.mastery * 100).round()}%',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: entry.mastery,
              minHeight: 8,
              backgroundColor: accent.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  _LevelMeta _levelMeta(String level) {
    return switch (level) {
      'advanced' => _LevelMeta(
        label: _t(
          'Продвинутый уровень',
          'Advanced level',
          'Жоғары деңгей',
        ),
        hint: _t(
          'Отличный результат! Сфокусируйтесь на углублённых темах и проектах в сильных сферах.',
          'Great result! Focus on advanced topics and projects in your strong spheres.',
          'Тамаша нәтиже! Күшті салаларда тереңдетілген тақырыптар мен жобаларға назар аударыңыз.',
        ),
        color: const Color(0xFF22C55E),
        icon: Icons.emoji_events_rounded,
      ),
      'intermediate' => _LevelMeta(
        label: _t(
          'Средний уровень',
          'Intermediate level',
          'Орташа деңгей',
        ),
        hint: _t(
          'Хорошая база! Подтяните слабые сферы и переходите к практическим курсам.',
          'Solid base! Strengthen weaker spheres and move to hands-on courses.',
          'Жақсы негіз! Әлсіз салаларды күшейтіп, тәжірибелік курстарға көшіңіз.',
        ),
        color: const Color(0xFF6C8CFF),
        icon: Icons.trending_up_rounded,
      ),
      _ => _LevelMeta(
        label: _t(
          'Начальный уровень',
          'Beginner level',
          'Бастапқы деңгей',
        ),
        hint: _t(
          'Отличный старт! Начните с рекомендованных курсов по вашим интересам.',
          'Great start! Begin with the recommended courses for your interests.',
          'Тамаша бастама! Қызығушылығыңызға сай ұсынылған курстардан бастаңыз.',
        ),
        color: const Color(0xFFF59E0B),
        icon: Icons.rocket_launch_rounded,
      ),
    };
  }
}

// ── Recommended courses ──────────────────────────────────────────────────────

class _RecommendedCourses extends ConsumerWidget {
  const _RecommendedCourses({
    required this.result,
    required this.locale,
    required this.colors,
  });

  final DiagnosticResultDto result;
  final AppLocale locale;
  final AppThemeColors colors;

  String _t(String ru, String en, String kk) => switch (locale) {
    AppLocale.ru => ru,
    AppLocale.kk => kk,
    AppLocale.en => en,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(demoCatalogProvider);
    final tracks = _pickTracks(catalog);
    if (tracks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t(
            'Рекомендуем из дерева знаний',
            'Recommended from your knowledge tree',
            'Білім ағашынан ұсынамыз',
          ),
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _t(
            'Эти ветки дерева подсвечены под ваши сильнейшие сферы',
            'These tree branches are highlighted for your strongest spheres',
            'Бұл тармақтар сіздің күшті салаларыңызға қарай белгіленді',
          ),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...tracks.map((track) => _trackCard(context, track)),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => context.go(AppRoutes.tree),
          icon: const Icon(Icons.account_tree_rounded, size: 18),
          label: Text(
            _t(
              'Открыть дерево знаний',
              'Open the knowledge tree',
              'Білім ағашын ашу',
            ),
          ),
          style: TextButton.styleFrom(foregroundColor: colors.accent),
        ),
      ],
    );
  }

  /// Resolves recommended track ids (strongest spheres → tree tracks) into real
  /// [LearningTrack]s from the catalog, preserving the recommendation order.
  List<LearningTrack> _pickTracks(DemoCatalog catalog) {
    final ids = recommendedTrackIdsForResult(result);
    final byId = <String, LearningTrack>{
      for (final track in catalog.tracks) track.id: track,
    };
    final picked = <LearningTrack>[];
    for (final id in ids) {
      final track = byId[id];
      if (track != null) picked.add(track);
    }
    return picked;
  }

  Widget _trackCard(BuildContext context, LearningTrack track) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push(AppRoutes.trackById(track.id)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceSoft.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: track.color.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: track.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(track.icon, color: track.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title.resolve(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      track.subtitle.resolve(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────────────────

class _LevelMeta {
  const _LevelMeta({
    required this.label,
    required this.hint,
    required this.color,
    required this.icon,
  });

  final String label;
  final String hint;
  final Color color;
  final IconData icon;
}

Color _hexColor(String hex, Color fallback) {
  var h = hex.trim().replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? fallback : Color(value);
}

IconData _sphereIcon(String key) => switch (key) {
  'dns' => Icons.dns_rounded,
  'account_tree' => Icons.account_tree_rounded,
  'category' => Icons.category_rounded,
  'storage' => Icons.storage_rounded,
  'psychology' => Icons.psychology_rounded,
  'cloud' => Icons.cloud_rounded,
  'shield' => Icons.shield_rounded,
  'memory' => Icons.memory_rounded,
  _ => Icons.bubble_chart_rounded,
};
