import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/bubble_progress_bar.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/data/models/backend_student_statistics_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final backendStreak = ref
        .watch(backendStreakProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final catalog = ref.watch(demoCatalogProvider);
    final colors = context.appColors;
    final locale = state.locale;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;

    String t({required String ru, required String en, required String kk}) {
      if (locale == AppLocale.kk) return kk;
      if (locale == AppLocale.ru) return ru;
      return en;
    }

    final backendProfile = ref
        .watch(backendProfileProvider)
        .maybeWhen(data: (p) => p, orElse: () => null);
    final backendAchievements = ref
        .watch(backendAchievementsProvider)
        .maybeWhen(data: (list) => list, orElse: () => const <Achievement>[]);
    final backendStats = ref
        .watch(backendStudentStatisticsProvider)
        .maybeWhen(data: (s) => s, orElse: () => null);

    final achievementList = backendAchievements.isNotEmpty
        ? backendAchievements
        : catalog.achievementsFor(state);
    final unlockedAchievements =
        achievementList.where((a) => a.unlocked).length;

    final passedAssessments = catalog.passedAssessments(state);
    final aiSessions =
        state.aiMessages.where((m) => m.author == AiAuthor.user).length;

    final aiQueries =
        state.aiMessages.where((m) => m.author == AiAuthor.user).length;

    final quizPercentVal =
        (state.quizAccuracy * 100).round().clamp(0, 100);
    final liveXpVal = backendProfile?.xp ?? state.xp;
    final aiTopicsVal = aiQueries;
    final streakDaysVal =
        backendProfile?.streak ?? backendStreak?.streak ?? state.streak;

    final double completionRatio =
        catalog.totalCompletedUnits(state) / math.max(1, catalog.totalUnits());
    final double xpRatio = (liveXpVal / 5000.0).clamp(0.0, 1.0);
    final double accuracyRatio = state.quizAccuracy.clamp(0.0, 1.0);
    final double masteryValue =
        (accuracyRatio * 0.4 + completionRatio * 0.3 + xpRatio * 0.3)
            .clamp(0.0, 0.99);

    final Widget kpiQuiz = _KPICard(
      title: t(ru: 'Код с первой попытки', en: 'Code on 1st Attempt', kk: 'Бірінші әрекеттен код'),
      value: '$quizPercentVal%',
      topIcon: Icons.check_circle_rounded,
      accentColor: colors.success,
      tooltipText: t(
        ru: 'Процент квизов и тестов, решенных правильно с первого раза.',
        en: 'Percentage of quizzes and tests solved correctly on the first attempt.',
        kk: 'Бірінші әрекеттен дұрыс шешілген квиздер мен тесттердің пайызы.',
      ),
    );
    final Widget kpiAi = _KPICard(
      title: t(ru: 'Разобранные темы с ИИ', en: 'AI Topics Cleared', kk: 'ИИ-мен талданған тақырыптар'),
      value: '$aiTopicsVal',
      topIcon: Icons.psychology_rounded,
      accentColor: colors.accent,
      tooltipText: t(
        ru: 'Количество тем и вопросов, изученных совместно с ИИ-ментором.',
        en: 'Number of topics and questions studied with the AI Mentor.',
        kk: 'ИИ-ментормен бірге зерттелген тақырыптар мен сұрақтар саны.',
      ),
    );
    final Widget kpiXp = _KPICard(
      title: t(ru: 'Скорость усвоения (XP)', en: 'Learning Speed (XP)', kk: 'Меңгеру жылдамдығы (XP)'),
      value: '$liveXpVal XP',
      topIcon: Icons.bolt_rounded,
      accentColor: colors.primary,
      tooltipText: t(
        ru: 'Набранные очки опыта (XP) за всё время обучения.',
        en: 'Experience points (XP) earned over the entire learning journey.',
        kk: 'Барлық оқу уақытында жиналған тәжірибе ұпайлары (XP).',
      ),
    );
    final Widget kpiMastery = _MasteryIndexCard(t: t, colors: colors, value: masteryValue);

    return AppPageScaffold(
      title: context.l10n.text('stats'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        children: [
          // Summary metrics carousel
          GlowCard(
            accent: colors.primary,
            child: _MetricsCarousel(
              t: t,
              xp: '${backendStats?.summary.totalXp ?? liveXpVal}',
              level: '${backendStats?.summary.level ?? backendProfile?.level ?? state.level}',
              xpToNextLevel: '${200 - (backendStats?.summary.totalXp ?? liveXpVal) % 200} XP',
              streak: '${backendStats?.summary.currentStreak ?? streakDaysVal}d',
              completedUnits:
                  '${backendStats?.summary.completedLessons ?? catalog.totalCompletedUnits(state)}'
                  '/${backendStats?.summary.totalLessons ?? catalog.totalUnits()}',
              unlockedAchievements: '${backendStats?.summary.achievements ?? unlockedAchievements}',
              passedAssessments: '$passedAssessments/${state.assessmentResultsByTrackId.length}',
              aiSessions: '$aiSessions',
            ),
          ),
          const SizedBox(height: 16),

          // Level progress
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(ru: 'Прогресс уровня', en: 'Level Progress', kk: 'Деңгей прогресі'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                () {
                  final xp = backendStats?.summary.totalXp ?? liveXpVal;
                  return Text(
                    '${xp % 200}/200 XP',
                    style: TextStyle(color: colors.textSecondary, height: 1.4),
                  );
                }(),
                const SizedBox(height: 14),
                () {
                  final xp = backendStats?.summary.totalXp ?? liveXpVal;
                  return BubbleProgressBar(
                    value: (xp % 200) / 200.0,
                    color: colors.primary,
                    backgroundColor: colors.backgroundElevated,
                    bubbleText: '${xp % 200}/200 XP',
                  );
                }(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // KPI cards – responsive grid
          if (isDesktop) ...[
            Row(
              children: [
                Expanded(child: SizedBox(height: 210, child: kpiQuiz)),
                const SizedBox(width: 16),
                Expanded(child: SizedBox(height: 210, child: kpiAi)),
                const SizedBox(width: 16),
                Expanded(child: SizedBox(height: 210, child: kpiXp)),
                const SizedBox(width: 16),
                Expanded(child: SizedBox(height: 210, child: kpiMastery)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: _StreakCard(t: t, colors: colors, streakVal: streakDaysVal),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: _LearningTimeCard(t: t, colors: colors),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: _FavoriteTopicsCard(t: t, colors: colors),
                  ),
                ),
              ],
            ),
          ] else if (isTablet) ...[
            Row(
              children: [
                Expanded(child: SizedBox(height: 200, child: kpiQuiz)),
                const SizedBox(width: 16),
                Expanded(child: SizedBox(height: 200, child: kpiAi)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: SizedBox(height: 200, child: kpiXp)),
                const SizedBox(width: 16),
                Expanded(child: SizedBox(height: 200, child: kpiMastery)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: _StreakCard(t: t, colors: colors, streakVal: streakDaysVal),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: _LearningTimeCard(t: t, colors: colors),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 180, child: _FavoriteTopicsCard(t: t, colors: colors)),
          ] else ...[
            SizedBox(height: 200, child: kpiQuiz),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: kpiAi),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: kpiXp),
            const SizedBox(height: 16),
            SizedBox(height: 220, child: kpiMastery),
            const SizedBox(height: 16),
            _StreakCard(t: t, colors: colors, streakVal: streakDaysVal),
            const SizedBox(height: 16),
            _LearningTimeCard(t: t, colors: colors),
            const SizedBox(height: 16),
            SizedBox(height: 180, child: _FavoriteTopicsCard(t: t, colors: colors)),
          ],
          const SizedBox(height: 16),

          // Backend statistics
          if (backendStats == null)
            GlowCard(
              accent: colors.primary,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: colors.primary),
                      const SizedBox(height: 12),
                      Text(
                        t(
                          ru: 'Загружаем статистику…',
                          en: 'Loading statistics…',
                          kk: 'Статистика жүктелуде…',
                        ),
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            _BackendLearningSignals(stats: backendStats, colors: colors, t: t),
            if (backendStats.activity.any((d) => d.xp > 0)) ...[
              const SizedBox(height: 16),
              _BackendActivityChart(activity: backendStats.activity, colors: colors, t: t),
            ],
            if (backendStats.topics.isNotEmpty) ...[
              const SizedBox(height: 16),
              _BackendTopicsProgress(topics: backendStats.topics, colors: colors, t: t),
            ],
            if (backendStats.courseProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              _BackendCourseProgress(courses: backendStats.courseProgress, colors: colors, t: t),
            ],
          ],
        ],
      ),
    );
  }
}

// ------------------- SUB COMPONENTS -------------------

// Metrics Carousel for detailed tab
class _MetricsCarousel extends StatefulWidget {
  const _MetricsCarousel({
    required this.t,
    required this.xp,
    required this.level,
    required this.xpToNextLevel,
    required this.streak,
    required this.completedUnits,
    required this.unlockedAchievements,
    required this.passedAssessments,
    required this.aiSessions,
  });

  final String Function({required String ru, required String en, required String kk}) t;
  final String xp;
  final String level;
  final String xpToNextLevel;
  final String streak;
  final String completedUnits;
  final String unlockedAchievements;
  final String passedAssessments;
  final String aiSessions;

  @override
  State<_MetricsCarousel> createState() => _MetricsCarouselState();
}

class _MetricsCarouselState extends State<_MetricsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final t = widget.t;
    final List<List<Map<String, String>>> pagesData = [
      [
        {'label': t(ru: 'XP', en: 'XP', kk: 'XP'), 'value': widget.xp},
        {'label': t(ru: 'Уровень', en: 'Level', kk: 'Деңгей'), 'value': widget.level},
      ],
      [
        {'label': t(ru: 'До уровня', en: 'To next', kk: 'Келесіге дейін'), 'value': widget.xpToNextLevel},
        {'label': t(ru: 'Серия', en: 'Streak', kk: 'Серия'), 'value': widget.streak},
      ],
      [
        {'label': t(ru: 'Модули', en: 'Units', kk: 'Модульдер'), 'value': widget.completedUnits},
        {'label': t(ru: 'Достижения', en: 'Achievements', kk: 'Жетістіктер'), 'value': widget.unlockedAchievements},
      ],
      [
        {'label': t(ru: 'Оценивания', en: 'Assessments', kk: 'Бағалаулар'), 'value': widget.passedAssessments},
        {'label': t(ru: 'Сессии с ИИ', en: 'AI sessions', kk: 'ИИ-мен сессиялар'), 'value': widget.aiSessions},
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left_rounded, color: colors.textSecondary),
              onPressed: _currentPage > 0
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
            ),
            Expanded(
              child: SizedBox(
                height: 110,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: pagesData.length,
                  itemBuilder: (context, index) {
                    final pair = pagesData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: pair[0]['label']!,
                              value: pair[0]['value']!,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricTile(
                              label: pair[1]['label']!,
                              value: pair[1]['value']!,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
              onPressed: _currentPage < pagesData.length - 1
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pagesData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 16 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? colors.primary : colors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.width,
  });

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.backgroundElevated.withValues(alpha: 0.5),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Breakdown row for original progress tab

// KPI Card reusable shell with interactive Tooltip description
class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData topIcon;
  final Color accentColor;
  final String tooltipText;

  const _KPICard({
    required this.title,
    required this.value,
    required this.topIcon,
    required this.accentColor,
    required this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surface.withValues(alpha: 0.6),
        border: Border.all(color: colors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: tooltipText,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: colors.backgroundElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.divider, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 4),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: colors.textSecondary.withValues(alpha: 0.4),
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  topIcon,
                  color: accentColor,
                  size: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// Mastery Index Composite Card (replaces percentile)
class _MasteryIndexCard extends StatelessWidget {
  final String Function({required String ru, required String en, required String kk}) t;
  final AppThemeColors colors;
  final double value;

  const _MasteryIndexCard({
    required this.t,
    required this.colors,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surface.withValues(alpha: 0.6),
        border: Border.all(color: colors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t(ru: 'Индекс мастерства', en: 'Mastery Index', kk: 'Шеберлік индексі'),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: t(
                  ru: 'Комплексный показатель готовности, рассчитанный на основе точности ответов, пройденного материала и опыта.',
                  en: 'A composite indicator of readiness, calculated based on answer accuracy, completed materials, and experience.',
                  kk: 'Жауаптардың дәлдігі, өткен материал және жиналған тәжірибе негізінде есептелген сіздің дайындығыңыздың кешенді көрсеткіші.',
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: colors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.divider, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: colors.textSecondary.withValues(alpha: 0.4),
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _HalfCircleGauge(value: value),
                Positioned(
                  bottom: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        t(ru: 'готовность', en: 'readiness', kk: 'дайындық'),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Half Circle Gauge painter and wrapper
class _HalfCircleGauge extends StatelessWidget {
  final double value;

  const _HalfCircleGauge({required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth > 0 ? constraints.maxWidth : 160;
        final double maxHeightForPaint = (constraints.maxHeight - 20).clamp(30.0, 150.0);
        final double height = math.min(width * 0.46, maxHeightForPaint);
        final double adjustedWidth = height * 2.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomPaint(
              size: Size(adjustedWidth, height),
              painter: _HalfCircleGaugePainter(
                value: value,
                trackColor: colors.backgroundElevated.withValues(alpha: 0.6),
                gradientColors: [
                  const Color(0xFFFF5F38), // Glowing red/orange
                  const Color(0xFFFFC043), // Glowing Yellow
                  colors.primary,          // glowing Cyan
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.4), fontSize: 9.0, fontWeight: FontWeight.bold)),
                Text('100', style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.4), fontSize: 9.0, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HalfCircleGaugePainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final List<Color> gradientColors;

  _HalfCircleGaugePainter({
    required this.value,
    required this.trackColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = (size.width / 2) - 8;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background track arc
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Progress sweep gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        tileMode: TileMode.clamp,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Draw active glowing progress
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * value.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // Tip indicator dots
    final endAngle = math.pi + (math.pi * value.clamp(0.0, 1.0));
    final tipOffset = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    final shadowPaint = Paint()
      ..color = gradientColors.last.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(tipOffset, 8, shadowPaint);
    canvas.drawCircle(tipOffset, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Header alert badge with live metrics

// Activity Heatmap implementation connected to actual state.weeklyActivity

// Streak Card connected to actual state.streak and state.weeklyActivity
class _StreakCard extends ConsumerWidget {
  final String Function({required String ru, required String en, required String kk}) t;
  final AppThemeColors colors;
  final int streakVal;

  const _StreakCard({
    required this.t,
    required this.colors,
    required this.streakVal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final now = DateTime.now();
    final dates = List.generate(
      7,
      (i) {
        final d = now.subtract(Duration(days: 6 - i));
        return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
      },
    );
    
    // Light up fires exactly on days user did tasks (weeklyActivity > 0)
    final actives = List.generate(7, (i) {
      if (state.weeklyActivity.length > i) {
        return state.weeklyActivity[i] > 0;
      }
      return false;
    });

    final bestStreak = state.maxStreak;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surface.withValues(alpha: 0.6),
        border: Border.all(color: colors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.02),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                t(ru: 'Серия', en: 'Streak', kk: 'Серия'),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: t(
                  ru: 'Количество дней подряд, в течение которых вы совершали учебные действия. Поддерживайте пламя!',
                  en: 'Number of consecutive days during which you performed learning actions. Keep the fire burning!',
                  kk: 'Оқу әрекеттерін орындаған қатарынан бірнеше күн. Жалынды сөндірмеңіз!',
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: colors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.divider, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: colors.textSecondary.withValues(alpha: 0.4),
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$streakVal',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                t(ru: 'дней', en: 'days', kk: 'күн'),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${t(ru: "Лучшая серия", en: "Best streak", kk: "Ең жақсы серия")}: $bestStreak ${t(ru: "дней", en: "days", kk: "күн")}',
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: 0.6),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final active = actives[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? Colors.orange.withValues(alpha: 0.15) : colors.backgroundElevated.withValues(alpha: 0.4),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: active ? Colors.orange : colors.textSecondary.withValues(alpha: 0.25),
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dates[index],
                    style: TextStyle(
                      color: colors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Learning Time Card — estimates time from completed lessons (15 min each).
class _LearningTimeCard extends ConsumerWidget {
  final String Function({required String ru, required String en, required String kk}) t;
  final AppThemeColors colors;

  const _LearningTimeCard({required this.t, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final totalMinutes = state.completedLessonIds.length * 15;
    final liveHours = totalMinutes ~/ 60;
    final liveMinutes = totalMinutes % 60;
    // Progress ring: weekly goal of 5 hours (300 min).
    final ringProgress = (totalMinutes / 300.0).clamp(0.05, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surface.withValues(alpha: 0.6),
        border: Border.all(color: colors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.success.withValues(alpha: 0.02),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      t(ru: 'Время обучения', en: 'Learning Time', kk: 'Оқу уақыты'),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: t(
                        ru: 'Общее время, проведенное в приложении за чтением теории, просмотром видео, решением задач и диалогами с ИИ.',
                        en: 'Total active time spent in the app reading theory, watching videos, solving code, and chatting with AI.',
                        kk: 'Теорияны оқуға, видео көруге, есептер шығаруға және ИИ-мен сөйлесуге қолданбада өткізілген жалпы белсенді уақыт.',
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: colors.backgroundElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.divider, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 4),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: colors.textSecondary.withValues(alpha: 0.4),
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$liveHours',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Text(
                      t(ru: 'ч', en: 'h', kk: 'с'),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$liveMinutes',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Text(
                      t(ru: 'мин', en: 'm', kk: 'м'),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Ring visual
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: CircularProgressIndicator(
                  value: ringProgress,
                  strokeWidth: 8,
                  backgroundColor: colors.backgroundElevated.withValues(alpha: 0.6),
                  color: colors.success,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(
                Icons.access_time_filled_rounded,
                color: colors.success,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Server-backed performance section: quiz/practice stats and topic progress
// from `GET /api/v1/student/statistics`, hidden when the backend is unavailable.

// Favorite Topics Card connected to actual user completed categories and tracks in Learn section
class _FavoriteTopicsCard extends ConsumerWidget {
  final String Function({required String ru, required String en, required String kk}) t;
  final AppThemeColors colors;

  const _FavoriteTopicsCard({required this.t, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);

    // Compute dynamic percentages based on user's progress in enrolled courses in Learn!
    // Exclude programming_languages as explicitly requested.
    int aiPoints = 30;
    int analyticsPoints = 25;
    int dbPoints = 20;
    int softSkillsPoints = 15;
    int otherPoints = 10;

    for (final entry in state.coursePlayerProgressByCourseId.entries) {
      final courseId = entry.key;
      final progress = entry.value;
      final course = catalog.maybeCourseById(courseId);
      if (course != null) {
        final earned = progress.earnedPoints > 0 
            ? progress.earnedPoints 
            : (progress.completedLessonIds.length * 10);
            
        if (course.topicKeys.contains('ai')) {
          aiPoints += earned;
        }
        if (course.topicKeys.contains('data_analytics')) {
          analyticsPoints += earned;
        }
        if (course.topicKeys.contains('sql_databases')) {
          dbPoints += earned;
        }
        if (course.topicKeys.contains('soft_skills')) {
          softSkillsPoints += earned;
        }
      }
    }

    final totalPoints = aiPoints + analyticsPoints + dbPoints + softSkillsPoints + otherPoints;
    final pAi = ((aiPoints / totalPoints) * 100).round();
    final pAnalytics = ((analyticsPoints / totalPoints) * 100).round();
    final pDb = ((dbPoints / totalPoints) * 100).round();
    final pSoftSkills = ((softSkillsPoints / totalPoints) * 100).round();
    final pOther = 100 - (pAi + pAnalytics + pDb + pSoftSkills);

    final topics = [
      {
        'label': t(ru: 'Искусственный\nинтеллект', en: 'Artificial\nIntelligence', kk: 'Жасанды\nинтеллект'),
        'percent': '$pAi%',
        'icon': Icons.psychology_rounded,
        'color': colors.primary,
      },
      {
        'label': t(ru: 'Анализ\nданных', en: 'Data\nAnalytics', kk: 'Деректерді\nталдау'),
        'percent': '$pAnalytics%',
        'icon': Icons.insights_rounded,
        'color': colors.success,
      },
      {
        'label': t(ru: 'Базы\nданных', en: 'Databases\n& SQL', kk: 'Деректер\nбазалары'),
        'percent': '$pDb%',
        'icon': Icons.storage_rounded,
        'color': Colors.orange,
      },
      {
        'label': t(ru: 'Гибкие\nнавыки', en: 'Soft\nSkills', kk: 'Гибкие\nнавыки'),
        'percent': '$pSoftSkills%',
        'icon': Icons.forum_rounded,
        'color': colors.accent,
      },
      {
        'label': t(ru: 'Другое', en: 'Other', kk: 'Басқа'),
        'percent': '$pOther%',
        'icon': Icons.more_horiz_rounded,
        'color': colors.textSecondary.withValues(alpha: 0.6),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surface.withValues(alpha: 0.6),
        border: Border.all(color: colors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.01),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                t(ru: 'Любимые темы', en: 'Favorite Topics', kk: 'Таңдаулы тақырыптар'),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: t(
                  ru: 'Распределение ваших учебных интересов на основе прогресса прохождения курсов в разделе Learn.',
                  en: 'Distribution of your learning interests based on course completion progress in the Learn section.',
                  kk: 'Learn бөліміндегі курстардың өту прогресі негизинде қызығушылықтарыңыздың бөлінуі.',
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: colors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.divider, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: colors.textSecondary.withValues(alpha: 0.4),
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(topics.length, (index) {
                final item = topics[index];
                final color = item['color'] as Color;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.12),
                          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: color,
                          size: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 24,
                        child: Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['percent'] as String,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress tab: backend-driven widgets
// ─────────────────────────────────────────────────────────────────────────────

typedef _T = String Function({required String ru, required String en, required String kk});

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.colors});

  final String label;
  final String value;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendLearningSignals extends StatelessWidget {
  const _BackendLearningSignals({
    required this.stats,
    required this.colors,
    required this.t,
  });

  final BackendStudentStatisticsDto stats;
  final AppThemeColors colors;
  final _T t;

  @override
  Widget build(BuildContext context) {
    final quiz = stats.quiz;
    final practice = stats.practice;
    final pct = quiz.accuracyPercent.clamp(0, 100);
    final hasQuiz = quiz.attemptedQuizzes > 0;

    return GlowCard(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(ru: 'Сигналы обучения', en: 'Learning Signals', kk: 'Оқу сигналдары'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 38,
                        sections: hasQuiz
                            ? [
                                PieChartSectionData(
                                  value: pct.toDouble(),
                                  color: colors.primary,
                                  title: '',
                                  radius: 22,
                                ),
                                PieChartSectionData(
                                  value: (100 - pct).toDouble(),
                                  color: colors.backgroundElevated,
                                  title: '',
                                  radius: 22,
                                ),
                              ]
                            : [
                                PieChartSectionData(
                                  value: 1,
                                  color: colors.backgroundElevated,
                                  title: '',
                                  radius: 22,
                                ),
                              ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasQuiz ? '$pct%' : '—',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          t(ru: 'точность', en: 'accuracy', kk: 'дәлдік'),
                          style: TextStyle(fontSize: 9, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _StatRow(
                      label: t(ru: 'Квизов пройдено', en: 'Quizzes passed', kk: 'Квиздер өтілді'),
                      value: '${quiz.passedQuizzes}/${quiz.attemptedQuizzes}',
                      colors: colors,
                    ),
                    _StatRow(
                      label: t(ru: 'Запусков кода', en: 'Code runs', kk: 'Код іске қосулары'),
                      value: '${practice.runs}',
                      colors: colors,
                    ),
                    _StatRow(
                      label: t(ru: 'Отправлений', en: 'Submissions', kk: 'Жіберулер'),
                      value: '${practice.submissions}',
                      colors: colors,
                    ),
                    _StatRow(
                      label: t(ru: 'Практик завершено', en: 'Practices done', kk: 'Практикалар аяқталды'),
                      value: '${practice.completedPractices}/${practice.attemptedPractices}',
                      colors: colors,
                    ),
                    _StatRow(
                      label: t(ru: 'XP за практику', en: 'Practice XP', kk: 'Практика XP'),
                      value: '+${practice.xpEarned} XP',
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackendActivityChart extends StatelessWidget {
  const _BackendActivityChart({
    required this.activity,
    required this.colors,
    required this.t,
  });

  final List<BackendStudentActivityDayDto> activity;
  final AppThemeColors colors;
  final _T t;

  @override
  Widget build(BuildContext context) {
    final maxXp = activity.isEmpty
        ? 1.0
        : activity.map((d) => d.xp).reduce(math.max).toDouble();
    final barGroups = activity.asMap().entries.map((entry) {
      final xp = entry.value.xp;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: xp.toDouble(),
            color: xp > 0 ? colors.primary : colors.backgroundElevated,
            width: 9,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return GlowCard(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(ru: 'Активность (30 дней)', en: 'Activity (30 days)', kk: 'Белсенділік (30 күн)'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            t(ru: 'XP по дням', en: 'XP per day', kk: 'Күн бойынша XP'),
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final idx = value.round();
                        if (idx < 0 || idx >= activity.length) {
                          return const SizedBox.shrink();
                        }
                        if (idx % 7 != 0) return const SizedBox.shrink();
                        final parts = activity[idx].date.split('-');
                        if (parts.length < 3) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${parts[2]}/${parts[1]}',
                            style: TextStyle(fontSize: 9, color: colors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                maxY: maxXp < 1 ? 10 : maxXp * 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendTopicsProgress extends StatelessWidget {
  const _BackendTopicsProgress({
    required this.topics,
    required this.colors,
    required this.t,
  });

  final List<BackendStudentTopicProgressDto> topics;
  final AppThemeColors colors;
  final _T t;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(ru: 'Прогресс по темам', en: 'Topics Progress', kk: 'Тақырыптар бойынша прогрес'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...topics.map((topic) {
            final pct = topic.progressPercent.clamp(0, 100) / 100.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          topic.name,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${topic.completedLessons}/${topic.totalLessons}',
                        style: TextStyle(color: colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  BubbleProgressBar(
                    value: pct,
                    color: colors.primary,
                    backgroundColor: colors.backgroundElevated,
                    bubbleText: '${topic.progressPercent}%',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BackendCourseProgress extends StatelessWidget {
  const _BackendCourseProgress({
    required this.courses,
    required this.colors,
    required this.t,
  });

  final List<BackendStudentCourseDetailDto> courses;
  final AppThemeColors colors;
  final _T t;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(ru: 'Курсы', en: 'Courses', kk: 'Курстар'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...courses.map((course) {
            final pct = course.progressPercent.clamp(0, 100) / 100.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${course.completedLessons}/${course.totalLessons}',
                        style: TextStyle(color: colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  BubbleProgressBar(
                    value: pct,
                    color: colors.primary,
                    backgroundColor: colors.backgroundElevated,
                    bubbleText: '${course.progressPercent}%',
                  ),
                  if (course.practiceRuns > 0 || course.practiceCompleted > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      t(
                        ru: 'Практика: ${course.practiceCompleted} завершено / ${course.practiceRuns} запусков',
                        en: 'Practice: ${course.practiceCompleted} completed / ${course.practiceRuns} runs',
                        kk: 'Практика: ${course.practiceCompleted} аяқталды / ${course.practiceRuns} іске қосу',
                      ),
                      style: TextStyle(fontSize: 11, color: colors.textSecondary),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
