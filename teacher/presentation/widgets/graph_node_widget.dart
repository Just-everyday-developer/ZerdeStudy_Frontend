// Single node widget in the knowledge graph canvas.
//
// Owns:
//   - visual rendering (type-specific colors, mastery overlay, risk halo)
//   - hit-handling for tap + drag (delta is reported up; conversion to graph
//     coordinates happens in the canvas)

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../application/course_constructor_controller.dart';
import '../../domain/models/course_graph.dart';

/// Logical size of a node on the canvas. Kept in sync with the painter's edge
/// calculations.
Size nodeSize(CourseNode node) {
  if (node.type == CourseNodeType.milestone) return const Size(150, 52);
  return const Size(196, 72);
}

class GraphNodeWidget extends StatelessWidget {
  const GraphNodeWidget({
    super.key,
    required this.node,
    required this.selected,
    required this.mode,
    required this.connectFromActive,
    required this.isConnectSource,
    required this.onTap,
    required this.onHandleTap,
    required this.onDelete,
    required this.onDragDelta,
  });

  final CourseNode node;
  final bool selected;
  final CanvasMode mode;

  /// True when the user has activated "connect mode" globally.
  final bool connectFromActive;

  /// True when THIS node is the source of the in-flight connection.
  final bool isConnectSource;

  final VoidCallback onTap;
  final VoidCallback onHandleTap;
  final VoidCallback onDelete;
  final void Function(Offset delta) onDragDelta;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = nodeSize(node);

    return SizedBox(
      width: size.width,
      height: size.height + (selected ? 30 : 0), // extra room for delete pop
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (selected)
            Positioned(
              top: -34,
              right: 0,
              child: _NodePop(onDelete: onDelete),
            ),
          Positioned(
            left: 0,
            top: selected ? 30 : 0,
            child: GestureDetector(
              onTap: onTap,
              onPanUpdate: (details) => onDragDelta(details.delta),
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: _buildBody(context, colors, size),
              ),
            ),
          ),

          // Right-side connect handle
          if (selected || isConnectSource)
            Positioned(
              right: -7,
              top: (selected ? 30 : 0) + size.height / 2 - 8,
              child: _ConnectHandle(
                active: isConnectSource,
                onTap: onHandleTap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppThemeColors colors, Size size) {
    final isMilestone = node.type == CourseNodeType.milestone;
    final accent = _accentFor(node, colors);
    final isGhost = node.type == CourseNodeType.ghost;

    if (isMilestone) {
      return Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? colors.primary : colors.success.withValues(alpha: 0.6),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_rounded, size: 14, color: colors.success),
            const SizedBox(width: 6),
            Text(
              node.title.toUpperCase(),
              style: TextStyle(
                color: colors.success,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                letterSpacing: 0.06,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: isGhost ? Colors.transparent : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? colors.primary
              : (node.risk
                  ? colors.danger.withValues(alpha: 0.7)
                  : (isGhost
                      ? colors.accent.withValues(alpha: 0.7)
                      : colors.divider)),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.20),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: mode == CanvasMode.mastery && node.mastery != null
                  ? _masteryColor(node.mastery!, colors)
                  : accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                bottomLeft: Radius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        _typeLabel(node.type),
                        style: TextStyle(
                          color: accent,
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (node.risk) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.warning_amber_rounded,
                            size: 11, color: colors.danger),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    node.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  if (_meta(node) != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _meta(node)!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 10.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Mastery chip
          if (!isGhost &&
              node.type != CourseNodeType.module &&
              node.mastery != null &&
              node.mastery! > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: mode == CanvasMode.mastery
                      ? Colors.transparent
                      : colors.surfaceSoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(node.mastery! * 100).round()}%',
                  style: TextStyle(
                    color: mode == CanvasMode.mastery
                        ? _masteryColor(node.mastery!, colors)
                        : colors.textSecondary,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _typeLabel(CourseNodeType t) {
    return switch (t) {
      CourseNodeType.module => 'MODULE',
      CourseNodeType.lesson => 'LESSON',
      CourseNodeType.quiz => 'QUIZ',
      CourseNodeType.practice => 'LAB',
      CourseNodeType.milestone => 'MILESTONE',
      CourseNodeType.ghost => 'AI DRAFT',
    };
  }

  Color _accentFor(CourseNode node, AppThemeColors colors) {
    return switch (node.type) {
      CourseNodeType.module => colors.primary,
      CourseNodeType.lesson => colors.primary,
      CourseNodeType.quiz => colors.accent,
      CourseNodeType.practice => const Color(0xFFB4A8FF),
      CourseNodeType.milestone => colors.success,
      CourseNodeType.ghost => colors.accent,
    };
  }

  String? _meta(CourseNode node) {
    if (node.lessonCount != null && node.lessonCount! > 0) {
      return '${node.lessonCount} lessons';
    }
    if (node.durationMinutes != null) return '${node.durationMinutes} min';
    if (node.itemCount != null) return '${node.itemCount} items';
    return node.hint;
  }

  Color _masteryColor(double v, AppThemeColors c) {
    if (v >= 0.85) return c.success;
    if (v >= 0.70) return c.primary;
    if (v >= 0.55) return const Color(0xFFFBBF24);
    if (v >= 0.40) return c.accent;
    return c.danger;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connect handle (small circle on the right edge of a selected node)
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectHandle extends StatelessWidget {
  const _ConnectHandle({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: active ? colors.accent : colors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colors.backgroundElevated, width: 2),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected-node mini-toolbar (delete)
// ─────────────────────────────────────────────────────────────────────────────

class _NodePop extends StatelessWidget {
  const _NodePop({required this.onDelete});
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.divider),
      ),
      child: Tooltip(
        message: 'Delete node',
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onDelete,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(Icons.close_rounded, size: 14, color: colors.danger),
          ),
        ),
      ),
    );
  }
}
