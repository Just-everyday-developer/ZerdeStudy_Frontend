import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/app_theme_mode.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final achievements = catalog.achievementsFor(state);
    final unlocked =
        achievements.where((item) => item.unlocked).toList(growable: false);
    final preview = <Achievement>[
      ...unlocked.take(3),
      ...achievements.where((item) => !item.unlocked).take(1),
    ].take(4).toList(growable: false);
    final favorites = catalog.savedCoursesFor(state);
    final completedTracks = catalog.completedTracksFor(state);
    final completedModules = catalog.completedModulesFor(state);
    final completedLessons = catalog.completedLessonsFor(state);
    final completedPractices = catalog.completedPracticesFor(state);
    final history = state.learningHistory
        .toList(growable: false)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    final user = state.user;
    final colors = context.appColors;

    return AppPageScaffold(
      actions: [
        IconButton(
          onPressed: () => _showSettingsSheet(context, ref),
          icon: Icon(Icons.settings_rounded, color: colors.textPrimary),
          tooltip: 'Settings',
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          GlowCard(
            accent: colors.primary,
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.14),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: colors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.name ?? 'Dana S.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? 'demo@zerdestudy.app',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _Pill(label: 'XP', value: '${state.xp}'),
                    _Pill(label: 'Level', value: '${state.level}'),
                    _Pill(label: 'Streak', value: '${state.streak}d'),
                    _Pill(
                      label: 'Theme',
                      value: state.themeMode.label,
                    ),
                  ],
                ),
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
                  context.l10n.text('profile_goal'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.goal ?? 'Reach confident demo flow in 14 days',
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoTag(
                      icon: Icons.language_rounded,
                      label: 'Language: ${state.locale.label}',
                    ),
                    _InfoTag(
                      icon: Icons.palette_outlined,
                      label: 'Theme: ${state.themeMode.label}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.text('achievements'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${unlocked.length}/${achievements.length} unlocked',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAchievementsSheet(
                        context,
                        achievements,
                        state.locale,
                      ),
                      icon: Icon(
                        Icons.workspace_premium_rounded,
                        color: colors.success,
                      ),
                      label: Text(
                        'Open',
                        style: TextStyle(
                          color: colors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...preview.map(
                  (achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AchievementRow(
                      achievement: achievement,
                      locale: state.locale,
                    ),
                  ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Favorites',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${favorites.length} saved',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (favorites.isEmpty)
                  Text(
                    'Save community courses to keep them here for quick access.',
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  )
                else
                  ...favorites.take(4).map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProfileLinkTile(
                            title: course.title.resolve(state.locale),
                            subtitle:
                                '${course.author.name}  •  ${course.level}  •  ${course.rating.toStringAsFixed(1)}',
                            accent: course.color,
                            icon: Icons.bookmark_rounded,
                            onTap: () => context.push(
                              AppRoutes.courseById(course.id),
                            ),
                          ),
                        ),
                      ),
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
                  'Completed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Pill(label: 'Tracks', value: '${completedTracks.length}'),
                    _Pill(label: 'Modules', value: '${completedModules.length}'),
                    _Pill(label: 'Lessons', value: '${completedLessons.length}'),
                    _Pill(label: 'Practices', value: '${completedPractices.length}'),
                  ],
                ),
                const SizedBox(height: 14),
                if (completedTracks.isNotEmpty)
                  ...completedTracks.take(3).map(
                        (track) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProfileLinkTile(
                            title: track.title.resolve(state.locale),
                            subtitle:
                                'Assessment ${catalog.bestAssessmentPercentFor(state, track.id)}%  •  ${catalog.progressForTrack(state, track.id).completedUnits}/${track.totalUnits} units',
                            accent: track.color,
                            icon: Icons.check_circle_rounded,
                            onTap: () => context.push(
                              AppRoutes.trackById(track.id),
                            ),
                          ),
                        ),
                      )
                else
                  Text(
                    'Completed tracks, modules, lessons, and practices will appear here.',
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
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
                  'Result history',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Text(
                    'Assessment attempts and completion events will appear here.',
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  )
                else
                  ...history.take(8).map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HistoryTile(
                            entry: entry,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton.secondary(
            label: context.l10n.text('view_stats'),
            icon: Icons.insights_rounded,
            onPressed: () => context.push(AppRoutes.stats),
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: context.l10n.text('view_leaderboard'),
            icon: Icons.leaderboard_rounded,
            onPressed: () => context.push(AppRoutes.leaderboard),
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: context.l10n.text('delete_history'),
            icon: Icons.restart_alt_rounded,
            onPressed: () {
              controller.resetDemo();
              AppNotice.show(
                context,
                message: context.l10n.text('reset_demo'),
                type: AppNoticeType.success,
              );
            },
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: context.l10n.text('logout'),
            icon: Icons.logout_rounded,
            onPressed: () {
              controller.logout();
              context.go(AppRoutes.welcome);
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    final state = ref.read(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final colors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Language',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  LocaleSelector(
                    currentLocale: state.locale,
                    onChanged: controller.changeLocale,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppThemeMode.values.map((mode) {
                      final selected = mode == state.themeMode;
                      return ChoiceChip(
                        label: Text(mode.label),
                        selected: selected,
                        onSelected: (_) => controller.changeThemeMode(mode),
                        selectedColor: colors.primary.withValues(alpha: 0.16),
                        backgroundColor: colors.surfaceSoft,
                        side: BorderSide(
                          color: selected ? colors.primary : colors.divider,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? colors.primary
                              : colors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAchievementsSheet(
    BuildContext context,
    List<Achievement> achievements,
    AppLocale locale,
  ) {
    final unlocked =
        achievements.where((item) => item.unlocked).toList(growable: false);
    final locked =
        achievements.where((item) => !item.unlocked).toList(growable: false);
    final colors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.78,
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          Text(
                            'Achievements',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${unlocked.length} unlocked | ${locked.length} locked',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          _AchievementSection(
                            title: 'Unlocked',
                            accent: colors.success,
                            achievements: unlocked,
                            locale: locale,
                          ),
                          const SizedBox(height: 18),
                          _AchievementSection(
                            title: 'Locked',
                            accent: colors.textSecondary,
                            achievements: locked,
                            locale: locale,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AchievementSection extends StatelessWidget {
  const _AchievementSection({
    required this.title,
    required this.accent,
    required this.achievements,
    required this.locale,
  });

  final String title;
  final Color accent;
  final List<Achievement> achievements;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (achievements.isEmpty)
            Text(
              'No items here yet.',
              style: TextStyle(color: colors.textSecondary),
            )
          else
            ...achievements.map(
              (achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AchievementRow(
                  achievement: achievement,
                  locale: locale,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({
    required this.achievement,
    required this.locale,
  });

  final Achievement achievement;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = achievement.unlocked ? colors.success : colors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.16),
            child: Icon(achievement.icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title.resolve(locale),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description.resolve(locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: achievement.fraction,
                    minHeight: 6,
                    backgroundColor: colors.backgroundElevated,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${achievement.progress}/${achievement.goal}',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceSoft,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
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

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLinkTile extends StatelessWidget {
  const _ProfileLinkTile({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colors.surfaceSoft,
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: 0.16),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
  });

  final LearningHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = switch (entry.kind) {
      LearningHistoryKind.lessonCompleted => colors.primary,
      LearningHistoryKind.practiceCompleted => colors.accent,
      LearningHistoryKind.moduleCompleted => colors.success,
      LearningHistoryKind.trackCompleted => const Color(0xFFFFD166),
      LearningHistoryKind.assessmentCompleted => colors.success,
      LearningHistoryKind.courseSaved => colors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.16),
            child: Icon(
              switch (entry.kind) {
                LearningHistoryKind.lessonCompleted => Icons.play_lesson_rounded,
                LearningHistoryKind.practiceCompleted => Icons.code_rounded,
                LearningHistoryKind.moduleCompleted => Icons.layers_rounded,
                LearningHistoryKind.trackCompleted => Icons.account_tree_rounded,
                LearningHistoryKind.assessmentCompleted =>
                  Icons.assignment_turned_in_rounded,
                LearningHistoryKind.courseSaved => Icons.bookmark_rounded,
              },
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (entry.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  [
                    if (entry.scoreLabel != null) entry.scoreLabel!,
                    _formatHistoryTimestamp(entry.createdAt),
                  ].join('  •  '),
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatHistoryTimestamp(DateTime timestamp) {
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day.$month ${timestamp.year}  $hour:$minute';
  }
}
