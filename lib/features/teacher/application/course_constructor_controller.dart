// Riverpod controller for the Course Constructor.
//
// Owns: the in-flight CourseGraph, the currently-selected node, the
// "connect-from" handle, and the canvas mode (structure / mastery / funnel).
//
// All mutations go through here so undo/redo can be added later (history
// stack — TODO Phase 2).

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/course_graph.dart';
import '../domain/services/course_auto_layout.dart';
import 'sample_course.dart';

enum CanvasMode { structure, mastery, funnel }

@immutable
class CourseConstructorState {
  const CourseConstructorState({
    required this.course,
    this.selectedNodeId,
    this.connectFromId,
    this.canvasMode = CanvasMode.structure,
  });

  final CourseGraph course;
  final String? selectedNodeId;
  final String? connectFromId;
  final CanvasMode canvasMode;

  CourseNode? get selectedNode =>
      selectedNodeId == null ? null : course.nodeById(selectedNodeId!);

  CourseConstructorState copyWith({
    CourseGraph? course,
    Object? selectedNodeId = _sentinel,
    Object? connectFromId = _sentinel,
    CanvasMode? canvasMode,
  }) {
    return CourseConstructorState(
      course: course ?? this.course,
      selectedNodeId: identical(selectedNodeId, _sentinel)
          ? this.selectedNodeId
          : selectedNodeId as String?,
      connectFromId: identical(connectFromId, _sentinel)
          ? this.connectFromId
          : connectFromId as String?,
      canvasMode: canvasMode ?? this.canvasMode,
    );
  }
}

const Object _sentinel = Object();

class CourseConstructorController extends Notifier<CourseConstructorState> {
  @override
  CourseConstructorState build() {
    return CourseConstructorState(
      course: SampleCourse.sqlForAnalysts(),
      selectedNodeId: 'n12',
    );
  }

  // ── Selection / interaction ─────────────────────────────────────────────
  void selectNode(String? id) {
    if (state.connectFromId != null && id != null && id != state.connectFromId) {
      _connect(state.connectFromId!, id);
      state = state.copyWith(connectFromId: null, selectedNodeId: id);
      return;
    }
    state = state.copyWith(selectedNodeId: id, connectFromId: null);
  }

  void clearSelection() => state = state.copyWith(
        selectedNodeId: null,
        connectFromId: null,
      );

  void startConnect() {
    final from = state.selectedNodeId ?? state.course.nodes.firstOrNull?.id;
    state = state.copyWith(connectFromId: from);
  }

  void cancelConnect() => state = state.copyWith(connectFromId: null);

  void setCanvasMode(CanvasMode mode) =>
      state = state.copyWith(canvasMode: mode);

  // ── Node CRUD ───────────────────────────────────────────────────────────
  void addNode(CourseNodeType type) {
    final sel = state.selectedNode;
    final baseX = sel?.position.dx ?? 200;
    final baseY = (sel?.position.dy ?? 200) + 140;

    final id = generateNodeId();
    final node = CourseNode(
      id: id,
      type: type,
      title: _titleFor(type),
      position: Offset(baseX, baseY),
      durationMinutes: type == CourseNodeType.lesson ? 10 : null,
      itemCount: switch (type) {
        CourseNodeType.quiz => 5,
        CourseNodeType.practice => 5,
        _ => null,
      },
      lessonCount: type == CourseNodeType.module ? 0 : null,
      blocks: defaultBlocksFor(type),
    );

    state = state.copyWith(
      course: state.course.copyWith(nodes: [...state.course.nodes, node]),
      selectedNodeId: id,
    );
  }

  void deleteNode(String id) {
    final filteredNodes = state.course.nodes.where((n) => n.id != id).toList();
    final filteredEdges =
        state.course.edges.where((e) => e.from != id && e.to != id).toList();
    state = state.copyWith(
      course: state.course.copyWith(
        nodes: filteredNodes,
        edges: filteredEdges,
      ),
      selectedNodeId: state.selectedNodeId == id ? null : state.selectedNodeId,
    );
  }

  void updateNode(String id, {String? title, int? duration, int? itemCount}) {
    state = state.copyWith(
      course: state.course.copyWith(
        nodes: state.course.nodes.map((n) {
          if (n.id != id) return n;
          return n.copyWith(
            title: title,
            durationMinutes: duration,
            itemCount: itemCount,
          );
        }).toList(),
      ),
    );
  }

  void moveNode(String id, Offset position) {
    state = state.copyWith(
      course: state.course.copyWith(
        nodes: state.course.nodes.map((n) {
          if (n.id != id) return n;
          return n.copyWith(position: position);
        }).toList(),
      ),
    );
  }

  // ── Edge CRUD ───────────────────────────────────────────────────────────
  void _connect(String from, String to) {
    if (from == to) return;
    final exists = state.course.edges.any((e) => e.from == from && e.to == to);
    if (exists) return;
    state = state.copyWith(
      course: state.course.copyWith(
        edges: [...state.course.edges, CourseEdge(from: from, to: to)],
      ),
    );
  }

  void removeEdge(String from, String to) {
    state = state.copyWith(
      course: state.course.copyWith(
        edges: state.course.edges
            .where((e) => !(e.from == from && e.to == to))
            .toList(),
      ),
    );
  }

  // ── Block CRUD ──────────────────────────────────────────────────────────
  void addBlock(String nodeId, CourseBlockType type) {
    final block = freshBlock(type);
    state = state.copyWith(
      course: state.course.copyWith(
        nodes: state.course.nodes.map((n) {
          if (n.id != nodeId) return n;
          return n.copyWith(blocks: [...n.blocks, block]);
        }).toList(),
      ),
    );
  }

  void updateBlock(
    String nodeId,
    String blockId, {
    String? title,
    String? body,
    String? url,
    String? language,
    int? durationMinutes,
    int? itemCount,
    CourseCalloutTone? tone,
  }) {
    state = state.copyWith(
      course: state.course.copyWith(
        nodes: state.course.nodes.map((n) {
          if (n.id != nodeId) return n;
          return n.copyWith(
            blocks: n.blocks.map((b) {
              if (b.id != blockId) return b;
              return b.copyWith(
                title: title,
                body: body,
                url: url,
                language: language,
                durationMinutes: durationMinutes,
                itemCount: itemCount,
                tone: tone,
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  void removeBlock(String nodeId, String blockId) {
    state = state.copyWith(
      course: state.course.copyWith(
        nodes: state.course.nodes.map((n) {
          if (n.id != nodeId) return n;
          return n.copyWith(blocks: n.blocks.where((b) => b.id != blockId).toList());
        }).toList(),
      ),
    );
  }

  /// Used by ReorderableListView: moves the block at [oldIndex] to [newIndex].
  void reorderBlocks(String nodeId, int oldIndex, int newIndex) {
    state = state.copyWith(
      course: state.course.copyWith(
        nodes: state.course.nodes.map((n) {
          if (n.id != nodeId) return n;
          final blocks = List<CourseBlock>.from(n.blocks);
          if (oldIndex < 0 || oldIndex >= blocks.length) return n;
          // ReorderableListView convention: newIndex is the index *before* removal.
          final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
          final item = blocks.removeAt(oldIndex);
          blocks.insert(target.clamp(0, blocks.length), item);
          return n.copyWith(blocks: blocks);
        }).toList(),
      ),
    );
  }

  // ── Layout ──────────────────────────────────────────────────────────────
  void applyAutoLayout() {
    state = state.copyWith(
      course: const CourseAutoLayout().apply(state.course),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  String _titleFor(CourseNodeType type) {
    return switch (type) {
      CourseNodeType.lesson => 'New lesson',
      CourseNodeType.quiz => 'New quiz',
      CourseNodeType.practice => 'New lab',
      CourseNodeType.module => 'New module',
      CourseNodeType.milestone => 'New milestone',
      CourseNodeType.ghost => 'AI draft',
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final courseConstructorProvider =
    NotifierProvider<CourseConstructorController, CourseConstructorState>(
  CourseConstructorController.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Default content blocks for fresh nodes
// ─────────────────────────────────────────────────────────────────────────────

List<CourseBlock> defaultBlocksFor(CourseNodeType type) {
  switch (type) {
    case CourseNodeType.module:
      return <CourseBlock>[
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.text,
          title: 'Module brief',
          body:
              'Group of lessons that share a learning goal. Add child lessons by connecting them from this node.',
        ),
      ];
    case CourseNodeType.quiz:
      return <CourseBlock>[
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.text,
          title: 'Instructions',
          body:
              'Auto-graded; one attempt allowed before the next module unlocks.',
        ),
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.quiz,
          title: 'Items',
          body: '5 questions',
          itemCount: 5,
        ),
      ];
    case CourseNodeType.practice:
      return <CourseBlock>[
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.text,
          title: 'Brief',
          body:
              'Hands-on lab with auto-checks. Learners submit a solution and receive feedback per puzzle.',
        ),
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.code,
          title: 'Starter code',
          body: '-- Your query here',
          language: 'sql',
        ),
      ];
    case CourseNodeType.milestone:
      return <CourseBlock>[
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.callout,
          title: 'Awarded automatically',
          body:
              'Issued when all prerequisite modules are 100% complete.',
          tone: CourseCalloutTone.success,
        ),
      ];
    case CourseNodeType.ghost:
      return <CourseBlock>[
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.text,
          title: 'AI draft',
          body: 'This block was drafted by the AI co-author.',
        ),
      ];
    case CourseNodeType.lesson:
      return <CourseBlock>[
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.text,
          title: 'Lesson body',
          body:
              'Roughly 10 minutes of reading + worked examples. Replace this block with the real content.',
        ),
        CourseBlock(
          id: generateBlockId(),
          type: CourseBlockType.quiz,
          title: 'Check',
          body: '2 quick checks',
          itemCount: 2,
        ),
      ];
  }
}

CourseBlock freshBlock(CourseBlockType type) {
  switch (type) {
    case CourseBlockType.video:
      return CourseBlock(
        id: generateBlockId(),
        type: type,
        title: 'New video',
        body: '5 min walkthrough',
        durationMinutes: 5,
      );
    case CourseBlockType.code:
      return CourseBlock(
        id: generateBlockId(),
        type: type,
        title: 'Code example',
        body: '-- write SQL here',
        language: 'sql',
      );
    case CourseBlockType.quiz:
      return CourseBlock(
        id: generateBlockId(),
        type: type,
        title: 'Check',
        body: 'MCQ items',
        itemCount: 3,
      );
    case CourseBlockType.callout:
      return CourseBlock(
        id: generateBlockId(),
        type: type,
        title: 'Note',
        body: 'Add a key insight or warning.',
        tone: CourseCalloutTone.primary,
      );
    case CourseBlockType.text:
      return CourseBlock(
        id: generateBlockId(),
        type: type,
        title: 'New block',
        body: 'Write the content here. Markdown supported.',
      );
  }
}
