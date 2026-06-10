import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/app_settings_panel.dart';
import '../../../../core/common_widgets/app_user_avatar.dart';
import '../../../../core/common_widgets/bubble_progress_bar.dart';
import '../../../../core/common_widgets/notification_bell_button.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../app_guide/presentation/app_guide_controller.dart';
import '../../../app_guide/presentation/app_guide_copy.dart';
import '../../../app_guide/presentation/app_guide_target.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';

/// Patches Minio/gateway URLs that contain 127.0.0.1 so they work on device.
String? _patchMediaUrl(String? url, String gatewayBase) {
  if (url == null || url.isEmpty || kIsWeb) return url;
  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  final host = uri.host;
  if (host != '127.0.0.1' && host != 'localhost') return url;
  final gatewayHost = Uri.tryParse(gatewayBase)?.host ?? host;
  if (gatewayHost == host) return url;
  return url.replaceFirst('$host:${uri.port}', '$gatewayHost:${uri.port}');
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, this.enableShellAvatarHero = false});

  final bool enableShellAvatarHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final backendProfile = ref
        .watch(backendProfileProvider)
        .maybeWhen(data: (p) => p, orElse: () => null);
    // XP, level, streak, max_streak — prefer server values; local state is fallback.
    final effectiveXp = backendProfile?.xp ?? state.xp;
    final effectiveLevel = backendProfile?.level ?? state.level;
    final effectiveStreak = backendProfile?.streak ?? state.streak;
    final effectiveMaxStreak = backendProfile?.maxStreak ?? state.maxStreak;
    final catalog = ref.watch(demoCatalogProvider);
    final l10n = context.l10n;
    // Prefer server-computed achievements; fall back to local demo data when
    // unauthenticated, loading, or the backend returns nothing.
    final backendAchievements = ref
        .watch(backendAchievementsProvider)
        .maybeWhen(
          data: (list) => list,
          orElse: () => const <Achievement>[],
        );
    final achievements = backendAchievements.isNotEmpty
        ? backendAchievements
        : catalog.achievementsFor(state);
    final unlocked = achievements
        .where((item) => item.unlocked)
        .toList(growable: false);
    final previewAchievements = achievements.take(6).toList(growable: false);
    final certificates = catalog.certificatesFor(state);
    // favorites removed — no backend endpoint; section hidden in UI.
    final completedTracks = catalog.completedTracksFor(state);
    final completedModules = catalog.completedModulesFor(state);
    final completedLessons = catalog.completedLessonsFor(state);
    final completedPractices = catalog.completedPracticesFor(state);
    final user = state.user;

    // Prefer backend profile data (login, bio, photoUrl) over local state.
    // This ensures name/bio survive app restarts by reading from the server.
    final backendLogin = (backendProfile?.login ?? '').trim();
    final backendBio   = (backendProfile?.bio ?? '').trim();
    final effectiveDisplayName = backendLogin.isNotEmpty
        ? backendLogin
        : (user?.name ?? '').trim().isNotEmpty
            ? user!.name
            : 'User';
    final effectiveBio = backendBio.isNotEmpty ? backendBio : (user?.bio ?? '');

    // Sync server profile to local DemoUser when backend data is fresher.
    // addPostFrameCallback avoids calling setState during build.
    if (backendProfile != null && backendLogin.isNotEmpty) {
      final localName = (user?.name ?? '').trim();
      if (localName != backendLogin || effectiveBio != (user?.bio ?? '')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ref.read(demoAppControllerProvider.notifier).updateProfile(
                  name: backendLogin,
                  bio: backendBio,
                );
          }
        });
      }
    }

    final displayName = effectiveDisplayName;
    final email = (backendProfile?.email ?? '').isNotEmpty
        ? backendProfile!.email
        : (user?.email ?? 'user@zerdestudy.app');
    final colors = context.appColors;
    final compact = context.isCompactLayout;

    // Patch Minio photo URL: on device 127.0.0.1 is the phone's own loopback.
    final gatewayBase = ref.read(appEnvironmentProvider).gatewayBaseUrl;
    final effectivePhotoUrl = _patchMediaUrl(backendProfile?.photoUrl, gatewayBase);

    // Build the effective DemoUser for the edit dialog (server values + local avatar).
    final effectiveUserForEdit = user?.copyWith(
          name: effectiveDisplayName,
          bio: effectiveBio,
        ) ?? DemoUser(
          name: effectiveDisplayName,
          email: email,
          role: 'student',
          goal: 'learning',
          bio: effectiveBio,
        );

    void openProfileEditor() {
      _showEditProfileDialog(context, ref, effectiveUserForEdit, effectivePhotoUrl);
    }

    return AppPageScaffold(
      title: l10n.text('profile'),
      actions: [
        IconButton(
          tooltip: l10n.text('view_stats'),
          icon: Icon(Icons.insights_rounded, color: colors.primary),
          onPressed: () => context.push(AppRoutes.stats),
        ),
        if (compact) const NotificationBellButton(),
        AppGuideTarget(
          id: AppGuideTargetIds.profileSettings,
          child: IconButton(
            tooltip: AppGuideCopy.openSettingsLabel(context),
            icon: Icon(Icons.settings_rounded, color: colors.textSecondary),
            onPressed: () => showAppSettingsPanel(context),
          ),
        ),
        IconButton(
          tooltip: l10n.text('logout'),
          icon: Icon(Icons.logout_rounded, color: colors.danger),
          onPressed: () async {
            final error = await ref
                .read(authControllerProvider.notifier)
                .logout();
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
        const SizedBox(width: 8),
      ],
      horizontalPadding: compact ? 0 : null,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 0,
          compact ? 6 : 8,
          compact ? 16 : 0,
          compact ? 104 : 120,
        ),
        children: [
          AppGuideTarget(
            id: AppGuideTargetIds.profileHeader,
            child: Container(
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final headerCompact = compact || constraints.maxWidth < 560;

                  if (headerCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // — Avatar + name row —
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _EditableProfileAvatar(
                              user: user,
                              photoUrl: effectivePhotoUrl,
                              enableHero: enableShellAvatarHero,
                              size: 88,
                              onTap: openProfileEditor,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontSize: 26, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    email,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // — Bio (full width, below avatar row) —
                        if (effectiveBio.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.surfaceSoft,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.divider.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.format_quote_rounded, color: colors.primary.withValues(alpha: 0.6), size: 16),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    effectiveBio,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // — Edit button (full width on mobile) —
                        const SizedBox(height: 16),
                        AppButton.secondary(
                          label: l10n.text('profile_edit'),
                          icon: Icons.edit_rounded,
                          onPressed: openProfileEditor,
                        ),
                        const SizedBox(height: 20),
                        // — Stats pills —
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Pill(label: 'XP', value: '$effectiveXp'),
                            _Pill(label: l10n.text('level'), value: '$effectiveLevel'),
                            _Pill(label: l10n.text('streak'), value: '${effectiveStreak}d'),
                            _Pill(
                              label: l10n.locale == AppLocale.ru
                                  ? 'Макс. серия'
                                  : (l10n.locale == AppLocale.kk ? 'Макс. серия' : 'Max Streak'),
                              value: '${effectiveMaxStreak}d',
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _EditableProfileAvatar(
                        user: user,
                        photoUrl: effectivePhotoUrl,
                        enableHero: enableShellAvatarHero,
                        size: 108,
                        onTap: openProfileEditor,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              style: TextStyle(color: colors.textSecondary),
                            ),
                            if (user != null && user.bio.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.surfaceSoft,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: colors.divider.withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.format_quote_rounded, color: colors.primary.withValues(alpha: 0.6), size: 16),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        user.bio,
                                        style: TextStyle(
                                          color: colors.textPrimary,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            AppButton.secondary(
                              label: l10n.text('profile_edit'),
                              icon: Icons.edit_rounded,
                              maxWidth: 220,
                              onPressed: openProfileEditor,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _Pill(label: 'XP', value: '$effectiveXp'),
                                _Pill(
                                  label: l10n.text('level'),
                                  value: '$effectiveLevel',
                                ),
                                _Pill(
                                  label: l10n.text('streak'),
                                  value: '${effectiveStreak}d',
                                ),
                                _Pill(
                                  label: l10n.locale == AppLocale.ru ? 'Макс. серия' : (l10n.locale == AppLocale.kk ? 'Макс. серия' : 'Max Streak'),
                                  value: '${effectiveMaxStreak}d',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionPanelHeader(
                  title: l10n.text('achievements'),
                  subtitle:
                      '${unlocked.length}/${achievements.length} ${l10n.text('unlocked').toLowerCase()}',
                  icon: Icons.workspace_premium_rounded,
                  accent: colors.success,
                  onOpen: () => _showAchievementsSheet(
                    context,
                    achievements,
                    state.locale,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: compact
                      ? 220
                      : context.isWideLayout
                      ? 210
                      : 215,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
            ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/empty_box.svg',
                            width: 64,
                            height: 64,
                            colorFilter: ColorFilter.mode(colors.textSecondary.withValues(alpha: 0.5), BlendMode.srcIn),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.text('no_items_yet'),
                            style: TextStyle(color: colors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: compact
                        ? 196
                        : context.isWideLayout
                        ? 178
                        : 188,
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
          // Favorites section hidden — no backend endpoint for saved courses.
          // TODO: implement when backend supports it.

          SizedBox(height: compact ? 14 : 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
            ),
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
                  ...completedTracks
                      .take(3)
                      .map(
                        (track) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProfileLinkTile(
                            title: track.title.resolve(state.locale),
                            subtitle:
                                '${l10n.text('tree_assessments')} ${catalog.bestAssessmentPercentFor(state, track.id)}% - ${catalog.progressForTrack(state, track.id).completedUnits}/${track.totalUnits} ${l10n.text('tree_units')}',
                            accent: track.color,
                            icon: Icons.check_circle_rounded,
                            onTap: () =>
                                context.push(AppRoutes.trackById(track.id)),
                          ),
                        ),
                      )
                else
                  Text(
                    l10n.text('completed_empty'),
                    style: TextStyle(color: colors.textSecondary, height: 1.4),
                  ),
              ],
            ),
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
    final unlocked = achievements
        .where((item) => item.unlocked)
        .toList(growable: false);
    final locked = achievements
        .where((item) => !item.unlocked)
        .toList(growable: false);
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
                        context.push(
                          AppRoutes.courseById(certificate.courseId),
                        );
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

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

Future<void> _showEditProfileDialog(
  BuildContext context,
  WidgetRef ref,
  DemoUser? user,
  String? backendPhotoUrl,
) async {
  final result = await showDialog<_ProfileEditorResult>(
    context: context,
    builder: (dialogContext) => _EditProfileDialog(
      initialName: user?.name ?? 'Talgat O.',
      initialEmail: user?.email ?? 'tomyrkanov@gmail.com',
      initialBio: user?.bio ?? '',
      initialAvatarBase64: user?.avatarBase64,
      initialPhotoUrl: backendPhotoUrl,
    ),
  );

  if (!context.mounted || result == null) return;

  final error = await ref.read(authControllerProvider.notifier).updateProfile(
        name: result.name,
        bio: result.bio,
        avatarBase64: result.avatarBase64,
      );

  if (!context.mounted) return;

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    return;
  }

  ref.invalidate(backendProfileProvider);
  ref
      .read(demoAppControllerProvider.notifier)
      .updateProfile(name: result.name, bio: result.bio, avatarBase64: result.avatarBase64);

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.text('profile_updated'))));
}

class _EditableProfileAvatar extends StatelessWidget {
  const _EditableProfileAvatar({
    required this.user,
    this.photoUrl,
    required this.enableHero,
    required this.size,
    required this.onTap,
  });

  final DemoUser? user;
  final String? photoUrl;
  final bool enableHero;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AppUserAvatar(
            name: user?.name ?? 'Talgat O.',
            avatarBase64: user?.avatarBase64,
            photoUrl: photoUrl,
            size: size,
            enableHero: enableHero,
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
                border: Border.all(color: colors.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditorResult {
  const _ProfileEditorResult({
    required this.name,
    required this.bio,
    required this.avatarBase64,
  });

  final String name;
  final String bio;
  final String? avatarBase64;
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.initialName,
    required this.initialEmail,
    required this.initialBio,
    required this.initialAvatarBase64,
    this.initialPhotoUrl,
  });

  final String initialName;
  final String initialEmail;
  final String initialBio;
  final String? initialAvatarBase64;
  /// Presigned photo URL from backend — shown when no local avatar is selected.
  final String? initialPhotoUrl;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late String? _avatarBase64;
  bool _localAvatarSelected = false;
  bool _isPickingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
    _avatarBase64 = widget.initialAvatarBase64;
  }


  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    setState(() => _isPickingAvatar = true);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || picked == null || picked.files.isEmpty) return;
      final bytes = picked.files.single.bytes;
      if (bytes == null || bytes.isEmpty) { _showAvatarError(); return; }
      final decoded = img.decodeImage(bytes);
      if (decoded == null) { _showAvatarError(); return; }
      final squareSize = math.min(decoded.width, decoded.height);
      final cropped = img.copyCrop(
        decoded,
        x: (decoded.width - squareSize) ~/ 2,
        y: (decoded.height - squareSize) ~/ 2,
        width: squareSize,
        height: squareSize,
      );
      final resized = img.copyResize(cropped, width: 320, height: 320);
      setState(() {
        _avatarBase64 = base64Encode(Uint8List.fromList(img.encodeJpg(resized, quality: 82)));
        _localAvatarSelected = true;
      });
    } catch (_) {
      if (mounted) _showAvatarError();
    } finally {
      if (mounted) setState(() => _isPickingAvatar = false);
    }
  }

  void _showAvatarError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.text('profile_avatar_error'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final trimmedName = _nameController.text.trim();
    final canSave = trimmedName.isNotEmpty && !_isPickingAvatar;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.text('profile_edit_title'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: AppUserAvatar(
                      name: trimmedName.isEmpty ? widget.initialName : trimmedName,
                      avatarBase64: _avatarBase64,
                      photoUrl: _localAvatarSelected ? null : widget.initialPhotoUrl,
                      size: 96,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isPickingAvatar ? null : _pickAvatar,
                          icon: const Icon(Icons.photo_library_rounded),
                          label: Text(context.l10n.text('profile_avatar_pick')),
                        ),
                        if (_avatarBase64 != null)
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _avatarBase64 = null),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text(context.l10n.text('profile_avatar_remove')),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: context.l10n.text('profile_name_label'),
                      hintText: context.l10n.text('profile_name_hint'),
                      helperText: widget.initialEmail,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _bioController,
                    maxLength: 255,
                    maxLines: 3,
                    minLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself...',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(context.l10n.text('profile_cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: canSave
                              ? () => Navigator.of(context).pop(
                                  _ProfileEditorResult(
                                    name: trimmedName,
                                    bio: _bioController.text.trim(),
                                    avatarBase64: _avatarBase64,
                                  ),
                                )
                              : null,
                          child: _isPickingAvatar
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2),
                                )
                              : Text(context.l10n.text('profile_save')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
        borderRadius: BorderRadius.circular(16),
        color: achievement.unlocked
            ? colors.success.withValues(alpha: 0.08)
            : colors.surfaceSoft,
        border: Border.all(
          color: achievement.unlocked
              ? colors.success.withValues(alpha: 0.3)
              : colors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(achievement.icon, color: accent, size: 24),
          const Spacer(),
          Text(
            achievement.title.resolve(locale),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: achievement.fraction,
            backgroundColor: colors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            '${achievement.progress}/${achievement.goal}',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
              Text(title, style: Theme.of(context).textTheme.titleLarge),
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
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
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
    final gridAspectRatio = context.isWideLayout ? 0.82 : 0.75;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: accent, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (achievements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/trophy.svg',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.text('no_items_yet'),
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
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
          SizedBox(height: isWide ? 4 : 6),
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
          SizedBox(height: isWide ? 3 : 4),
          Text(
            achievement.description.resolve(locale),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: isWide ? 11 : 11.5,
              height: 1.2,
            ),
          ),
          const Spacer(),
          BubbleProgressBar(
            value: achievement.fraction,
            height: 6,
            backgroundColor: colors.backgroundElevated,
            color: accent,
          ),
          SizedBox(height: isWide ? 4 : 6),
          Text(
            '${achievement.progress}/${achievement.goal}',
            style: TextStyle(
              color: accent, 
              fontWeight: FontWeight.w700,
              fontSize: isWide ? 12 : 13,
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
                Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
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
              style: TextStyle(color: colors.textSecondary, height: 1.35),
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
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
                    style: TextStyle(color: colors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}


