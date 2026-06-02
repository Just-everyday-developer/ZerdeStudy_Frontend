// Interactive knowledge-graph canvas.
//
// Uses InteractiveViewer for pan + pinch-zoom (works on Web, Windows, Android
// out of the box) plus a Stack of Positioned GraphNodeWidgets layered above a
// CustomPainter that draws the bezier edges.
//
// Node drag math: GestureDetector.onPanUpdate gives us screen-space delta.
// We divide by the current InteractiveViewer scale to get graph-space delta,
// read live from a TransformationController.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../application/course_constructor_controller.dart';
import '../../domain/models/course_graph.dart';
import 'graph_node_widget.dart';

/// Logical size of the canvas. Nodes can live outside this, since
/// InteractiveViewer is unconstrained, but the painter uses it as a
/// reasonable default bound.
const double kCanvasWidth = 1800;
const double kCanvasHeight = 1200;

class KnowledgeGraphCanvas extends ConsumerStatefulWidget {
  const KnowledgeGraphCanvas({super.key});

  @override
  ConsumerState<KnowledgeGraphCanvas> createState() =>
      _KnowledgeGraphCanvasState();
}

class _KnowledgeGraphCanvasState extends ConsumerState<KnowledgeGraphCanvas> {
  final _transformController = TransformationController();
  bool _didInitialFit = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _fitToScreen(Size viewportSize) {
    final scale = (viewportSize.width - 80) / kCanvasWidth;
    final clamped = scale.clamp(0.42, 1.0);
    _transformController.value = Matrix4.identity()
      ..scaleByDouble(clamped, clamped, 1, 1)
      ..setTranslationRaw(30, 30, 0);
  }

  double get _currentScale {
    return _transformController.value.getMaxScaleOnAxis();
  }

  void _zoom(double factor) {
    final current = _currentScale;
    final next = (current * factor).clamp(0.35, 2.0);
    final k = next / current;
    final m = _transformController.value.clone();
    m.scaleByDouble(k, k, 1, 1);
    _transformController.value = m;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseConstructorProvider);
    final controller = ref.read(courseConstructorProvider.notifier);
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_didInitialFit) {
          _didInitialFit = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitToScreen(constraints.biggest);
          });
        }

        return Stack(
          children: [
            // ── Grid background ────────────────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _GridBackgroundPainter(colors)),
            ),

            // ── Canvas (pan + zoom) ────────────────────────────────────
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.clearSelection(),
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.35,
                  maxScale: 2.0,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(2000),
                  child: SizedBox(
                    width: kCanvasWidth,
                    height: kCanvasHeight,
                    child: _CanvasContent(
                      state: state,
                      controller: controller,
                      transformController: _transformController,
                    ),
                  ),
                ),
              ),
            ),

            // ── Toolbar ───────────────────────────────────────────────
            Positioned(
              top: 16,
              left: 16,
              child: _CanvasToolbar(
                onAddNode: controller.addNode,
                onStartConnect: controller.startConnect,
                onAutoLayout: () {
                  controller.applyAutoLayout();
                  // Reset view so the new layout is visible.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fitToScreen(constraints.biggest);
                  });
                },
                onZoomIn: () => _zoom(1.15),
                onZoomOut: () => _zoom(1 / 1.15),
                onFit: () => _fitToScreen(constraints.biggest),
                scale: _currentScale,
                connectActive: state.connectFromId != null,
              ),
            ),

            // ── Mode switcher ─────────────────────────────────────────
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: _ModeSwitcher(
                  mode: state.canvasMode,
                  onChanged: controller.setCanvasMode,
                ),
              ),
            ),

            // ── Mini-map ──────────────────────────────────────────────
            if (constraints.maxWidth > 720)
              Positioned(
                bottom: 16,
                right: 16,
                child: _MiniMap(course: state.course),
              ),

            // ── Connect-mode hint ─────────────────────────────────────
            if (state.connectFromId != null)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: _ConnectHint(onCancel: controller.cancelConnect),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Canvas content: edges (CustomPaint) + nodes (Positioned)
// ─────────────────────────────────────────────────────────────────────────────

class _CanvasContent extends StatelessWidget {
  const _CanvasContent({
    required this.state,
    required this.controller,
    required this.transformController,
  });

  final CourseConstructorState state;
  final CourseConstructorController controller;
  final TransformationController transformController;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Edges layer
        Positioned.fill(
          child: CustomPaint(
            painter: _EdgesPainter(
              course: state.course,
              mode: state.canvasMode,
              connectFromId: state.connectFromId,
              colors: colors,
            ),
          ),
        ),
        // Nodes layer
        for (final node in state.course.nodes)
          Positioned(
            left: node.position.dx,
            top: node.position.dy,
            child: GraphNodeWidget(
              node: node,
              selected: state.selectedNodeId == node.id,
              mode: state.canvasMode,
              connectFromActive: state.connectFromId != null,
              isConnectSource: state.connectFromId == node.id,
              onTap: () => controller.selectNode(node.id),
              onHandleTap: () => controller.selectNode(node.id),
              onDelete: () => controller.deleteNode(node.id),
              onDragDelta: (delta) {
                final scale = transformController.value.getMaxScaleOnAxis();
                final scaled = delta / scale;
                controller.moveNode(node.id, node.position + scaled);
              },
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edges painter
// ─────────────────────────────────────────────────────────────────────────────

class _EdgesPainter extends CustomPainter {
  _EdgesPainter({
    required this.course,
    required this.mode,
    required this.connectFromId,
    required this.colors,
  });

  final CourseGraph course;
  final CanvasMode mode;
  final String? connectFromId;
  final AppThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = colors.divider.withValues(alpha: 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final riskPaint = Paint()
      ..color = colors.danger.withValues(alpha: 0.85)
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;

    final ghostPaint = Paint()
      ..color = colors.accent.withValues(alpha: 0.95)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final edge in course.edges) {
      final a = course.nodeById(edge.from);
      final b = course.nodeById(edge.to);
      if (a == null || b == null) continue;

      final aSize = nodeSize(a);
      final bSize = nodeSize(b);

      final path = _edgePath(a.position, aSize, b.position, bSize);
      final isGhost =
          a.type == CourseNodeType.ghost || b.type == CourseNodeType.ghost;
      final isRisk = mode == CanvasMode.structure && (a.risk || b.risk);

      if (isGhost) {
        canvas.drawPath(_dashPath(path, 4, 4), ghostPaint);
      } else if (isRisk) {
        canvas.drawPath(path, riskPaint);
      } else {
        canvas.drawPath(path, basePaint);
      }
    }

    // Live connect indicator at the source node
    if (connectFromId != null) {
      final src = course.nodeById(connectFromId!);
      if (src != null) {
        final s = nodeSize(src);
        canvas.drawCircle(
          Offset(src.position.dx + s.width, src.position.dy + s.height / 2),
          6,
          Paint()..color = colors.primary,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EdgesPainter old) {
    return old.course != course ||
        old.mode != mode ||
        old.connectFromId != connectFromId;
  }
}

Path _edgePath(Offset aPos, Size aSize, Offset bPos, Size bSize) {
  final ax = aPos.dx, ay = aPos.dy;
  final bx = bPos.dx, by = bPos.dy;
  final acx = ax + aSize.width / 2;
  final acy = ay + aSize.height / 2;
  final bcx = bx + bSize.width / 2;
  final bcy = by + bSize.height / 2;
  final dx = bcx - acx;
  final dy = bcy - acy;
  final path = Path();

  if (dy.abs() < 80 && dx.abs() > 80) {
    // Horizontal between siblings.
    final x1 = ax + aSize.width;
    final y1 = acy;
    final x2 = bx;
    final y2 = bcy;
    final cx = (x1 + x2) / 2;
    path.moveTo(x1, y1);
    path.cubicTo(cx, y1, cx, y2, x2, y2);
  } else {
    // Vertical parent → child.
    final x1 = acx;
    final y1 = ay + aSize.height;
    final x2 = bcx;
    final y2 = by;
    final cy = (y1 + y2) / 2;
    path.moveTo(x1, y1);
    path.cubicTo(x1, cy, x2, cy, x2, y2);
  }
  return path;
}

Path _dashPath(Path source, double dashLen, double gapLen) {
  final out = Path();
  for (final metric in source.computeMetrics()) {
    double distance = 0;
    while (distance < metric.length) {
      final end = (distance + dashLen).clamp(0, metric.length).toDouble();
      out.addPath(metric.extractPath(distance, end), Offset.zero);
      distance = end + gapLen;
    }
  }
  return out;
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid background
// ─────────────────────────────────────────────────────────────────────────────

class _GridBackgroundPainter extends CustomPainter {
  _GridBackgroundPainter(this.colors);
  final AppThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.background);
    final line = Paint()
      ..color = colors.textSecondary.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    const step = 80.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _CanvasToolbar extends StatelessWidget {
  const _CanvasToolbar({
    required this.onAddNode,
    required this.onStartConnect,
    required this.onAutoLayout,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
    required this.scale,
    required this.connectActive,
  });

  final void Function(CourseNodeType type) onAddNode;
  final VoidCallback onStartConnect;
  final VoidCallback onAutoLayout;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final double scale;
  final bool connectActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<CourseNodeType>(
            tooltip: 'Add node',
            icon: Icon(Icons.add_rounded, color: colors.textPrimary, size: 18),
            onSelected: onAddNode,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: CourseNodeType.lesson,
                child: _MenuRow(icon: Icons.menu_book_rounded, label: 'Lesson'),
              ),
              PopupMenuItem(
                value: CourseNodeType.quiz,
                child: _MenuRow(icon: Icons.quiz_rounded, label: 'Quiz'),
              ),
              PopupMenuItem(
                value: CourseNodeType.practice,
                child: _MenuRow(
                  icon: Icons.science_rounded,
                  label: 'Practice lab',
                ),
              ),
              PopupMenuItem(
                value: CourseNodeType.module,
                child: _MenuRow(icon: Icons.dashboard_rounded, label: 'Module'),
              ),
              PopupMenuItem(
                value: CourseNodeType.milestone,
                child: _MenuRow(icon: Icons.flag_rounded, label: 'Milestone'),
              ),
            ],
          ),
          _ToolbarBtn(
            tooltip: 'Connect nodes',
            icon: Icons.arrow_forward_rounded,
            highlight: connectActive,
            onPressed: onStartConnect,
          ),
          const _ToolbarSep(),
          _ToolbarBtn(
            tooltip: 'Zoom out',
            icon: Icons.remove_rounded,
            onPressed: onZoomOut,
          ),
          _ToolbarBtn(
            tooltip: 'Fit',
            label: '${(scale * 100).round()}',
            onPressed: onFit,
          ),
          _ToolbarBtn(
            tooltip: 'Zoom in',
            icon: Icons.add_rounded,
            onPressed: onZoomIn,
          ),
          const _ToolbarSep(),
          _ToolbarBtn(
            tooltip: 'Auto-layout',
            icon: Icons.account_tree_rounded,
            onPressed: onAutoLayout,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon, size: 16), const SizedBox(width: 10), Text(label)],
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  const _ToolbarBtn({
    required this.tooltip,
    this.icon,
    this.label,
    this.highlight = false,
    required this.onPressed,
  });

  final String tooltip;
  final IconData? icon;
  final String? label;
  final bool highlight;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = highlight ? colors.primary : colors.textSecondary;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: fg, size: 18)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    color: fg,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
        ),
      ),
    );
  }
}

class _ToolbarSep extends StatelessWidget {
  const _ToolbarSep();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: context.appColors.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode switcher (Structure / Mastery / Funnel)
// ─────────────────────────────────────────────────────────────────────────────

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.mode, required this.onChanged});
  final CanvasMode mode;
  final ValueChanged<CanvasMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [for (final m in CanvasMode.values) _seg(context, m)],
      ),
    );
  }

  Widget _seg(BuildContext context, CanvasMode m) {
    final colors = context.appColors;
    final selected = mode == m;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(m),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _label(m),
          style: TextStyle(
            color: selected ? colors.primary : colors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _label(CanvasMode m) => switch (m) {
    CanvasMode.structure => 'Structure',
    CanvasMode.mastery => 'Mastery',
    CanvasMode.funnel => 'Funnel',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini-map
// ─────────────────────────────────────────────────────────────────────────────

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.course});
  final CourseGraph course;

  static const double _w = 170;
  static const double _h = 120;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: _w,
      height: _h,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: _MiniMapPainter(course: course, colors: colors),
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter({required this.course, required this.colors});
  final CourseGraph course;
  final AppThemeColors colors;

  static const double _minX = 80, _minY = 80, _maxX = 1600, _maxY = 1100;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / (_maxX - _minX);
    final sy = size.height / (_maxY - _minY);
    for (final n in course.nodes) {
      final ns = nodeSize(n);
      final rect = Rect.fromLTWH(
        (n.position.dx - _minX) * sx,
        (n.position.dy - _minY) * sy,
        (ns.width * sx).clamp(2, size.width),
        (ns.height * sy).clamp(2, size.height),
      );
      final paint = Paint()..color = _colorFor(n);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        paint,
      );
    }
  }

  Color _colorFor(CourseNode n) {
    switch (n.type) {
      case CourseNodeType.module:
        return colors.primary;
      case CourseNodeType.quiz:
        return colors.accent;
      case CourseNodeType.practice:
        return const Color(0xFFB4A8FF);
      case CourseNodeType.milestone:
        return colors.success;
      case CourseNodeType.ghost:
        return colors.accent.withValues(alpha: 0.4);
      case CourseNodeType.lesson:
        return colors.textSecondary;
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter old) => old.course != course;
}

// ─────────────────────────────────────────────────────────────────────────────
// Connect hint
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectHint extends StatelessWidget {
  const _ConnectHint({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded, color: colors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            'Tap a target node to create an edge',
            style: TextStyle(color: colors.textPrimary, fontSize: 12),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onCancel,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
