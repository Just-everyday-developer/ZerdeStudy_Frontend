import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/app_theme_mode.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({
    super.key,
    this.enableShellAvatarHero = false,
  });

  final bool enableShellAvatarHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final l10n = context.l10n;
    final achievements = catalog.achievementsFor(state);
    final unlocked =
        achievements.where((item) => item.unlocked).toList(growable: false);
    final previewAchievements = achievements.take(6).toList(growable: false);
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
    final compact = context.isCompactLayout;

    return AppPageScaffold(
      horizontalPadding: compact ? 0 : null,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 0,
          compact ? 6 : 8,
          compact ? 16 : 0,
          compact ? 104 : 120,
        ),
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 18 : 22),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileAvatar(
                            enableHero: enableShellAvatarHero,
                            size: 108,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Dana S.',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontSize: 28),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user?.email ?? 'demo@zerdestudy.app',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _Pill(label: 'XP', value: '${state.xp}')),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Pill(
                              label: l10n.text('level'),
                              value: '${state.level}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Pill(
                              label: l10n.text('streak'),
                              value: '${state.streak}d',
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ProfileAvatar(
                        enableHero: enableShellAvatarHero,
                        size: 108,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              children: [
                                _Pill(label: 'XP', value: '${state.xp}'),
                                _Pill(
                                  label: l10n.text('level'),
                                  value: '${state.level}',
                                ),
                                _Pill(
                                  label: l10n.text('streak'),
                                  value: '${state.streak}d',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.text('locale'),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LocaleSelector(
                            currentLocale: state.locale,
                            onChanged: controller.changeLocale,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.text('theme'),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: AppThemeMode.values.map((mode) {
                              final selected = mode == state.themeMode;
                              return ChoiceChip(
                                label: Text(_themeModeLabel(l10n, mode)),
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
                    ],
                  ),
          ),
          SizedBox(height: compact ? 14 : 16),
          GlowCard(
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionPanelHeader(
                  title: l10n.text('achievements'),
                  subtitle:
                      '${unlocked.length}/${achievements.length} ${l10n.text('unlocked').toLowerCase()}',
                  icon: Icons.workspace_premium_rounded,
                  accent: colors.success,
                  onOpen: () =>
                      _showAchievementsSheet(context, achievements, state.locale),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: compact ? 198 : context.isWideLayout ? 168 : 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: previewAchievements.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: compact
                            ? 184
                            : context.isWideLayout
                                ? 220
                                : 206,
                        child: _AchievementPreviewCard(
                          achievement: previewAchievements[index],
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
          SizedBox(height: compact ? 14 : 16),
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionPanelHeader(
                  title: l10n.text('certificates'),
                  subtitle: l10n.text('certificates_hint'),
                  icon: Icons.workspace_premium_rounded,
                  accent: colors.primary,
                  onOpen: certificates.isEmpty
                      ? null
                      : () => _showCertificatesSheet(context, certificates),
                ),
                const SizedBox(height: 14),
                if (certificates.isEmpty)
                  Text(
                    l10n.text('no_items_yet'),
                    style: TextStyle(color: colors.textSecondary),
                  )
                else
                  SizedBox(
                    height: compact ? 196 : context.isWideLayout ? 178 : 188,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: certificates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final certificate = certificates[index];
                        return SizedBox(
                          width: compact
                              ? 212
                              : context.isWideLayout
                                  ? 260
                                  : 228,
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
          SizedBox(height: compact ? 14 : 16),
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionPanelHeader(
                  title: l10n.text('favorites'),
                  subtitle:
                      '${favorites.length} ${l10n.text('saved').toLowerCase()}',
                  icon: Icons.bookmark_rounded,
                  accent: colors.primary,
                  onOpen: favorites.isEmpty
                      ? null
                      : () => _showFavoritesSheet(
                            context,
                            favorites,
                            state,
                            catalog,
                          ),
                ),
                const SizedBox(height: 14),
                if (favorites.isEmpty)
                  Text(
                    l10n.text('favorites_empty'),
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  )
                else
                  SizedBox(
                    height: compact ? 196 : context.isWideLayout ? 176 : 188,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final course = favorites[index];
                        return SizedBox(
                          width: compact ? 224 : 248,
                          child: _FavoritePreviewCard(
                            course: course,
                            subtitle:
                                '${course.author.name} / ${l10n.courseLevelLabel(course.level)} / ${catalog.displayCourseRatingFor(state, course.id).toStringAsFixed(1)}',
                            onTap: () => context.push(
                              AppRoutes.courseById(course.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Pill(
                        label: l10n.text('tracks'),
                        value: '${completedTracks.length}',
                      ),
                      const SizedBox(width: 10),
                      _Pill(
                        label: l10n.text('modules'),
                        value: '${completedModules.length}',
                      ),
                      const SizedBox(width: 10),
                      _Pill(
                        label: l10n.text('lessons'),
                        value: '${completedLessons.length}',
                      ),
                      const SizedBox(width: 10),
                      _Pill(
                        label: l10n.text('practices'),
                        value: '${completedPractices.length}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (completedTracks.isNotEmpty)
                  ...completedTracks.take(3).map(
                        (track) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProfileLinkTile(
                            title: track.title.resolve(state.locale),
                            subtitle:
                                '${l10n.text('tree_assessments')} ${catalog.bestAssessmentPercentFor(state, track.id)}% - ${catalog.progressForTrack(state, track.id).completedUnits}/${track.totalUnits} ${l10n.text('tree_units')}',
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
          SizedBox(height: compact ? 14 : 16),
          GlowCard(
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionPanelHeader(
                  title: l10n.text('result_history'),
                  subtitle: history.isEmpty
                      ? l10n.text('result_history_empty')
                      : '${history.length} ${l10n.text('result_history').toLowerCase()}',
                  icon: Icons.history_rounded,
                  accent: colors.success,
                  onOpen:
                      history.isEmpty ? null : () => _showHistorySheet(context, history),
                ),
                const SizedBox(height: 14),
                AppButton.secondary(
                  label: l10n.text('open_history'),
                  icon: Icons.receipt_long_rounded,
                  onPressed:
                      history.isEmpty ? null : () => _showHistorySheet(context, history),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
            onPressed: () async {
              final error = await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) {
                return;
              }
              if (error != null) {
                AppNotice.show(
                  context,
                  message: error,
                  type: AppNoticeType.error,
                );
                return;
              }
              context.go(AppRoutes.welcome);
            },
          ),
        ],
      ),
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
          child: Column(
            children: [
              const AdaptivePanelHandle(),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('achievements'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${unlocked.length} ${l10n.text('unlocked').toLowerCase()} - ${locked.length} ${l10n.text('locked').toLowerCase()}',
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCertificatesSheet(
    BuildContext context,
    List<CourseCertificate> certificates,
  ) {
    showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 720,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              const AdaptivePanelHandle(),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: certificates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final certificate = certificates[index];
                    return _ProfileLinkTile(
                      title: certificate.title,
                      subtitle:
                          '${certificate.recipientName} - ${_formatDate(certificate.issuedAt)}',
                      accent: certificate.accent,
                      icon: Icons.workspace_premium_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.courseById(certificate.courseId));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFavoritesSheet(
    BuildContext context,
    List<CommunityCourse> favorites,
    DemoAppState state,
    DemoCatalog catalog,
  ) {
    showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 760,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              const AdaptivePanelHandle(),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final course = favorites[index];
                    return _ProfileLinkTile(
                      title: course.title.en,
                      subtitle:
                          '${course.author.name} - ${context.l10n.courseLevelLabel(course.level)} - ${catalog.displayCourseRatingFor(state, course.id).toStringAsFixed(1)}',
                      accent: course.color,
                      icon: Icons.bookmark_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.courseById(course.id));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHistorySheet(
    BuildContext context,
    List<LearningHistoryEntry> history,
  ) {
    showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 760,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              const AdaptivePanelHandle(),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _HistoryTile(entry: history[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _SectionPanelHeader extends StatelessWidget {
  const _SectionPanelHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onOpen,
          icon: Icon(icon, color: accent),
          label: Text(
            context.l10n.text('show_all'),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
    final l10n = context.l10n;
    final gridColumns = context.isWideLayout ? 4 : 2;
    final gridAspectRatio = context.isWideLayout ? 0.96 : 0.8;

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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.15,
              fontSize: isWide ? 15 : 16,
            ),
          ),
          SizedBox(height: isWide ? 4 : 6),
          Text(
            achievement.description.resolve(locale),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11.5,
              height: 1.25,
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
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: certificate.accent,
                    size: isWide ? 22 : 20,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textSecondary,
                  ),
                ],
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
              '${context.l10n.text('course_certificate')} - ${_formatDate(certificate.issuedAt)}',
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

class _FavoritePreviewCard extends StatelessWidget {
  const _FavoritePreviewCard({
    required this.course,
    required this.subtitle,
    required this.onTap,
  });

  final CommunityCourse course;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: colors.surfaceSoft,
          border: Border.all(color: course.color.withValues(alpha: 0.24)),
        ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: course.color.withValues(alpha: 0.16),
                    child: Icon(
                      Icons.bookmark_rounded,
                      color: course.color,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              course.title.en,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.enableHero,
    required this.size,
  });

  final bool enableHero;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.14),
      ),
      child: Icon(
        Icons.person_rounded,
        color: colors.primary,
        size: size * 0.48,
      ),
    );

    if (!enableHero) {
      return avatar;
    }

    return Hero(
      tag: 'shell-profile-avatar',
      child: avatar,
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
                  ].join('  -  '),
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

String _themeModeLabel(AppLocalizations l10n, AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.dark => l10n.text('theme_dark'),
    AppThemeMode.light => l10n.text('theme_light'),
  };
}
