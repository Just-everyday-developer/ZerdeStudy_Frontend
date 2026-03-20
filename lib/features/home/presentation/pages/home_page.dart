import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../widgets/course_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final l10n = context.l10n;
    final currentTrack = catalog.trackById(state.currentTrackId);
    final currentProgress = catalog.progressForTrack(state, currentTrack.id);
    final leaderboard =
        catalog.leaderboardFor(state).take(5).toList(growable: false);
    final recommendedTracks = catalog.tracks.take(4).toList(growable: false);
    final incorrectExercises = catalog.incorrectCourseExercisesFor(state);
    final incorrectQuizzes = catalog.incorrectTrackQuizzesFor(state);
    final colors = context.appColors;
    final compact = context.isCompactLayout;

    return AppPageScaffold(
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, compact ? 6 : 8, 0, compact ? 104 : 120),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${state.user?.name ?? 'Talgat'}, ${l10n.text('continue_learning').toLowerCase()}',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: compact ? 24 : 28),
              ),
              const SizedBox(height: 10),
              Text(
                currentTrack.description.resolve(state.locale),
                style: TextStyle(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricBadge(label: 'XP', value: '${state.xp}'),
                  _MetricBadge(label: 'Level', value: '${state.level}'),
                  _MetricBadge(label: 'Streak', value: '${state.streak}d'),
                  _MetricBadge(
                    label: 'Mastered',
                    value: '${catalog.masteredTracks(state)}',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                currentTrack.title.resolve(state.locale),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '${currentProgress.completedUnits}/${currentProgress.totalUnits} completed units',
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: currentProgress.fraction,
                  minHeight: 10,
                  backgroundColor: colors.backgroundElevated,
                  color: currentTrack.color,
                ),
              ),
              const SizedBox(height: 16),
              AppButton.primary(
                label: currentProgress.nextTarget == null
                    ? l10n.text('start_track')
                    : l10n.text('continue_learning'),
                icon: Icons.play_circle_fill_rounded,
                maxWidth: compact ? null : 360,
                onPressed: () {
                  final target = currentProgress.nextTarget;
                  if (target == null) {
                    context.push(AppRoutes.trackById(currentTrack.id));
                    return;
                  }
                  context.push(
                    target.isPractice
                        ? AppRoutes.practiceById(target.id)
                        : AppRoutes.lessonById(target.id),
                  );
                },
              ),
              if (incorrectExercises.isNotEmpty || incorrectQuizzes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: colors.surfaceSoft,
                    border: Border.all(color: colors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('repeat_wrong_answers'),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.format(
                          'repeat_wrong_answers_hint',
                          <String, Object>{
                            'count': incorrectExercises.length + incorrectQuizzes.length,
                          },
                        ),
                        style: TextStyle(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...incorrectExercises.take(2).map(
                            (exercise) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '• ${exercise.title.resolve(state.locale)}',
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ),
                          ),
                      ...incorrectQuizzes.take(2).map(
                            (quiz) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '• ${quiz.title.resolve(state.locale)}',
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ),
                          ),
                      const SizedBox(height: 10),
                      AppButton.secondary(
                        label: l10n.text('repeat_wrong_answers'),
                        icon: Icons.refresh_rounded,
                        maxWidth: compact ? null : 300,
                        onPressed: () {
                          if (state.enrolledCommunityCourseIds.isNotEmpty) {
                            context.push(
                              AppRoutes.coursePlayerById(
                                state.enrolledCommunityCourseIds.first,
                              ),
                            );
                            return;
                          }
                          if (currentProgress.nextTarget != null) {
                            final target = currentProgress.nextTarget!;
                            context.push(
                              target.isPractice
                                  ? AppRoutes.practiceById(target.id)
                                  : AppRoutes.lessonById(target.id),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: compact ? 20 : 16),
          if (!compact) const SizedBox(height: 24),
          _SectionTitle(title: l10n.text('recommended_tracks')),
          const SizedBox(height: 12),
          ...recommendedTracks.map((track) {
            final progress = catalog.progressForTrack(state, track.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(
                title: track.title.resolve(state.locale),
                subtitle: track.subtitle.resolve(state.locale),
                progress: progress.fraction,
                color: track.color,
                trailing: Icon(track.icon, color: track.color, size: 32),
                onTap: () => context.push(AppRoutes.trackById(track.id)),
              ),
            );
          }),
          _SectionTitle(
            title: l10n.text('leaderboard'),
            actionLabel: l10n.text('view_leaderboard'),
            onTap: () => context.push(AppRoutes.leaderboard),
          ),
          const SizedBox(height: 12),
          GlowCard(
            accent: colors.success,
            child: Column(
              children: leaderboard.map((entry) {
                final index = leaderboard.indexOf(entry) + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: (entry.isCurrentUser
                                ? colors.primary
                                : colors.surfaceSoft)
                            .withValues(alpha: 0.18),
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: entry.isCurrentUser
                                ? colors.primary
                                : colors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.name,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${entry.role} | ${entry.focus}',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${entry.xp} XP',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
      ],
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 2),
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
