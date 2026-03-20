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
import '../tree_map_config.dart';

class KnowledgeTreePage extends ConsumerWidget {
  const KnowledgeTreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.sizeOf(context);
    final compact = context.isCompactLayout;
    final treeHeight = math.max(
      460.0,
      screenSize.height - (compact ? 104 : 128),
    );
    final treeContentWidth = compact
        ? screenSize.width
        : math.min(screenSize.width - 56, 1220.0);

    return AppPageScaffold(
      horizontalPadding: 0,
      expandContent: true,
      child: SizedBox(
        width: screenSize.width,
        height: treeHeight,
        child: _KnowledgeTreeViewport(
          contentWidth: treeContentWidth,
        ),
      ),
    );
  }
}

class _KnowledgeTreeViewport extends ConsumerStatefulWidget {
  const _KnowledgeTreeViewport({
    required this.contentWidth,
  });

  final double contentWidth;

  @override
  ConsumerState<_KnowledgeTreeViewport> createState() =>
      _KnowledgeTreeViewportState();
}

class _KnowledgeTreeViewportState extends ConsumerState<_KnowledgeTreeViewport> {
  static const double _windowsFixedScale = 0.64;

  final TransformationController _controller = TransformationController();
  Size? _lastViewportSize;
  double _fitScale = 1;
  bool _didInitialFit = false;
  bool _legendOpen = false;

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
    final offsetX =
        (viewport.width - (knowledgeTreeCanvasSize.width * scale)) / 2;
    final offsetY = windowsFixedViewport
        ? 24.0
        : (viewport.height - (knowledgeTreeCanvasSize.height * scale)) / 2;
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

  double _maxScale(bool compact) =>
      compact ? math.max(_fitScale * 2.35, 1.7) : math.max(_fitScale * 1.65, 1.2);

  void _setScale(
    double targetScale, {
    Offset? focalPoint,
    required bool compact,
  }) {
    final viewport = _lastViewportSize;
    if (viewport == null || viewport.isEmpty) {
      return;
    }
    final clampedScale = targetScale.clamp(_minScale(compact), _maxScale(compact));
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = context.isCompactLayout;
        final contentWidth = math.min(widget.contentWidth, constraints.maxWidth);

        return ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 0 : 28),
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
                          _fitScale =
                              windowsFixedViewport ? _windowsFixedScale : fitScale;

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
                                        event.kind == PointerDeviceKind.touch) {
                                      return;
                                    }
                                    final delta = (-event.scrollDelta.dy / 240)
                                        .clamp(-0.18, 0.18);
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
                              ),
                              Positioned(
                                right: 16,
                                top: 16,
                                child: _TreeLegendMenu(
                                  compact: compact,
                                  isOpen: _legendOpen,
                                  onToggle: () {
                                    setState(() {
                                      _legendOpen = !_legendOpen;
                                    });
                                  },
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
        (node.isHub ? orbSize + 68 : math.max(orbSize + 64, 152)).toDouble();
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

class _TreeLegendCard extends StatelessWidget {
  const _TreeLegendCard({
    required this.compact,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surface.withValues(alpha: 0.94),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendChip(
            label: context.l10n.text('tree_available'),
            color: colors.primary,
            compact: true,
          ),
          const SizedBox(height: 6),
          _LegendChip(
            label: context.l10n.text('tree_in_progress'),
            color: colors.accent,
            compact: true,
          ),
          const SizedBox(height: 6),
          _LegendChip(
            label: context.l10n.text('tree_completed'),
            color: colors.success,
            compact: true,
          ),
          const SizedBox(height: 6),
          _LegendChip(
            label: context.l10n.text('tree_mastered'),
            color: const Color(0xFFFFD166),
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _TreeLegendMenu extends StatelessWidget {
  const _TreeLegendMenu({
    required this.compact,
    required this.isOpen,
    required this.onToggle,
  });

  final bool compact;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            color: colors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.divider),
                ),
                child: Icon(
                  isOpen ? Icons.close_rounded : Icons.legend_toggle_rounded,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          if (isOpen) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: compact ? 232 : 182,
              child: _TreeLegendCard(compact: compact),
            ),
          ],
        ],
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
                        bestPercent == 0
                            ? _statusLabel(context, availability)
                            : '$bestPercent%',
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
                '${catalog.progressForTrack(state, track.id).completedUnits}/${track.totalUnits} ${context.l10n.text('tree_units')}',
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

  static String _statusLabel(BuildContext context, TrackAvailability availability) {
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
    final verticalDistance = (end.dy - start.dy).abs();
    final controlOffset = math.max(90, verticalDistance * 0.18);
    final midX = start.dx + ((end.dx - start.dx) * 0.18);
    final endMidX = end.dx - ((end.dx - start.dx) * 0.18);
    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        midX,
        start.dy + controlOffset,
        endMidX,
        end.dy - controlOffset,
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

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 10 : 12,
      ),
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
                fontSize: compact ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
