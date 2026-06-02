// Left-side course outline panel.
//
// Shows the course as a collapsible tree of modules → children, lets the user
// jump to any node and quick-add new ones.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../application/course_constructor_controller.dart';
import '../../domain/models/course_graph.dart';

class CourseOutlinePanel extends ConsumerStatefulWidget {
  const CourseOutlinePanel({super.key});

  @override
  ConsumerState<CourseOutlinePanel> createState() => _CourseOutlinePanelState();
}

class _CourseOutlinePanelState extends ConsumerState<CourseOutlinePanel> {
  final _openModules = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseConstructorProvider);
    final controller = ref.read(courseConstructorProvider.notifier);
    final colors = context.appColors;

    final modules = state.course.nodes
        .where((n) => n.type == CourseNodeType.module)
        .toList();
    final tracked = <String>{
      for (final m in modules) m.id,
      for (final m in modules) ...state.course.descendantsOf(m.id).map((n) => n.id),
    };
    final orphans = state.course.nodes
        .where((n) => !tracked.contains(n.id))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        border: Border(right: BorderSide(color: colors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CourseHeader(course: state.course),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 8, 4),
                  child: Row(
                    children: [
                      Text('OUTLINE',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 0.14,
                            fontWeight: FontWeight.w600,
                          )),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Add module',
                        iconSize: 14,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        onPressed: () =>
                            controller.addNode(CourseNodeType.module),
                        icon: Icon(Icons.add_rounded, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                for (final mod in modules)
                  _ModuleBlock(
                    module: mod,
                    children: state.course.descendantsOf(mod.id),
                    open: _openModules[mod.id] ?? true,
                    selectedId: state.selectedNodeId,
                    onToggle: () => setState(() {
                      _openModules[mod.id] = !(_openModules[mod.id] ?? true);
                    }),
                    onSelect: controller.selectNode,
                  ),
                if (orphans.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 8, 4),
                    child: Text('UNLINKED',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 10,
                          letterSpacing: 0.14,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  for (final n in orphans)
                    _LessonRow(
                      node: n,
                      selected: state.selectedNodeId == n.id,
                      onTap: () => controller.selectNode(n.id),
                    ),
                ],
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: Text('QUICK ADD',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 10,
                        letterSpacing: 0.14,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _QuickAdd(
                        icon: Icons.menu_book_rounded,
                        label: 'Lesson',
                        onTap: () => controller.addNode(CourseNodeType.lesson),
                      ),
                      _QuickAdd(
                        icon: Icons.quiz_rounded,
                        label: 'Quiz',
                        onTap: () => controller.addNode(CourseNodeType.quiz),
                      ),
                      _QuickAdd(
                        icon: Icons.science_rounded,
                        label: 'Lab',
                        onTap: () =>
                            controller.addNode(CourseNodeType.practice),
                      ),
                      _QuickAdd(
                        icon: Icons.flag_rounded,
                        label: 'Milestone',
                        onTap: () =>
                            controller.addNode(CourseNodeType.milestone),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.course});
  final CourseGraph course;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COURSE',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              letterSpacing: 0.14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${course.code} · v${course.version}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10.5,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Text(
                '${course.nodes.length} nodes',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10.5,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module block (header + children)
// ─────────────────────────────────────────────────────────────────────────────

class _ModuleBlock extends StatelessWidget {
  const _ModuleBlock({
    required this.module,
    required this.children,
    required this.open,
    required this.selectedId,
    required this.onToggle,
    required this.onSelect,
  });

  final CourseNode module;
  final List<CourseNode> children;
  final bool open;
  final String? selectedId;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => onSelect(module.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedRotation(
                    turns: open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 16, color: colors.textSecondary),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    module.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${children.length}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (open)
          ...children.map((c) => _LessonRow(
                node: c,
                selected: selectedId == c.id,
                onTap: () => onSelect(c.id),
              )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lesson row
// ─────────────────────────────────────────────────────────────────────────────

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.node,
    required this.selected,
    required this.onTap,
  });

  final CourseNode node;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(34, 6, 12, 6),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            _typeDot(colors),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? colors.textPrimary : colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              _meta(node),
              style: TextStyle(
                color: colors.textSecondary.withValues(alpha: 0.7),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeDot(AppThemeColors colors) {
    final color = switch (node.type) {
      CourseNodeType.lesson => colors.primary,
      CourseNodeType.quiz => colors.accent,
      CourseNodeType.practice => const Color(0xFFB4A8FF),
      CourseNodeType.milestone => colors.success,
      CourseNodeType.ghost => colors.accent.withValues(alpha: 0.5),
      CourseNodeType.module => colors.primary,
    };
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: node.type == CourseNodeType.ghost ? Colors.transparent : color,
        border: node.type == CourseNodeType.ghost
            ? Border.all(color: colors.accent, width: 1, style: BorderStyle.solid)
            : null,
        borderRadius: BorderRadius.circular(
          node.type == CourseNodeType.milestone ? 999 : 2,
        ),
      ),
    );
  }

  String _meta(CourseNode n) {
    if (n.durationMinutes != null) return '${n.durationMinutes}m';
    if (n.type == CourseNodeType.quiz && n.itemCount != null) return '${n.itemCount}q';
    if (n.type == CourseNodeType.practice && n.itemCount != null) return '${n.itemCount}p';
    return '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick-add chip
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
