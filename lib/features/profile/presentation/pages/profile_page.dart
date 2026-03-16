import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final achievements = catalog.achievementsFor(state);
    final l10n = context.l10n;
    final user = state.user;

    return AppPageScaffold(
      title: l10n.text('profile'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          GlowCard(
            accent: AppColors.primary,
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
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
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _Pill(label: 'XP', value: '${state.xp}'),
                    _Pill(label: 'Level', value: '${state.level}'),
                    _Pill(label: 'Streak', value: '${state.streak}d'),
                  ],
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
                  l10n.text('profile_goal'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.goal ?? 'Reach confident demo flow in 14 days',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.text('locale'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                LocaleSelector(
                  currentLocale: state.locale,
                  onChanged: controller.changeLocale,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: AppColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('achievements'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...achievements.map((achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: (achievement.unlocked ? AppColors.success : AppColors.surfaceSoft)
                                .withValues(alpha: 0.16),
                            child: Icon(
                              achievement.icon,
                              color: achievement.unlocked
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              achievement.title.resolve(state.locale),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${achievement.progress}/${achievement.goal}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )),
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
            label: l10n.text('reset_demo'),
            icon: Icons.restart_alt_rounded,
            onPressed: () {
              controller.resetDemo();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.text('reset_demo'))),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surfaceSoft,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
