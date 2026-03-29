import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final entries = ref.watch(demoCatalogProvider).leaderboardFor(state);
    final podium = entries.take(3).toList(growable: false);
    final rest = entries.skip(3).toList(growable: false);
    final colors = context.appColors;
    final compact = context.isCompactLayout;

    return AppPageScaffold(
      title: compact ? context.l10n.text('leaderboard') : null,
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, compact ? 6 : 8, 0, 40),
        children: [
          if (podium.length == 3)
            GlowCard(
              accent: colors.primary,
              child: SizedBox(
                height: compact ? 188 : 300,
                child: compact
                    ? _CompactPodium(entries: podium)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _PodiumColumn(
                              entry: podium[1],
                              rank: 2,
                              heightFactor: 0.72,
                            ),
                          ),
                          Expanded(
                            child: _PodiumColumn(
                              entry: podium[0],
                              rank: 1,
                              heightFactor: 1,
                            ),
                          ),
                          Expanded(
                            child: _PodiumColumn(
                              entry: podium[2],
                              rank: 3,
                              heightFactor: 0.58,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          SizedBox(height: compact ? 14 : 18),
          ...rest.asMap().entries.map((item) {
            final rank = item.key + 4;
            final entry = item.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                accent: entry.isCurrentUser ? colors.primary : colors.divider,
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (entry.isCurrentUser
                                    ? colors.primary
                                    : colors.surfaceSoft)
                                .withValues(alpha: 0.18),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            color: entry.isCurrentUser
                                ? colors.primary
                                : colors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level ${entry.level}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                          if (entry.isCurrentUser) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Tag(label: context.l10n.text('you_label')),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '${entry.xp} XP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _CompactPodium extends StatelessWidget {
  const _CompactPodium({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _CompactPodiumColumn(
            entry: entries[1],
            rank: 2,
            heightFactor: 0.7,
          ),
        ),
        Expanded(
          child: _CompactPodiumColumn(
            entry: entries[0],
            rank: 1,
            heightFactor: 1,
          ),
        ),
        Expanded(
          child: _CompactPodiumColumn(
            entry: entries[2],
            rank: 3,
            heightFactor: 0.58,
          ),
        ),
      ],
    );
  }
}

class _CompactPodiumColumn extends StatelessWidget {
  const _CompactPodiumColumn({
    required this.entry,
    required this.rank,
    required this.heightFactor,
  });

  final LeaderboardEntry entry;
  final int rank;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = switch (rank) {
      1 => const Color(0xFFFFD166),
      2 => const Color(0xFFAEC5E6),
      _ => const Color(0xFFFFB38A),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                entry.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1.05,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 12,
            child: Center(
              child: Text(
                'Level ${entry.level}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                widthFactor: 0.86,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withValues(alpha: 0.92),
                        accent.withValues(alpha: 0.28),
                      ],
                    ),
                    border: Border.all(color: accent.withValues(alpha: 0.7)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '#$rank',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.xp} XP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textPrimary.withValues(alpha: 0.94),
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.entry,
    required this.rank,
    required this.heightFactor,
  });

  final LeaderboardEntry entry;
  final int rank;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = switch (rank) {
      1 => const Color(0xFFFFD166),
      2 => const Color(0xFFAEC5E6),
      _ => const Color(0xFFFFB38A),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Level ${entry.level}',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                widthFactor: 0.86,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withValues(alpha: 0.92),
                        accent.withValues(alpha: 0.28),
                      ],
                    ),
                    border: Border.all(color: accent.withValues(alpha: 0.7)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '#$rank',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${entry.xp} XP',
                          style: TextStyle(
                            color: colors.textPrimary.withValues(alpha: 0.94),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceSoft,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
