import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_catalog.dart';
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
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final nodes = _buildNodes(catalog, state);

    return AppPageScaffold(
      title: context.l10n.text('knowledge_tree'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          GlowCard(
            accent: AppColors.primary,
            child: Text(
              context.l10n.text('tree_intro'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),
          GlowCard(
            accent: AppColors.accent,
            padding: const EdgeInsets.all(8),
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 1.8,
              constrained: false,
              child: SizedBox(
                width: 720,
                height: 620,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TreePainter(
                          connections: _connectionsForNodes(nodes),
                        ),
                      ),
                    ),
                    ...nodes.map((node) {
                      return SkillNode(
                        label: node.track.title.resolve(state.locale),
                        icon: node.track.icon,
                        color: node.color,
                        statusLabel: node.statusLabel,
                        offset: node.position,
                        onTap: () => context.push(
                          AppRoutes.trackById(node.track.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<_TreeNodeModel> _buildNodes(DemoCatalog catalog, DemoAppState state) {
  final tracks = <String, Offset>{
    'fundamentals': const Offset(300, 20),
    'frontend': const Offset(160, 180),
    'backend': const Offset(460, 180),
    'mobile': const Offset(40, 360),
    'devops': const Offset(250, 360),
    'cyber_security': const Offset(430, 360),
    'machine_learning': const Offset(590, 300),
  };

  return catalog.tracks.map((track) {
    final progress = catalog.progressForTrack(state, track.id);
    final color = switch (progress.state) {
      TrackVisualState.locked => AppColors.textSecondary,
      TrackVisualState.inProgress => track.color,
      TrackVisualState.completed => AppColors.success,
    };
    final statusLabel = switch (progress.state) {
      TrackVisualState.locked => 'Locked',
      TrackVisualState.inProgress => 'In progress',
      TrackVisualState.completed => 'Completed',
    };

    return _TreeNodeModel(
      track: track,
      position: tracks[track.id] ?? Offset.zero,
      color: color,
      statusLabel: statusLabel,
    );
  }).toList();
}

List<List<Offset>> _connectionsForNodes(List<_TreeNodeModel> nodes) {
  Offset positionOf(String id) {
    return nodes.firstWhere((node) => node.track.id == id).position +
        const Offset(44, 44);
  }

  return <List<Offset>>[
    [positionOf('fundamentals'), positionOf('frontend')],
    [positionOf('fundamentals'), positionOf('backend')],
    [positionOf('frontend'), positionOf('mobile')],
    [positionOf('frontend'), positionOf('devops')],
    [positionOf('backend'), positionOf('cyber_security')],
    [positionOf('backend'), positionOf('machine_learning')],
  ];
}

class _TreeNodeModel {
  const _TreeNodeModel({
    required this.track,
    required this.position,
    required this.color,
    required this.statusLabel,
  });

  final LearningTrack track;
  final Offset position;
  final Color color;
  final String statusLabel;
}
