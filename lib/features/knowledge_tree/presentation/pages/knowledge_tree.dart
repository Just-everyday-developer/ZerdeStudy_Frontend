import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/theme/app_theme_colors.dart';

class KnowledgeTreePage extends ConsumerWidget {
  const KnowledgeTreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(demoCatalogProvider);
    final state = ref.watch(demoAppControllerProvider);
    final colors = context.appColors;
    final coreCount = _coreBranchIds.length + _mathChildIds.length;
    final appliedCount = _appliedBranchIds.length + _mobileChildIds.length;
    final completed = catalog.totalCompletedUnits(state);

    return AppPageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One unified tree starts from the computer science foundation and grows into applied engineering paths.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FlowPill(
                      label: 'Core',
                      value: '$coreCount nodes',
                      color: colors.primary,
                    ),
                    _FlowPill(
                      label: 'Applied',
                      value: '$appliedCount nodes',
                      color: colors.accent,
                    ),
                    _FlowPill(
                      label: 'Progress',
                      value: '$completed units done',
                      color: colors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Legend(),
          const SizedBox(height: 16),
          const _TreeCanvas(),
        ],
      ),
    );
  }
}

class _TreeCanvas extends ConsumerWidget {
  const _TreeCanvas();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return GlowCard(
      accent: colors.primary,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Column(
                children: [
                  const SizedBox(height: 86),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 8,
                        decoration: BoxDecoration(
                          color: colors.treeTrunk,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: colors.treeTrunkGlow.withValues(alpha: 0.24),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              _RootHeader(
                title: 'Computer Science',
                subtitle:
                    'Base branches first, then applied specializations that grow from them.',
              ),
              const SizedBox(height: 18),
              _TreeStageLabel(label: 'Core branches'),
              const SizedBox(height: 10),
              _BranchGroup(
                trackId: 'mathematics',
                side: _BranchSide.left,
                childTrackIds: _mathChildIds,
              ),
              const SizedBox(height: 10),
              ..._coreBranchIds
                  .where((trackId) => trackId != 'mathematics')
                  .toList(growable: false)
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BranchGroup(
                        trackId: entry.value,
                        side: entry.key.isEven
                            ? _BranchSide.right
                            : _BranchSide.left,
                      ),
                    ),
                  ),
              const SizedBox(height: 10),
              _TreeStageLabel(label: 'Applied branches'),
              const SizedBox(height: 10),
              ..._appliedBranchIds.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BranchGroup(
                        trackId: entry.value,
                        side: entry.key.isEven
                            ? _BranchSide.right
                            : _BranchSide.left,
                        childTrackIds: entry.value == 'mobile'
                            ? _mobileChildIds
                            : const <String>[],
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              Text(
                'Tap any node to open its track overview.',
                style: TextStyle(
                  color: colors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BranchGroup extends ConsumerWidget {
  const _BranchGroup({
    required this.trackId,
    required this.side,
    this.childTrackIds = const <String>[],
  });

  final String trackId;
  final _BranchSide side;
  final List<String> childTrackIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final track = catalog.trackById(trackId);
    final availability = catalog.trackAvailabilityFor(state, track.id);
    final colors = context.appColors;
    final statusColor = _statusColor(colors, availability, track.color);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: side == _BranchSide.left
              ? Align(
                  alignment: Alignment.centerRight,
                  child: _NodeCluster(
                    track: track,
                    statusLabel: _statusLabel(availability),
                    statusColor: statusColor,
                    childTrackIds: childTrackIds,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(
          width: 68,
          child: Row(
            children: [
              if (side == _BranchSide.right) ...[
                Container(width: 34, height: 4, color: colors.treeTrunk),
                Expanded(child: Container()),
              ] else ...[
                Expanded(child: Container()),
                Container(width: 34, height: 4, color: colors.treeTrunk),
              ],
            ],
          ),
        ),
        Expanded(
          child: side == _BranchSide.right
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: _NodeCluster(
                    track: track,
                    statusLabel: _statusLabel(availability),
                    statusColor: statusColor,
                    childTrackIds: childTrackIds,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NodeCluster extends ConsumerWidget {
  const _NodeCluster({
    required this.track,
    required this.statusLabel,
    required this.statusColor,
    required this.childTrackIds,
  });

  final LearningTrack track;
  final String statusLabel;
  final Color statusColor;
  final List<String> childTrackIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final colors = context.appColors;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: Column(
        crossAxisAlignment: track.id == 'backend' ||
                track.id == 'databases' ||
                track.id == 'networking_protocols' ||
                track.id == 'ai_theory' ||
                track.id == 'computer_architecture' ||
                track.id == 'operating_systems' ||
                track.id == 'sre_devops' ||
                track.id == 'system_administration' ||
                track.id == 'qa_engineering' ||
                track.id == 'cybersecurity'
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => context.push(AppRoutes.trackById(track.id)),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: colors.surface,
                border: Border.all(color: statusColor.withValues(alpha: 0.34)),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.14),
                    ),
                    child: Icon(track.icon, color: statusColor, size: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    track.title.resolve(state.locale),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: statusColor.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (childTrackIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: colors.treeTrunk,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: childTrackIds.map((childTrackId) {
                final childTrack = catalog.trackById(childTrackId);
                final availability = catalog.trackAvailabilityFor(
                  state,
                  childTrack.id,
                );
                final childColor = _statusColor(
                  colors,
                  availability,
                  childTrack.color,
                );

                return InkWell(
                  onTap: () => context.push(AppRoutes.trackById(childTrack.id)),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: colors.surfaceSoft,
                      border: Border.all(
                        color: childColor.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(childTrack.icon, color: childColor, size: 18),
                        const SizedBox(height: 6),
                        Text(
                          childTrack.title.resolve(state.locale),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GlowCard(
      accent: colors.success,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _LegendPill(label: 'Available', color: colors.textSecondary),
          _LegendPill(label: 'In progress', color: colors.primary),
          _LegendPill(label: 'Completed', color: colors.success),
          _LegendPill(label: 'Mastered', color: colors.accent),
        ],
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FlowPill extends StatelessWidget {
  const _FlowPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RootHeader extends StatelessWidget {
  const _RootHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surface.withValues(alpha: 0.92),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeStageLabel extends StatelessWidget {
  const _TreeStageLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _BranchSide {
  left,
  right,
}

String _statusLabel(TrackAvailability availability) {
  switch (availability) {
    case TrackAvailability.available:
      return 'Available';
    case TrackAvailability.inProgress:
      return 'In progress';
    case TrackAvailability.completed:
      return 'Completed';
    case TrackAvailability.mastered:
      return 'Mastered';
  }
}

Color _statusColor(
  AppThemeColors colors,
  TrackAvailability availability,
  Color trackColor,
) {
  switch (availability) {
    case TrackAvailability.available:
      return colors.textSecondary;
    case TrackAvailability.inProgress:
      return trackColor;
    case TrackAvailability.completed:
      return colors.success;
    case TrackAvailability.mastered:
      return colors.accent;
  }
}

const List<String> _mathChildIds = <String>[
  'mathematical_analysis',
  'discrete_math',
  'linear_algebra_calculus',
  'probability_statistics_analytics',
];

const List<String> _coreBranchIds = <String>[
  'mathematics',
  'databases',
  'algorithms_data_structures',
  'networking_protocols',
  'ai_theory',
  'computer_architecture',
  'information_security_foundations',
  'operating_systems',
];

const List<String> _mobileChildIds = <String>[
  'android_development',
  'ios_development',
  'crossplatform_development',
];

const List<String> _appliedBranchIds = <String>[
  'frontend',
  'backend',
  'mobile',
  'sre_devops',
  'system_administration',
  'machine_learning',
  'qa_engineering',
  'cybersecurity',
];
