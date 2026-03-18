import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../widgets/skill_node.dart';
import '../widgets/tree_painter.dart';

class KnowledgeTreePage extends ConsumerWidget {
  const KnowledgeTreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(demoCatalogProvider);
    final coreCount = _treeNodeSpecs.keys
        .where(
          (id) => catalog.trackById(id).zone == TrackZone.computerScienceCore,
        )
        .length;
    final appliedCount = _treeNodeSpecs.keys
        .where((id) => catalog.trackById(id).zone == TrackZone.itSpheres)
        .length;

    return AppPageScaffold(
      title: context.l10n.text('knowledge_tree'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          GlowCard(
            accent: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The knowledge map now grows like a real tree: the trunk holds core computer science, the first large branches carry the foundational disciplines, and higher branches specialize into engineering roles.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FlowPill(
                      label: 'CS Core',
                      value: '$coreCount branches',
                      color: AppColors.primary,
                    ),
                    _FlowPill(
                      label: 'Applied Roles',
                      value: '$appliedCount branches',
                      color: AppColors.accent,
                    ),
                    _FlowPill(
                      label: 'Map Size',
                      value: '${_treeNodeSpecs.length} interactive nodes',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Legend(),
          const SizedBox(height: 16),
          const SizedBox(
            height: 760,
            child: _OrganicKnowledgeTree(),
          ),
        ],
      ),
    );
  }
}

class _OrganicKnowledgeTree extends ConsumerWidget {
  const _OrganicKnowledgeTree();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final size = const Size(1860, 1400);

    final connections = <List<Offset>>[
      for (final link in _treeLinks)
        if (_treeNodeSpecs.containsKey(link.$1) &&
            _treeNodeSpecs.containsKey(link.$2))
          <Offset>[
            _treeNodeSpecs[link.$1]!.center,
            _treeNodeSpecs[link.$2]!.center,
          ],
    ];

    return GlowCard(
      accent: AppColors.primary,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(24),
          minScale: 0.24,
          maxScale: 2.2,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: TreePainter(
                    connections: connections,
                    trunkPaths: _trunkPaths,
                  ),
                ),
                const Positioned(
                  left: 720,
                  top: 1040,
                  child: _TreeLabel(
                    title: 'Computer Science Roots',
                    subtitle:
                        'Math, databases, algorithms, networks, AI theory, architecture, security, and OS',
                  ),
                ),
                const Positioned(
                  left: 700,
                  top: 360,
                  child: _TreeLabel(
                    title: 'Applied Engineering Branches',
                    subtitle:
                        'Frontend, backend, mobile, DevOps / SRE, system administration, ML, QA, and cybersecurity',
                  ),
                ),
                ..._treeNodeSpecs.entries.map((entry) {
                  final track = catalog.trackById(entry.key);
                  final availability = catalog.trackAvailabilityFor(
                    state,
                    track.id,
                  );
                  final spec = entry.value;

                  return SkillNode(
                    label: track.title.resolve(state.locale),
                    icon: track.icon,
                    color: _statusColor(availability, track.color),
                    statusLabel: _statusLabel(availability),
                    offset: spec.offset,
                    diameter: spec.diameter,
                    labelWidth: spec.labelWidth,
                    onTap: () => context.push(AppRoutes.trackById(track.id)),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
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

  Color _statusColor(TrackAvailability availability, Color trackColor) {
    switch (availability) {
      case TrackAvailability.available:
        return AppColors.textSecondary;
      case TrackAvailability.inProgress:
        return trackColor;
      case TrackAvailability.completed:
        return AppColors.success;
      case TrackAvailability.mastered:
        return AppColors.accent;
    }
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: AppColors.success,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          _LegendPill(label: 'Available', color: AppColors.textSecondary),
          _LegendPill(label: 'In progress', color: AppColors.primary),
          _LegendPill(label: 'Completed', color: AppColors.success),
          _LegendPill(label: 'Mastered', color: AppColors.accent),
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
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TreeLabel extends StatelessWidget {
  const _TreeLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 430,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface.withValues(alpha: 0.88),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeNodeSpec {
  const _TreeNodeSpec({
    required this.offset,
    this.diameter = 88,
    this.labelWidth = 124,
  });

  final Offset offset;
  final double diameter;
  final double labelWidth;

  Offset get center => offset + Offset(diameter / 2, diameter / 2);
}

const Map<String, _TreeNodeSpec> _treeNodeSpecs = <String, _TreeNodeSpec>{
  'mathematics': _TreeNodeSpec(
    offset: Offset(150, 720),
    diameter: 106,
    labelWidth: 150,
  ),
  'mathematical_analysis': _TreeNodeSpec(offset: Offset(20, 510), diameter: 82),
  'discrete_math': _TreeNodeSpec(offset: Offset(170, 340), diameter: 82),
  'linear_algebra_calculus': _TreeNodeSpec(
    offset: Offset(320, 510),
    diameter: 82,
  ),
  'probability_statistics_analytics': _TreeNodeSpec(
    offset: Offset(470, 340),
    diameter: 82,
    labelWidth: 132,
  ),
  'algorithms_data_structures': _TreeNodeSpec(
    offset: Offset(560, 810),
    diameter: 94,
    labelWidth: 144,
  ),
  'databases': _TreeNodeSpec(offset: Offset(780, 680), diameter: 92),
  'networking_protocols': _TreeNodeSpec(
    offset: Offset(1030, 630),
    diameter: 92,
    labelWidth: 136,
  ),
  'ai_theory': _TreeNodeSpec(offset: Offset(1240, 820), diameter: 94),
  'computer_architecture': _TreeNodeSpec(
    offset: Offset(1460, 950),
    diameter: 92,
    labelWidth: 136,
  ),
  'information_security_foundations': _TreeNodeSpec(
    offset: Offset(1560, 630),
    diameter: 92,
    labelWidth: 136,
  ),
  'operating_systems': _TreeNodeSpec(offset: Offset(1720, 790), diameter: 96),
  'qa_engineering': _TreeNodeSpec(
    offset: Offset(220, 140),
    diameter: 90,
    labelWidth: 132,
  ),
  'frontend': _TreeNodeSpec(offset: Offset(470, 160), diameter: 92),
  'backend': _TreeNodeSpec(offset: Offset(790, 170), diameter: 94),
  'machine_learning': _TreeNodeSpec(
    offset: Offset(990, 80),
    diameter: 96,
    labelWidth: 136,
  ),
  'mobile': _TreeNodeSpec(
    offset: Offset(1130, 260),
    diameter: 102,
    labelWidth: 132,
  ),
  'android_development': _TreeNodeSpec(
    offset: Offset(980, 0),
    diameter: 78,
    labelWidth: 118,
  ),
  'ios_development': _TreeNodeSpec(
    offset: Offset(1140, 0),
    diameter: 78,
    labelWidth: 112,
  ),
  'crossplatform_development': _TreeNodeSpec(
    offset: Offset(1300, 0),
    diameter: 78,
    labelWidth: 122,
  ),
  'sre_devops': _TreeNodeSpec(
    offset: Offset(1450, 200),
    diameter: 92,
    labelWidth: 132,
  ),
  'system_administration': _TreeNodeSpec(
    offset: Offset(1650, 330),
    diameter: 94,
    labelWidth: 140,
  ),
  'cybersecurity': _TreeNodeSpec(
    offset: Offset(1600, 90),
    diameter: 92,
    labelWidth: 132,
  ),
};

const List<(String, String)> _treeLinks = <(String, String)>[
  ('mathematics', 'mathematical_analysis'),
  ('mathematics', 'discrete_math'),
  ('mathematics', 'linear_algebra_calculus'),
  ('mathematics', 'probability_statistics_analytics'),
  ('discrete_math', 'algorithms_data_structures'),
  ('linear_algebra_calculus', 'ai_theory'),
  ('probability_statistics_analytics', 'machine_learning'),
  ('algorithms_data_structures', 'frontend'),
  ('algorithms_data_structures', 'backend'),
  ('algorithms_data_structures', 'qa_engineering'),
  ('algorithms_data_structures', 'machine_learning'),
  ('databases', 'backend'),
  ('databases', 'machine_learning'),
  ('networking_protocols', 'backend'),
  ('networking_protocols', 'sre_devops'),
  ('networking_protocols', 'system_administration'),
  ('networking_protocols', 'cybersecurity'),
  ('ai_theory', 'machine_learning'),
  ('computer_architecture', 'operating_systems'),
  ('computer_architecture', 'sre_devops'),
  ('computer_architecture', 'system_administration'),
  ('information_security_foundations', 'cybersecurity'),
  ('information_security_foundations', 'system_administration'),
  ('operating_systems', 'backend'),
  ('operating_systems', 'mobile'),
  ('operating_systems', 'sre_devops'),
  ('operating_systems', 'system_administration'),
  ('operating_systems', 'cybersecurity'),
  ('frontend', 'mobile'),
  ('mobile', 'android_development'),
  ('mobile', 'ios_development'),
  ('mobile', 'crossplatform_development'),
];

const List<List<Offset>> _trunkPaths = <List<Offset>>[
  <Offset>[
    Offset(930, 1390),
    Offset(930, 1220),
    Offset(925, 1060),
    Offset(920, 930),
  ],
  <Offset>[
    Offset(925, 1140),
    Offset(790, 1260),
  ],
  <Offset>[
    Offset(935, 1140),
    Offset(1080, 1260),
  ],
];
