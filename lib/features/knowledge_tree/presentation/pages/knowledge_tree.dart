import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../app_guide/presentation/app_guide_controller.dart';
import '../../../app_guide/presentation/app_guide_target.dart';
import '../tree_map_config.dart';

class KnowledgeTreePage extends ConsumerWidget {
  const KnowledgeTreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppPageScaffold(
      horizontalPadding: 0,
      expandContent: true,
      safeAreaBottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = context.isCompactLayout;
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final availableHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height;
          final treeContentWidth = compact
              ? availableWidth
              : math.min(math.max(availableWidth - 56, 0), 1220.0).toDouble();

          return SizedBox(
            width: availableWidth,
            height: math.max(460.0, availableHeight),
            child: _KnowledgeTreeViewport(contentWidth: treeContentWidth),
          );
        },
      ),
    );
  }
}

class _KnowledgeTreeViewport extends ConsumerStatefulWidget {
  const _KnowledgeTreeViewport({required this.contentWidth});

  final double contentWidth;

  @override
  ConsumerState<_KnowledgeTreeViewport> createState() =>
      _KnowledgeTreeViewportState();
}

class _KnowledgeTreeViewportState
    extends ConsumerState<_KnowledgeTreeViewport> {
  static const double _windowsFixedScale = 0.64;

  final TransformationController _controller = TransformationController();
  Size? _lastViewportSize;
  double _fitScale = 1;
  bool _didInitialFit = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isWindowsDesktopViewport(bool compact) {
    return !compact &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows;
  }

  void _fitToViewport(
    Size viewport, {
    bool force = false,
    required bool windowsFixedViewport,
  }) {
    if (viewport.isEmpty) {
      return;
    }
    if (!force && _didInitialFit && _lastViewportSize == viewport) {
      return;
    }

    final availableWidth = math.max(1.0, viewport.width - 24);
    final availableHeight = math.max(1.0, viewport.height - 24);
    final scale = windowsFixedViewport
        ? _windowsFixedScale
        : math.min(
            availableWidth / knowledgeTreeCanvasSize.width,
            availableHeight / knowledgeTreeCanvasSize.height,
          );
    _fitScale = scale;
    final offsetX = windowsFixedViewport
        ? 24.0
        : math.max(
            0.0,
            (viewport.width - (knowledgeTreeCanvasSize.width * scale)) / 2,
          );
    final offsetY = windowsFixedViewport ? 24.0 : 12.0;
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale);
    matrix.setTranslationRaw(offsetX, offsetY, 0);
    _controller.value = matrix;
    _lastViewportSize = viewport;
    _didInitialFit = true;
  }

  double get _currentScale => _controller.value.getMaxScaleOnAxis();

  double _minScale(bool compact) => compact ? _fitScale * 0.96 : _fitScale;

  double _maxScale(bool compact) => compact
      ? math.max(_fitScale * 2.35, 1.7)
      : math.max(_fitScale * 1.65, 1.2);

  void _setScale(
    double targetScale, {
    Offset? focalPoint,
    required bool compact,
  }) {
    final viewport = _lastViewportSize;
    if (viewport == null || viewport.isEmpty) {
      return;
    }
    final clampedScale = targetScale.clamp(
      _minScale(compact),
      _maxScale(compact),
    );
    final viewportFocalPoint =
        focalPoint ?? Offset(viewport.width / 2, viewport.height / 2);
    final scenePoint = _controller.toScene(viewportFocalPoint);
    final nextMatrix = Matrix4.identity()
      ..setEntry(0, 0, clampedScale)
      ..setEntry(1, 1, clampedScale);
    nextMatrix.setTranslationRaw(
      viewportFocalPoint.dx - (scenePoint.dx * clampedScale),
      viewportFocalPoint.dy - (scenePoint.dy * clampedScale),
      0,
    );
    _controller.value = nextMatrix;
    _didInitialFit = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final colors = context.appColors;
    final nodeAccentColors = <String, Color>{
      for (final node in knowledgeTreeNodes)
        node.id: _nodeAccentColor(
          node: node,
          catalog: catalog,
          state: state,
          colors: colors,
        ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = context.isCompactLayout;
        final contentWidth = math.min(
          widget.contentWidth,
          constraints.maxWidth,
        );

        return AppGuideTarget(
          id: AppGuideTargetIds.treeCanvas,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 0 : 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF03111D),
                    const Color(0xFF051A28),
                    Color.lerp(const Color(0xFF071F31), colors.surface, 0.35) ??
                        colors.surface,
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
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: contentWidth,
                        height: constraints.maxHeight,
                        child: LayoutBuilder(
                          builder: (context, contentConstraints) {
                            final viewportSize = Size(
                              contentConstraints.maxWidth,
                              contentConstraints.maxHeight,
                            );
                            final desktopLike = !compact;
                            final windowsFixedViewport =
                                _isWindowsDesktopViewport(compact);

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _fitToViewport(
                                  viewportSize,
                                  windowsFixedViewport: windowsFixedViewport,
                                );
                              }
                            });
                            final fitScale = math.min(
                              math.max(
                                0.1,
                                (viewportSize.width - 24) /
                                    knowledgeTreeCanvasSize.width,
                              ),
                              math.max(
                                0.1,
                                (viewportSize.height - 24) /
                                    knowledgeTreeCanvasSize.height,
                              ),
                            );
                            _fitScale = windowsFixedViewport
                                ? _windowsFixedScale
                                : fitScale;

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Listener(
                                    behavior: HitTestBehavior.opaque,
                                    onPointerSignal: (event) {
                                      if (windowsFixedViewport) {
                                        return;
                                      }
                                      if (event is! PointerScrollEvent ||
                                          event.kind ==
                                              PointerDeviceKind.touch) {
                                        return;
                                      }
                                      final delta =
                                          (-event.scrollDelta.dy / 240).clamp(
                                            -0.18,
                                            0.18,
                                          );
                                      _setScale(
                                        _currentScale + delta,
                                        focalPoint: event.localPosition,
                                        compact: compact,
                                      );
                                    },
                                    child: InteractiveViewer(
                                      transformationController: _controller,
                                      constrained: false,
                                      minScale: _minScale(compact),
                                      maxScale: windowsFixedViewport
                                          ? _windowsFixedScale
                                          : _maxScale(compact),
                                      scaleEnabled: !windowsFixedViewport,
                                      panEnabled: true,
                                      trackpadScrollCausesScale: false,
                                      boundaryMargin: EdgeInsets.symmetric(
                                        horizontal: windowsFixedViewport
                                            ? 36
                                            : desktopLike
                                            ? 8
                                            : 44,
                                        vertical: windowsFixedViewport
                                            ? 80
                                            : desktopLike
                                            ? 24
                                            : 64,
                                      ),
                                      child: SizedBox(
                                        width: knowledgeTreeCanvasSize.width,
                                        height: knowledgeTreeCanvasSize.height,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned.fill(
                                              child: IgnorePointer(
                                                child: CustomPaint(
                                                  painter:
                                                      _KnowledgeTreePainter(
                                                        nodes:
                                                            knowledgeTreeNodes,
                                                        edges:
                                                            knowledgeTreeEdges,
                                                        nodeAccentColors:
                                                            nodeAccentColors,
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
                                                nodeAccentColors[node.id] ??
                                                    colors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
    Color accent,
  ) {
    final orbSize = node.radius * 2;
    final widgetWidth =
        (node.isHub ? math.max(orbSize + 76, 230) : math.max(orbSize + 54, 164))
            .toDouble();
    final widgetHeight = node.isHub ? orbSize + 44 : orbSize + 28;

    return Positioned(
      left: node.position.dx - (widgetWidth / 2),
      top: node.position.dy - (widgetHeight / 2),
      width: widgetWidth,
      height: widgetHeight,
      child: _KnowledgeTreeNodeCard(
        node: node,
        state: state,
        catalog: catalog,
        accent: accent,
        onTap: node.trackId == null || node.id == 'mathematics'
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
    required this.accent,
    required this.onTap,
  });

  final KnowledgeTreeNodeSpec node;
  final DemoAppState state;
  final DemoCatalog catalog;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final track = node.trackId == null
        ? null
        : catalog.trackById(node.trackId!);
    final availability = track == null
        ? TrackAvailability.available
        : catalog.trackAvailabilityFor(state, track.id);
    final bestPercent = track == null
        ? 0
        : catalog.bestAssessmentPercentFor(state, track.id);
    final progress = track == null
        ? null
        : catalog.progressForTrack(state, track.id);
    final orbSize = node.radius * 2;
    final statusHasBadge =
        bestPercent > 0 || (progress?.completedUnits ?? 0) > 0;
    final statusLabel = bestPercent > 0
        ? '$bestPercent%'
        : progress == null || progress.completedUnits == 0
        ? ''
        : '${progress.completedUnits}';
    final hubIcon = node.id == 'root'
        ? Icons.hub_rounded
        : Icons.auto_awesome_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: orbSize + 22,
        height: orbSize + 22,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: orbSize + 20,
                height: orbSize + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.24),
                      accent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: orbSize,
                height: orbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: progress != null && progress.fraction > 0 ? LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: [
                      0.0,
                      progress.fraction,
                      progress.fraction,
                      1.0,
                    ],
                    colors: [
                      accent.withValues(alpha: 0.5),
                      accent.withValues(alpha: 0.5),
                      const Color(0xFF071C2A).withValues(alpha: node.isHub ? 0.98 : 0.94),
                      const Color(0xFF05121D).withValues(alpha: node.isHub ? 0.98 : 0.92),
                    ],
                  ) : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(
                        0xFF071C2A,
                      ).withValues(alpha: node.isHub ? 0.98 : 0.94),
                      const Color(
                        0xFF05121D,
                      ).withValues(alpha: node.isHub ? 0.98 : 0.92),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.96),
                    width: node.isHub ? 3.1 : 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.22),
                      blurRadius: node.isHub ? 24 : 18,
                      spreadRadius: node.isHub ? 2 : 1,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.18),
                      width: 1.1,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            track?.icon ?? hubIcon,
                            color: accent,
                            size: node.isHub
                                ? 30
                                : math.max(18, node.radius * 0.34),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            node.title.resolve(state.locale),
                            textAlign: TextAlign.center,
                            maxLines: node.isHub ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              fontSize: node.isHub
                                  ? 16
                                  : node.radius <= 66
                                  ? 11.5
                                  : 12.5,
                            ),
                          ),
                          if (node.subtitle != null) ...[
                            const SizedBox(height: 5),
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
            ),
            if (track != null)
              Positioned(
                top: 6,
                right: 4,
                child: statusHasBadge
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: statusLabel.isEmpty ? 0 : 8,
                          vertical: statusLabel.isEmpty ? 0 : 5,
                        ),
                        width: statusLabel.isEmpty ? 12 : null,
                        height: statusLabel.isEmpty ? 12 : null,
                        decoration: BoxDecoration(
                          shape: statusLabel.isEmpty
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          borderRadius: statusLabel.isEmpty
                              ? null
                              : BorderRadius.circular(999),
                          color: colors.surfaceSoft.withValues(alpha: 0.96),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.58),
                          ),
                        ),
                        child: statusLabel.isEmpty
                            ? null
                            : Text(
                                statusLabel,
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                      )
                    : Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.34),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
              ),
            if (track != null && bestPercent == 0)
              Positioned(
                left: 8,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colors.surfaceSoft.withValues(alpha: 0.88),
                    border: Border.all(color: accent.withValues(alpha: 0.28)),
                  ),
                  child: Text(
                    _statusLabel(context, availability),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KnowledgeTreePainter extends CustomPainter {
  const _KnowledgeTreePainter({
    required this.nodes,
    required this.edges,
    required this.nodeAccentColors,
    required this.colors,
  });

  final List<KnowledgeTreeNodeSpec> nodes;
  final List<KnowledgeTreeEdgeSpec> edges;
  final Map<String, Color> nodeAccentColors;
  final AppThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final nodesById = <String, KnowledgeTreeNodeSpec>{
      for (final node in nodes) node.id: node,
    };
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final branchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final edge in edges) {
      final from = nodesById[edge.fromNodeId];
      final to = nodesById[edge.toNodeId];
      if (from == null || to == null) {
        continue;
      }

      final fromAccent = nodeAccentColors[from.id] ?? colors.primary;
      final toAccent = nodeAccentColors[to.id] ?? colors.accent;
      final majorEdge =
          from.isHub || to.isHub || from.radius >= 86 || to.radius >= 86;
      final edgeColor = edge.toNodeId == 'applied_hub'
          ? fromAccent
          : Color.lerp(fromAccent, toAccent, 0.45) ?? toAccent;
      final path = _buildBranchPath(from, to, edge);
      glowPaint
        ..color = edgeColor.withValues(alpha: majorEdge ? 0.34 : 0.2)
        ..strokeWidth = majorEdge ? 8 : 5.5;
      branchPaint
        ..color = edgeColor.withValues(alpha: majorEdge ? 0.92 : 0.82)
        ..strokeWidth = majorEdge ? 3.8 : 2.4;
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, branchPaint);
    }
  }

  Path _buildBranchPath(
    KnowledgeTreeNodeSpec startNode,
    KnowledgeTreeNodeSpec endNode,
    KnowledgeTreeEdgeSpec edge,
  ) {
    if (edge.toNodeId == 'applied_hub') {
      final start = Offset(
        startNode.position.dx,
        startNode.position.dy + startNode.radius - 6,
      );
      final end = Offset(
        endNode.position.dx,
        endNode.position.dy - endNode.radius + 6,
      );
      final bridgeY = end.dy - 86;

      return Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(start.dx, bridgeY)
        ..lineTo(end.dx, bridgeY)
        ..lineTo(end.dx, end.dy);
    }

    final start = _circleEdgePoint(
      center: startNode.position,
      target: endNode.position,
      radius: math.max(16, startNode.radius - 6),
    );
    final end = _circleEdgePoint(
      center: endNode.position,
      target: startNode.position,
      radius: math.max(16, endNode.radius - 6),
    );

    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
  }

  Offset _circleEdgePoint({
    required Offset center,
    required Offset target,
    required double radius,
  }) {
    final direction = target - center;
    final distance = direction.distance;
    if (distance == 0) {
      return center;
    }
    final normalized = direction / distance;
    return center + (normalized * radius);
  }

  @override
  bool shouldRepaint(covariant _KnowledgeTreePainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.nodeAccentColors != nodeAccentColors;
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({required this.colors});

  final AppThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF13D9FF).withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: const Offset(800, 240), radius: 320),
          );
    final accentPaintTwo = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFFA63E).withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height * 0.62),
              radius: 380,
            ),
          );
    final accentPaintThree = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFA991FF).withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width - 260, size.height - 320),
              radius: 320,
            ),
          );

    canvas.drawRect(Offset.zero & size, accentPaint);
    canvas.drawRect(Offset.zero & size, accentPaintTwo);
    canvas.drawRect(Offset.zero & size, accentPaintThree);

    final particlePaint = Paint()
      ..color = colors.textSecondary.withValues(alpha: 0.08);
    const particleOffsets = <Offset>[
      Offset(146, 132),
      Offset(428, 324),
      Offset(716, 282),
      Offset(1220, 364),
      Offset(262, 684),
      Offset(846, 1016),
      Offset(1348, 918),
      Offset(560, 1478),
      Offset(1160, 1708),
      Offset(364, 2080),
      Offset(1008, 2280),
    ];
    for (final offset in particleOffsets) {
      canvas.drawCircle(offset, 5, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}

Color _nodeAccentColor({
  required KnowledgeTreeNodeSpec node,
  required DemoCatalog catalog,
  required DemoAppState state,
  required AppThemeColors colors,
}) {
  if (node.trackId == null) {
    switch (node.id) {
      case 'root':
        return const Color(0xFF13D9FF);
      case 'applied_hub':
        return const Color(0xFFFFA63E);
      default:
        return colors.primary;
    }
  }

  final track = catalog.trackById(node.trackId!);
  final availability = catalog.trackAvailabilityFor(state, track.id);
  return _availabilityAccent(colors, availability, track.color);
}

Color _availabilityAccent(
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

String _statusLabel(BuildContext context, TrackAvailability availability) {
  switch (availability) {
    case TrackAvailability.available:
      return context.l10n.text('tree_available');
    case TrackAvailability.inProgress:
      return context.l10n.text('tree_in_progress');
    case TrackAvailability.completed:
      return context.l10n.text('tree_completed');
    case TrackAvailability.mastered:
      return context.l10n.text('tree_mastered');
  }
}

