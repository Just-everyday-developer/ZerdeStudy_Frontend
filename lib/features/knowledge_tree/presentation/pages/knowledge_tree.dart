import 'dart:math' as math;

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
import '../../../../core/theme/app_theme_colors.dart';
import '../tree_map_config.dart';

class KnowledgeTreePage extends ConsumerWidget {
  const KnowledgeTreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final colors = context.appColors;
    final visibleTracks = knowledgeTreeNodes
        .where((node) => node.trackId != null)
        .map((node) => catalog.trackById(node.trackId!))
        .toList(growable: false);
    final completedBranches = visibleTracks
        .where(
          (track) =>
              catalog.trackAvailabilityFor(state, track.id) == TrackAvailability.completed ||
              catalog.trackAvailabilityFor(state, track.id) == TrackAvailability.mastered,
        )
        .length;
    final activeAssessments = visibleTracks
        .where((track) => catalog.bestAssessmentPercentFor(state, track.id) > 0)
        .length;

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
                  'One connected knowledge tree grows from Computer Science foundations into applied engineering paths.',
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
                    _SummaryPill(
                      label: 'Visible branches',
                      value: '${visibleTracks.length}',
                      color: colors.primary,
                    ),
                    _SummaryPill(
                      label: 'Completed',
                      value: '$completedBranches',
                      color: colors.success,
                    ),
                    _SummaryPill(
                      label: 'Assessments',
                      value: '$activeAssessments scored',
                      color: colors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.accent,
            child: Row(
              children: [
                Expanded(
                  child: _LegendChip(
                    label: 'Available',
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LegendChip(
                    label: 'In progress',
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LegendChip(
                    label: 'Completed',
                    color: colors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LegendChip(
                    label: 'Mastered',
                    color: const Color(0xFFFFD166),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.primary,
            child: SizedBox(
              height: 760,
              child: _KnowledgeTreeViewport(
                visibleTracks: visibleTracks,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeTreeViewport extends ConsumerStatefulWidget {
  const _KnowledgeTreeViewport({
    required this.visibleTracks,
  });

  final List<LearningTrack> visibleTracks;

  @override
  ConsumerState<_KnowledgeTreeViewport> createState() =>
      _KnowledgeTreeViewportState();
}

class _KnowledgeTreeViewportState extends ConsumerState<_KnowledgeTreeViewport> {
  final TransformationController _controller = TransformationController();
  Size? _lastViewportSize;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fitToViewport(Size viewport) {
    if (_lastViewportSize == viewport || viewport.isEmpty) {
      return;
    }

    final availableWidth = math.max(1.0, viewport.width - 24);
    final availableHeight = math.max(1.0, viewport.height - 24);
    final scale = math.min(
      availableWidth / knowledgeTreeCanvasSize.width,
      availableHeight / knowledgeTreeCanvasSize.height,
    );
    final offsetX =
        (viewport.width - (knowledgeTreeCanvasSize.width * scale)) / 2;
    final offsetY =
        (viewport.height - (knowledgeTreeCanvasSize.height * scale)) / 2;
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale);
    matrix.setTranslationRaw(offsetX, offsetY, 0);
    _controller.value = matrix;
    _lastViewportSize = viewport;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fitToViewport(viewportSize);
          }
        });
        final fitScale = math.min(
          math.max(0.1, (viewportSize.width - 24) / knowledgeTreeCanvasSize.width),
          math.max(0.1, (viewportSize.height - 24) / knowledgeTreeCanvasSize.height),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.surface,
                  colors.backgroundElevated,
                  colors.surfaceSoft.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _BackdropPainter(colors: colors),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _controller,
                    constrained: false,
                    minScale: fitScale * 0.9,
                    maxScale: math.max(fitScale * 2.8, 1.8),
                    boundaryMargin: const EdgeInsets.all(120),
                    child: SizedBox(
                      width: knowledgeTreeCanvasSize.width,
                      height: knowledgeTreeCanvasSize.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _KnowledgeTreePainter(
                                  nodes: knowledgeTreeNodes,
                                  edges: knowledgeTreeEdges,
                                  colors: colors,
                                ),
                              ),
                            ),
                          ),
                          ...knowledgeTreeNodes.map(
                            (node) => _buildPositionedNode(
                              context,
                              node,
                              catalog,
                              state,
                              colors,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionedNode(
    BuildContext context,
    KnowledgeTreeNodeSpec node,
    DemoCatalog catalog,
    DemoAppState state,
    AppThemeColors colors,
  ) {
    final orbSize = node.radius * 2;
    final widgetWidth =
        (node.isHub ? orbSize + 56 : math.max(orbSize + 48, 124)).toDouble();
    final widgetHeight = node.isHub ? orbSize + 60 : orbSize + 56;

    return Positioned(
      left: node.position.dx - (widgetWidth / 2),
      top: node.position.dy - (orbSize / 2),
      width: widgetWidth,
      height: widgetHeight,
      child: _KnowledgeTreeNodeCard(
        node: node,
        state: state,
        catalog: catalog,
        onTap: node.trackId == null
            ? null
            : () => context.push(AppRoutes.trackById(node.trackId!)),
      ),
    );
  }
}

class _KnowledgeTreeNodeCard extends StatelessWidget {
  const _KnowledgeTreeNodeCard({
    required this.node,
    required this.state,
    required this.catalog,
    required this.onTap,
  });

  final KnowledgeTreeNodeSpec node;
  final DemoAppState state;
  final DemoCatalog catalog;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final track = node.trackId == null ? null : catalog.trackById(node.trackId!);
    final availability = track == null
        ? TrackAvailability.available
        : catalog.trackAvailabilityFor(state, track.id);
    final accent = track == null
        ? colors.primary
        : _accentForAvailability(colors, availability, track.color);
    final bestPercent =
        track == null ? 0 : catalog.bestAssessmentPercentFor(state, track.id);
    final orbSize = node.radius * 2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        children: [
          SizedBox(
            width: orbSize + 18,
            height: orbSize + 18,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: orbSize,
                    height: orbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withValues(alpha: 0.28),
                          accent.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: orbSize - 10,
                    height: orbSize - 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface.withValues(alpha: 0.92),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.92),
                        width: node.isHub ? 3.2 : 2.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.22),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (track != null)
                              Icon(
                                track.icon,
                                color: accent,
                                size: node.isHub ? 30 : math.max(16, node.radius * 0.36),
                              )
                            else
                              Icon(
                                node.id == 'root'
                                    ? Icons.account_tree_rounded
                                    : Icons.auto_awesome_mosaic_rounded,
                                color: accent,
                                size: node.isHub ? 30 : 22,
                              ),
                            const SizedBox(height: 6),
                            Text(
                              node.title.resolve(state.locale),
                              textAlign: TextAlign.center,
                              maxLines: node.isHub ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                                fontSize: node.isHub
                                    ? 15
                                    : node.radius < 56
                                        ? 11
                                        : 12,
                              ),
                            ),
                            if (node.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                node.subtitle!.resolve(state.locale),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (track != null)
                  Positioned(
                    top: 2,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: colors.surfaceSoft.withValues(alpha: 0.96),
                        border: Border.all(color: accent.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        bestPercent == 0 ? _statusLabel(availability) : '$bestPercent%',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (track != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: accent.withValues(alpha: 0.12),
              ),
              child: Text(
                '${catalog.progressForTrack(state, track.id).completedUnits}/${track.totalUnits} units',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _accentForAvailability(
    AppThemeColors colors,
    TrackAvailability availability,
    Color fallback,
  ) {
    switch (availability) {
      case TrackAvailability.available:
        return fallback;
      case TrackAvailability.inProgress:
        return colors.accent;
      case TrackAvailability.completed:
        return colors.success;
      case TrackAvailability.mastered:
        return const Color(0xFFFFD166);
    }
  }

  static String _statusLabel(TrackAvailability availability) {
    switch (availability) {
      case TrackAvailability.available:
        return 'Open';
      case TrackAvailability.inProgress:
        return 'Live';
      case TrackAvailability.completed:
        return 'Done';
      case TrackAvailability.mastered:
        return 'Mastered';
    }
  }
}

class _KnowledgeTreePainter extends CustomPainter {
  const _KnowledgeTreePainter({
    required this.nodes,
    required this.edges,
    required this.colors,
  });

  final List<KnowledgeTreeNodeSpec> nodes;
  final List<KnowledgeTreeEdgeSpec> edges;
  final AppThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final nodesById = <String, KnowledgeTreeNodeSpec>{
      for (final node in nodes) node.id: node,
    };
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final branchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final edge in edges) {
      final from = nodesById[edge.fromNodeId];
      final to = nodesById[edge.toNodeId];
      if (from == null || to == null) {
        continue;
      }

      final majorEdge =
          from.isHub || to.isHub || from.radius >= 78 || to.radius >= 78;
      final path = _buildBranchPath(from.position, to.position);
      glowPaint
        ..color = colors.treeTrunkGlow.withValues(alpha: majorEdge ? 0.44 : 0.22)
        ..strokeWidth = majorEdge ? 9 : 6;
      branchPaint
        ..color = colors.treeTrunk.withValues(alpha: majorEdge ? 0.92 : 0.74)
        ..strokeWidth = majorEdge ? 5.5 : 2.8;
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, branchPaint);
    }
  }

  Path _buildBranchPath(Offset start, Offset end) {
    final midY = (start.dy + end.dy) / 2;
    final horizontalBias = (end.dx - start.dx) * 0.18;
    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx,
        midY - 46,
        end.dx - horizontalBias,
        midY + 26,
        end.dx,
        end.dy,
      );
  }

  @override
  bool shouldRepaint(covariant _KnowledgeTreePainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges;
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({
    required this.colors,
  });

  final AppThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.primary.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: const Offset(160, 140), radius: 220));
    final accentPaintTwo = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.accent.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(size.width - 120, size.height - 160), radius: 260),
      );

    canvas.drawRect(Offset.zero & size, accentPaint);
    canvas.drawRect(Offset.zero & size, accentPaintTwo);

    final particlePaint = Paint()..color = colors.textSecondary.withValues(alpha: 0.1);
    const particleOffsets = <Offset>[
      Offset(120, 92),
      Offset(280, 174),
      Offset(700, 148),
      Offset(780, 408),
      Offset(170, 566),
      Offset(620, 680),
      Offset(250, 1020),
      Offset(720, 1190),
      Offset(440, 1410),
    ];
    for (final offset in particleOffsets) {
      canvas.drawCircle(offset, 6, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
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
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
