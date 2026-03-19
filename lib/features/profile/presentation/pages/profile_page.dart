import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/app_theme_mode.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final l10n = context.l10n;
    final achievements = catalog.achievementsFor(state);
    final unlocked =
        achievements.where((item) => item.unlocked).toList(growable: false);
    final preview = achievements.take(6).toList(growable: false);
    final certificates = catalog.certificatesFor(state);
    final favorites = catalog.savedCoursesFor(state);
    final completedTracks = catalog.completedTracksFor(state);
    final completedModules = catalog.completedModulesFor(state);
    final completedLessons = catalog.completedLessonsFor(state);
    final completedPractices = catalog.completedPracticesFor(state);
    final history = state.learningHistory.toList(growable: false)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    final user = state.user;
    final colors = context.appColors;

    return AppPageScaffold(
      actions: [
        IconButton(
          onPressed: () => _showSettingsSheet(context),
          icon: Icon(Icons.settings_rounded, color: colors.textPrimary),
          tooltip: l10n.text('settings'),
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
                    _Pill(label: l10n.text('level'), value: '${state.level}'),
                    _Pill(
                      label: l10n.text('streak'),
                      value: '${state.streak}d',
                    ),
                    _Pill(
                      label: l10n.text('theme'),
                      value: _themeLabel(l10n, state.themeMode),
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
                  l10n.text('profile_goal'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.goal ?? l10n.text('default_goal'),
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
                      label: '${l10n.text('locale')}: ${state.locale.label}',
                    ),
                    _InfoTag(
                      icon: Icons.palette_outlined,
                      label:
                          '${l10n.text('theme')}: ${_themeLabel(l10n, state.themeMode)}',
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
                            l10n.text('achievements'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${unlocked.length}/${achievements.length} ${l10n.text('unlocked').toLowerCase()}',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          _showAchievementsSheet(context, achievements, state.locale),
                      icon: Icon(
                        Icons.workspace_premium_rounded,
                        color: colors.success,
                      ),
                      label: Text(
                        l10n.text('show_all'),
                        style: TextStyle(
                          color: colors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: context.isWideLayout ? 164 : 186,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: preview.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: context.isWideLayout ? 220 : 206,
                        child: _AchievementPreviewCard(
                          achievement: preview[index],
                          locale: state.locale,
                          onOpen: () => _showAchievementsSheet(
                            context,
                            achievements,
                            state.locale,
                          ),
                        ),
                      );
                    },
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
                Text(
                  l10n.text('certificates'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.text('certificates_hint'),
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 14),
                if (certificates.isEmpty)
                  Text(
                    l10n.text('no_items_yet'),
                    style: TextStyle(color: colors.textSecondary),
                  )
                else
                  SizedBox(
                    height: context.isWideLayout ? 176 : 188,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: certificates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final certificate = certificates[index];
                        return SizedBox(
                          width: context.isWideLayout ? 260 : 228,
                          child: _CertificatePreviewCard(
                            certificate: certificate,
                            onTap: () => context.push(
                              AppRoutes.courseById(certificate.courseId),
                            ),
                          ),
                        );
                      },
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
                        l10n.text('favorites'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${favorites.length} ${l10n.text('saved').toLowerCase()}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (favorites.isEmpty)
                  Text(
                    l10n.text('favorites_empty'),
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
                            title: course.title.en,
                            subtitle:
                                '${course.author.name} • ${l10n.courseLevelLabel(course.level)} • ${catalog.displayCourseRatingFor(state, course.id).toStringAsFixed(1)}',
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
                  l10n.text('completed'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Pill(
                      label: l10n.text('tracks'),
                      value: '${completedTracks.length}',
                    ),
                    _Pill(
                      label: l10n.text('modules'),
                      value: '${completedModules.length}',
                    ),
                    _Pill(
                      label: l10n.text('lessons'),
                      value: '${completedLessons.length}',
                    ),
                    _Pill(
                      label: l10n.text('practices'),
                      value: '${completedPractices.length}',
                    ),
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
                                '${l10n.text('tree_assessments')} ${catalog.bestAssessmentPercentFor(state, track.id)}% • ${catalog.progressForTrack(state, track.id).completedUnits}/${track.totalUnits} ${l10n.text('tree_units')}',
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
                    l10n.text('completed_empty'),
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
                  l10n.text('result_history'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Text(
                    l10n.text('result_history_empty'),
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  )
                else
                  ...history.take(8).map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HistoryTile(entry: entry),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton.secondary(
            label: l10n.text('view_stats'),
            icon: Icons.insights_rounded,
            onPressed: () => context.push(AppRoutes.stats),
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: l10n.text('view_leaderboard'),
            icon: Icons.leaderboard_rounded,
            onPressed: () => context.push(AppRoutes.leaderboard),
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: l10n.text('delete_history'),
            icon: Icons.restart_alt_rounded,
            onPressed: () {
              controller.resetDemo();
              AppNotice.show(
                context,
                message: l10n.text('reset_demo'),
                type: AppNoticeType.success,
              );
            },
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: l10n.text('logout'),
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

  void _showSettingsSheet(BuildContext context) {
    showAdaptivePanel<void>(
      context: context,
      builder: (context) {
        return const _SettingsPanelContent();
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
    final l10n = context.l10n;

    showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: context.isWideLayout ? 780 : 560,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.78,
            child: Column(
              children: [
                const AdaptivePanelHandle(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        l10n.text('achievements'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${unlocked.length} ${l10n.text('unlocked').toLowerCase()} • ${locked.length} ${l10n.text('locked').toLowerCase()}',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 18),
                      _AchievementSection(
                        title: l10n.text('unlocked'),
                        accent: colors.success,
                        achievements: unlocked,
                        locale: locale,
                      ),
                      const SizedBox(height: 18),
                      _AchievementSection(
                        title: l10n.text('locked'),
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
        );
      },
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return l10n.text('theme_dark');
      case AppThemeMode.light:
        return l10n.text('theme_light');
    }
  }
}

class _SettingsPanelContent extends ConsumerWidget {
  const _SettingsPanelContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final colors = context.appColors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdaptivePanelHandle(),
          const SizedBox(height: 18),
          Text(
            l10n.text('settings'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('locale'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          LocaleSelector(
            currentLocale: state.locale,
            onChanged: controller.changeLocale,
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('theme'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppThemeMode.values.map((mode) {
              final selected = mode == state.themeMode;
              return ChoiceChip(
                label: Text(_themeLabel(l10n, mode)),
                selected: selected,
                onSelected: (_) => controller.changeThemeMode(mode),
                selectedColor: colors.primary.withValues(alpha: 0.16),
                backgroundColor: colors.surfaceSoft,
                side: BorderSide(
                  color: selected ? colors.primary : colors.divider,
                ),
                labelStyle: TextStyle(
                  color: selected ? colors.primary : colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return l10n.text('theme_dark');
      case AppThemeMode.light:
        return l10n.text('theme_light');
    }
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
    final l10n = context.l10n;
    final gridColumns = context.isWideLayout ? 4 : 2;
    final gridAspectRatio = context.isWideLayout ? 0.92 : 0.72;

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
              l10n.text('no_items_yet'),
              style: TextStyle(color: colors.textSecondary),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: gridAspectRatio,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return _AchievementGridItem(
                  achievement: achievements[index],
                  locale: locale,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AchievementPreviewCard extends StatelessWidget {
  const _AchievementPreviewCard({
    required this.achievement,
    required this.locale,
    required this.onOpen,
  });

  final Achievement achievement;
  final AppLocale locale;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = achievement.unlocked ? colors.success : colors.textSecondary;
    final isWide = context.isWideLayout;

    return Container(
      padding: EdgeInsets.all(isWide ? 12 : 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceSoft,
        border: Border.all(
          color: achievement.unlocked
              ? accent.withValues(alpha: 0.45)
              : colors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isWide ? 16 : 18,
                backgroundColor: accent.withValues(alpha: 0.16),
                child: Icon(
                  achievement.icon,
                  color: accent,
                  size: isWide ? 16 : 18,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 30,
                height: 30,
                child: IconButton(
                  onPressed: onOpen,
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  splashRadius: 18,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textSecondary,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          SizedBox(height: isWide ? 6 : 8),
          Text(
            achievement.title.resolve(locale),
            maxLines: isWide ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: isWide ? 15 : 16,
              height: 1.15,
            ),
          ),
          SizedBox(height: isWide ? 4 : 6),
          Text(
            achievement.description.resolve(locale),
            maxLines: isWide ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11.5,
              height: 1.25,
            ),
          ),
          SizedBox(height: isWide ? 8 : 10),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: achievement.fraction,
              minHeight: 6,
              backgroundColor: colors.backgroundElevated,
              color: accent,
            ),
          ),
          SizedBox(height: isWide ? 6 : 8),
          Text(
            '${achievement.progress}/${achievement.goal}',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificatePreviewCard extends StatelessWidget {
  const _CertificatePreviewCard({
    required this.certificate,
    required this.onTap,
  });

  final CourseCertificate certificate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isWide = context.isWideLayout;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: EdgeInsets.all(isWide ? 14 : 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              certificate.accent.withValues(alpha: 0.2),
              colors.surface,
              colors.surfaceSoft,
            ],
          ),
          border: Border.all(color: certificate.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: certificate.accent,
              size: isWide ? 22 : 20,
            ),
            SizedBox(height: isWide ? 10 : 12),
            Text(
              certificate.title,
              maxLines: isWide ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: isWide ? 16 : 15,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              certificate.recipientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '${context.l10n.text('course_certificate')} • ${_formatDate(certificate.issuedAt)}',
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _AchievementGridItem extends StatelessWidget {
  const _AchievementGridItem({
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
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceSoft,
        border: Border.all(
          color:
              achievement.unlocked ? accent.withValues(alpha: 0.45) : colors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withValues(alpha: 0.16),
            child: Icon(achievement.icon, color: accent, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            achievement.title.resolve(locale),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description.resolve(locale),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: achievement.fraction,
              minHeight: 6,
              backgroundColor: colors.backgroundElevated,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${achievement.progress}/${achievement.goal}',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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
    final l10n = context.l10n;
    final accent = switch (entry.kind) {
      LearningHistoryKind.lessonCompleted => colors.primary,
      LearningHistoryKind.practiceCompleted => colors.accent,
      LearningHistoryKind.moduleCompleted => colors.success,
      LearningHistoryKind.trackCompleted => const Color(0xFFFFD166),
      LearningHistoryKind.assessmentCompleted => colors.success,
      LearningHistoryKind.courseSaved => colors.primary,
      LearningHistoryKind.courseEnrolled => colors.primary,
      LearningHistoryKind.courseCompleted => colors.success,
      LearningHistoryKind.certificateEarned => const Color(0xFFFFD166),
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
                LearningHistoryKind.courseEnrolled => Icons.school_rounded,
                LearningHistoryKind.courseCompleted => Icons.check_circle_rounded,
                LearningHistoryKind.certificateEarned =>
                  Icons.workspace_premium_rounded,
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
                  _historyTitle(l10n, entry.kind),
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

  String _historyTitle(AppLocalizations l10n, LearningHistoryKind kind) {
    switch (kind) {
      case LearningHistoryKind.lessonCompleted:
        return l10n.text('history_lesson_completed');
      case LearningHistoryKind.practiceCompleted:
        return l10n.text('history_practice_completed');
      case LearningHistoryKind.moduleCompleted:
        return l10n.text('history_module_completed');
      case LearningHistoryKind.trackCompleted:
        return l10n.text('history_track_completed');
      case LearningHistoryKind.assessmentCompleted:
        return l10n.text('history_assessment_completed');
      case LearningHistoryKind.courseSaved:
        return l10n.text('history_course_saved');
      case LearningHistoryKind.courseEnrolled:
        return l10n.text('course_enroll_title');
      case LearningHistoryKind.courseCompleted:
        return l10n.text('course_completed');
      case LearningHistoryKind.certificateEarned:
        return l10n.text('course_certificate');
    }
  }

  String _formatHistoryTimestamp(DateTime timestamp) {
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day.$month.${timestamp.year}  $hour:$minute';
  }
}
