import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
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
    final achievements = catalog.achievementsFor(state).take(3).toList();
    final leaderboard = catalog.leaderboardFor(state).take(3).toList();
    final recommended = catalog.tracks.take(3).toList();

    return AppPageScaffold(
      title: l10n.text('dashboard'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          GlowCard(
            accent: currentTrack.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.user?.name ?? 'Aliya ❤️'}, ${l10n.text('continue_learning').toLowerCase()}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  currentTrack.description.resolve(state.locale),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricBadge(label: 'XP', value: '${state.xp}'),
                    _MetricBadge(label: 'Level', value: '${state.level}'),
                    _MetricBadge(label: 'Streak', value: '${state.streak}d'),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  currentTrack.title.resolve(state.locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentProgress.completedUnits}/${currentProgress.totalUnits} ${l10n.text('lessons_done').toLowerCase()}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: currentProgress.fraction,
                    minHeight: 10,
                    color: currentTrack.color,
                    backgroundColor: AppColors.backgroundElevated,
                  ),
                ),
                const SizedBox(height: 18),
                AppButton.primary(
                  label: currentProgress.nextTarget == null
                      ? l10n.text('start_track')
                      : l10n.text('continue_learning'),
                  icon: Icons.play_circle_fill_rounded,
                  onPressed: () {
                    final nextTarget = currentProgress.nextTarget;
                    if (nextTarget == null) {
                      context.push(AppRoutes.trackById(currentTrack.id));
                      return;
                    }
                    context.push(
                      nextTarget.isPractice
                          ? AppRoutes.practiceById(nextTarget.id)
                          : AppRoutes.lessonById(nextTarget.id),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: AppColors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('daily_mission'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.dailyMissionDone
                      ? l10n.text('daily_mission_done')
                      : l10n.text('daily_mission_pending'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.text('recommended_tracks')),
          const SizedBox(height: 12),
          ...recommended.map((track) {
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
          const SizedBox(height: 12),
          _SectionTitle(title: l10n.text('achievements')),
          const SizedBox(height: 12),
          ...achievements.map((achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AchievementPreview(
                  achievement: achievement,
                  locale: state.locale,
                ),
              )),
          const SizedBox(height: 12),
          _SectionTitle(
            title: l10n.text('leaderboard'),
            actionLabel: l10n.text('view_leaderboard'),
            onTap: () => context.push(AppRoutes.leaderboard),
          ),
          const SizedBox(height: 12),
          GlowCard(
            accent: AppColors.success,
            child: Column(
              children: leaderboard.map((entry) {
                final index = leaderboard.indexOf(entry) + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: entry.isCurrentUser
                            ? AppColors.primary.withValues(alpha: 0.18)
                            : AppColors.surfaceSoft,
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: entry.isCurrentUser
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.name,
                          style: TextStyle(
                            color: entry.isCurrentUser
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.xp} XP',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel!),
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementPreview extends StatelessWidget {
  const _AchievementPreview({
    required this.achievement,
    required this.locale,
  });

  final Achievement achievement;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: achievement.unlocked ? AppColors.primary : AppColors.divider,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (achievement.unlocked ? AppColors.primary : AppColors.surfaceSoft)
                  .withValues(alpha: 0.16),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.unlocked ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title.resolve(locale),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description.resolve(locale),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: achievement.fraction,
                    minHeight: 6,
                    backgroundColor: AppColors.backgroundElevated,
                    color: achievement.unlocked ? AppColors.success : AppColors.primary,
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
