import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final entries = ref.watch(demoCatalogProvider).leaderboardFor(state);
    final l10n = context.l10n;

    return AppPageScaffold(
      title: l10n.text('leaderboard'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: AppColors.primary,
            child: Text(
              'A richer local leaderboard makes demo engagement visible: level, role, focus branch, and current-user highlighting all update from mock state.',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          ...entries.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            final accent = item.isCurrentUser ? AppColors.primary : AppColors.divider;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                accent: accent,
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (item.isCurrentUser ? AppColors.primary : AppColors.surfaceSoft).withValues(alpha: 0.18),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: item.isCurrentUser ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Level ${item.level} • ${item.role}', style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Tag(label: item.focus),
                              if (item.isCurrentUser) const _Tag(label: 'You'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text('${item.xp} XP', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.surfaceSoft,
      ),
      child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    );
  }
}
