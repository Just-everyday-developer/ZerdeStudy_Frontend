import 'dart:math' as math;

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/bubble_progress_bar.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

enum ActivityInterval { week, month, threeMonths, year }

class _StatsPageState extends ConsumerState<StatsPage> {
  ActivityInterval _selectedInterval = ActivityInterval.week;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final unlockedAchievements = catalog
        .achievementsFor(state)
        .where((item) => item.unlocked)
        .length;
    final passedAssessments = catalog.passedAssessments(state);
    final averageAssessment = catalog.averageBestAssessmentPercent(state);
    final aiSessions = state.aiMessages
        .where((item) => item.author == AiAuthor.user)
        .length;
    final colors = context.appColors;

    return AppPageScaffold(
      title: context.l10n.text('stats'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: colors.primary,
            child: _MetricsCarousel(
              xp: '${state.xp}',
              level: '${state.level}',
              xpToNextLevel: '${state.xpToNextLevel} XP',
              streak: '${state.streak}d',
              completedUnits: '${catalog.totalCompletedUnits(state)}/${catalog.totalUnits()}',
              unlockedAchievements: '$unlockedAchievements',
              passedAssessments: '$passedAssessments/${state.assessmentResultsByTrackId.length}',
              aiSessions: '$aiSessions',
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.xpIntoLevel}/${DemoAppState.xpPerLevel} XP in the current level',
                  style: TextStyle(color: colors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                BubbleProgressBar(
                  value: state.xpIntoLevel / DemoAppState.xpPerLevel,
                  color: colors.primary,
                  backgroundColor: colors.backgroundElevated,
                  bubbleText: '${state.xpIntoLevel}/${DemoAppState.xpPerLevel} XP',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.locale == AppLocale.ru ? 'Активность' : (context.l10n.locale == AppLocale.kk ? 'Белсенділік' : 'Activity'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SegmentedButton<ActivityInterval>(
                      segments: [
                        ButtonSegment(value: ActivityInterval.week, label: Text(context.l10n.locale == AppLocale.ru ? 'Неделя' : 'Week')),
                        ButtonSegment(value: ActivityInterval.month, label: Text(context.l10n.locale == AppLocale.ru ? 'Месяц' : 'Month')),
                        ButtonSegment(value: ActivityInterval.threeMonths, label: Text('3 мес.')),
                        ButtonSegment(value: ActivityInterval.year, label: Text(context.l10n.locale == AppLocale.ru ? 'Год' : 'Year')),
                      ],
                      selected: {_selectedInterval},
                      onSelectionChanged: (set) {
                        setState(() {
                          _selectedInterval = set.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ActivityChart(interval: _selectedInterval, colors: colors),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XP and learning signals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _BreakdownRow(
                  label: 'Lessons',
                  value: '${state.completedLessonIds.length}',
                ),
                _BreakdownRow(
                  label: 'Practice',
                  value: '${state.completedPracticeIds.length}',
                ),
                _BreakdownRow(
                  label: 'Quizzes solved',
                  value:
                      '${state.completedQuizIds.length}/${catalog.totalQuizzes()}',
                ),
                _BreakdownRow(
                  label: 'Memory labs',
                  value:
                      '${state.completedTrainerIds.length}/${catalog.totalTrainers()}',
                ),
                _BreakdownRow(
                  label: 'Quiz accuracy',
                  value: '${(state.quizAccuracy * 100).round()}%',
                ),
                _BreakdownRow(label: 'AI sessions', value: '$aiSessions'),
                _BreakdownRow(
                  label: 'Assessment passes',
                  value: '$passedAssessments',
                ),
                _BreakdownRow(
                  label: 'Assessment average',
                  value: '$averageAssessment%',
                ),
                _BreakdownRow(
                  label: 'Assessment attempts',
                  value: '${state.assessmentAttemptHistory.length}',
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
                  'Zone progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...TrackZone.values.map((zone) {
                  final zoneTitle = catalog
                      .zoneTitle(zone)
                      .resolve(state.locale);
                  final completed = catalog.completedUnitsForZone(state, zone);
                  final total = catalog.totalUnitsForZone(zone);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zoneTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$completed / $total units',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : completed / total,
                            minHeight: 8,
                            backgroundColor: colors.backgroundElevated,
                            color: zone == TrackZone.computerScienceCore
                                ? colors.primary
                                : colors.accent,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
                  'Track breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...catalog.tracks.map((track) {
                  final progress = catalog.progressForTrack(state, track.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title.resolve(state.locale),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progress.completedUnits}/${progress.totalUnits} units | ${progress.state.name} | assessment ${catalog.bestAssessmentPercentFor(state, track.id)}%',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        BubbleProgressBar(
                          value: progress.fraction,
                          color: track.color,
                          backgroundColor: colors.backgroundElevated,
                          height: 8,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent milestones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...catalog
                    .recentMilestonesFor(state)
                    .map(
                      (milestone) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.bolt_rounded,
                                color: colors.success,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                milestone.resolve(state.locale),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsCarousel extends StatefulWidget {
  const _MetricsCarousel({
    required this.xp,
    required this.level,
    required this.xpToNextLevel,
    required this.streak,
    required this.completedUnits,
    required this.unlockedAchievements,
    required this.passedAssessments,
    required this.aiSessions,
  });

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

    final List<List<Map<String, String>>> pagesData = [
      [
        {'label': 'XP', 'value': widget.xp},
        {'label': 'Level', 'value': widget.level},
      ],
      [
        {'label': 'To next', 'value': widget.xpToNextLevel},
        {'label': 'Streak', 'value': widget.streak},
      ],
      [
        {'label': 'Units', 'value': widget.completedUnits},
        {'label': 'Achievements', 'value': widget.unlockedAchievements},
      ],
      [
        {'label': 'Assessments', 'value': widget.passedAssessments},
        {'label': 'AI sessions', 'value': widget.aiSessions},
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
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({
    required this.interval,
    required this.colors,
  });

  final ActivityInterval interval;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final List<_ChartData> chartData = [];
    final double maxY;

    switch (interval) {
      case ActivityInterval.week:
        final mock = [2, 4, 3, 5, 4, 6, 2];
        final labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        for (int i = 0; i < 7; i++) {
          chartData.add(_ChartData(labels[i], mock[i].toDouble()));
        }
        maxY = 10;
        break;
      case ActivityInterval.month:
        for (int i = 0; i < 30; i++) {
          final label = '${i + 1}';
          chartData.add(_ChartData(label, 2.0 + math.Random(i).nextInt(10)));
        }
        maxY = 15;
        break;
      case ActivityInterval.threeMonths:
        for (int i = 0; i < 12; i++) {
          final label = 'W${i + 1}';
          chartData.add(_ChartData(label, 10.0 + math.Random(i).nextInt(25)));
        }
        maxY = 40;
        break;
      case ActivityInterval.year:
        final labels = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        for (int i = 0; i < 12; i++) {
          chartData.add(_ChartData(labels[i], 40.0 + math.Random(i).nextInt(100)));
        }
        maxY = 150;
        break;
    }

    return SizedBox(
      height: 220,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enableDoubleTapZooming: true,
          enablePanning: true,
          enableSelectionZooming: true,
        ),
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: TextStyle(color: colors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
          labelIntersectAction: AxisLabelIntersectAction.hide,
        ),
        primaryYAxis: NumericAxis(
          isVisible: false,
          minimum: 0,
          maximum: maxY,
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          canShowMarker: false,
          format: 'point.y',
          textStyle: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        series: <CartesianSeries<_ChartData, String>>[
          SplineAreaSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.28),
                colors.primary.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          SplineSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: colors.primary,
            width: 3.5,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 6,
              width: 6,
              shape: DataMarkerType.circle,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: interval == ActivityInterval.week || interval == ActivityInterval.year,
              textStyle: TextStyle(color: colors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold),
              labelAlignment: ChartDataLabelAlignment.outer,
            ),
          )
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: colors.textSecondary)),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
