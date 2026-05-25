// Course Builder page (replaces the previous stub).
//
// Layout:
//
//   Desktop / web wide (>= 900px)
//   ┌──────────────────┬──────────────────────────────────────┬──────────────┐
//   │ CourseOutline    │ Knowledge graph canvas               │ LessonDetail │
//   │ (280 px)         │                                      │ (420 px)     │
//   └──────────────────┴──────────────────────────────────────┴──────────────┘
//
//   Compact (Android / phone web)
//   ┌──────────────────────────────────────────────────────────────────────┐
//   │ Canvas (full bleed)                                                  │
//   │  · outline reachable via top toolbar (modal sheet)                   │
//   │  · selecting a node opens LessonDetail as a bottom sheet             │
//   └──────────────────────────────────────────────────────────────────────┘

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../application/course_constructor_controller.dart';
import '../../domain/models/course_graph.dart';
import '../widgets/course_outline_panel.dart';
import '../widgets/export_json_dialog.dart';
import '../widgets/knowledge_graph_canvas.dart';
import '../widgets/lesson_detail_panel.dart';

/// Display mode for the outline panel on wide layouts.
enum OutlineMode { labels, icons, hidden }

class TeacherCourseBuilderPage extends ConsumerStatefulWidget {
  const TeacherCourseBuilderPage({super.key});

  static const double _compactBreakpoint = 900;
  static const double _outlineWidth = 280;
  static const double _outlineWidthIcons = 64;
  static const double _detailWidth = 420;

  @override
  ConsumerState<TeacherCourseBuilderPage> createState() =>
      _TeacherCourseBuilderPageState();
}

class _TeacherCourseBuilderPageState
    extends ConsumerState<TeacherCourseBuilderPage> {
  OutlineMode _outlineMode = OutlineMode.labels;

  void _cycleOutline() {
    setState(() {
      _outlineMode = switch (_outlineMode) {
        OutlineMode.labels => OutlineMode.icons,
        OutlineMode.icons => OutlineMode.hidden,
        OutlineMode.hidden => OutlineMode.labels,
      };
    });
  }

  double get _outlineWidthFor {
    return switch (_outlineMode) {
      OutlineMode.labels => TeacherCourseBuilderPage._outlineWidth,
      OutlineMode.icons => TeacherCourseBuilderPage._outlineWidthIcons,
      OutlineMode.hidden => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < TeacherCourseBuilderPage._compactBreakpoint;

    final selectedId =
        ref.watch(courseConstructorProvider.select((s) => s.selectedNodeId));
    final course =
        ref.watch(courseConstructorProvider.select((s) => s.course));

    const canvas = KnowledgeGraphCanvas();

    if (compact) {
      // Compact layout: bottom-sheet for detail, top app bar for outline.
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.backgroundElevated,
          elevation: 0,
          title: Text(
            course.title,
            style: TextStyle(color: colors.textPrimary, fontSize: 15),
          ),
          actions: [
            IconButton(
              tooltip: 'Outline',
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _showOutlineSheet(context),
            ),
            IconButton(
              tooltip: 'Export JSON',
              icon: const Icon(Icons.upload_rounded),
              onPressed: () => ExportJsonDialog.show(context),
            ),
            IconButton(
              tooltip: 'Publish',
              icon: const Icon(Icons.cloud_upload_rounded),
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            canvas,
            if (selectedId != null)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: SafeArea(
                  top: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.backgroundElevated,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: const _SheetGrip(child: LessonDetailPanel()),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Desktop / wide
    final outlineWidth = _outlineWidthFor;
    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: outlineWidth,
            child: outlineWidth > 0
                ? CourseOutlinePanel(compact: _outlineMode == OutlineMode.icons)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: canvas),
                // Floating top-left outline toggle (always visible)
                Positioned(
                  top: 14,
                  left: 14,
                  child: _OutlineToggle(
                    mode: _outlineMode,
                    onPressed: _cycleOutline,
                  ),
                ),
                // Floating top-right action bar
                Positioned(
                  top: 14,
                  right: selectedId != null
                      ? TeacherCourseBuilderPage._detailWidth + 14
                      : 14,
                  child: _TopActions(course: course),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: selectedId != null
                ? TeacherCourseBuilderPage._detailWidth
                : 0,
            child: selectedId != null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: colors.divider)),
                    ),
                    child: const LessonDetailPanel(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showOutlineSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: const CourseOutlinePanel(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top-right floating actions
// ─────────────────────────────────────────────────────────────────────────────

class _TopActions extends StatelessWidget {
  const _TopActions({required this.course});
  final CourseGraph course;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${course.code} · v${course.version}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(width: 10),
              Text('·',
                  style: TextStyle(
                      color: colors.divider, fontFamily: 'monospace')),
              const SizedBox(width: 10),
              Text(
                course.title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: colors.success.withValues(alpha: 0.4)),
                ),
                child: Text(
                  course.status.code.toUpperCase(),
                  style: TextStyle(
                    color: colors.success,
                    fontSize: 9.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.divider),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          icon: const Icon(Icons.visibility_outlined, size: 14),
          label: const Text('Preview'),
        ),
        const SizedBox(width: 6),
        OutlinedButton.icon(
          onPressed: () => ExportJsonDialog.show(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.divider),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          icon: const Icon(Icons.upload_rounded, size: 14),
          label: const Text('Export JSON'),
        ),
        const SizedBox(width: 6),
        FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: const Color(0xFF062623),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          icon: const Icon(Icons.sync_rounded, size: 14),
          label: const Text('Publish v3.3'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet grip (small handle shown above the bottom-sheet detail on mobile)
// ─────────────────────────────────────────────────────────────────────────────

class _SheetGrip extends StatelessWidget {
  const _SheetGrip({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: colors.divider,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Flexible(child: child),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outline panel toggle (labels → icons → hidden)
// ─────────────────────────────────────────────────────────────────────────────

class _OutlineToggle extends StatelessWidget {
  const _OutlineToggle({required this.mode, required this.onPressed});

  final OutlineMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, tooltip) = switch (mode) {
      OutlineMode.labels => (Icons.view_sidebar_rounded, 'Collapse outline'),
      OutlineMode.icons => (Icons.first_page_rounded, 'Hide outline'),
      OutlineMode.hidden => (Icons.last_page_rounded, 'Show outline'),
    };
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.divider),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: colors.textSecondary),
          ),
        ),
      ),
    );
  }
}
