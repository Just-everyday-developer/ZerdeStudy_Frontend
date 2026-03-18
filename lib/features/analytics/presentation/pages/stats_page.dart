import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final unlockedAchievements = catalog
        .achievementsFor(state)
        .where((item) => item.unlocked)
        .length;
    final colors = context.appColors;

    return AppPageScaffold(
      title: context.l10n.text('stats'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: colors.primary,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 540;
                final columns = compact ? 2 : 3;
                final itemWidth =
                    (constraints.maxWidth - (12 * (columns - 1))) / columns;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricTile(label: 'XP', value: '${state.xp}', width: itemWidth),
                    _MetricTile(
                      label: 'Level',
                      value: '${state.level}',
                      width: itemWidth,
                    ),
                    _MetricTile(
                      label: 'Streak',
                      value: '${state.streak}d',
                      width: itemWidth,
                    ),
                    _MetricTile(
                      label: 'Units',
                      value:
                          '${catalog.totalCompletedUnits(state)}/${catalog.totalUnits()}',
                      width: itemWidth,
                    ),
                    _MetricTile(
                      label: 'Achievements',
                      value: '$unlockedAchievements',
                      width: itemWidth,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text('weekly_activity'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _WeeklyActivityChart(values: state.weeklyActivity),
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
                _BreakdownRow(
                  label: 'AI sessions',
                  value:
                      '${state.aiMessages.where((item) => item.author == AiAuthor.user).length}',
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
                  final zoneTitle = catalog.zoneTitle(zone).resolve(state.locale);
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
                          '${progress.completedUnits}/${progress.totalUnits} units | ${progress.state.name}',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress.fraction,
                            minHeight: 6,
                            backgroundColor: colors.backgroundElevated,
                            color: track.color,
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
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent milestones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...catalog.recentMilestonesFor(state).map(
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart({
    required this.values,
  });

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final normalizedValues = values.length >= 7
        ? values.take(7).toList(growable: false)
        : <int>[...values, ...List<int>.filled(7 - values.length, 0)];
    final maxValue = math.max(1, normalizedValues.fold<int>(0, math.max));
    const days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List<Widget>.generate(days.length, (index) {
          final value = normalizedValues[index];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: value == 0 ? 0.12 : value / maxValue,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: colors.primary.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 16,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        days[index],
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
  });

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
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary),
            ),
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
