// Auto-layout algorithm for the course knowledge graph.
//
// Produces tidy positions for every node:
//
//   ┌────────┐    ┌────────┐    ┌────────┐
//   │ M1     │───▶│ M2     │───▶│ M3     │
//   └────────┘    └────────┘    └────────┘
//      │             │             │
//   ┌──▼──────┐   ┌──▼──────┐   ┌──▼──────┐
//   │ Lesson  │   │ Lesson  │   │ Lesson  │
//   │ Lesson  │   │ Lesson  │   │ Lesson  │
//   │ Quiz    │   │ Lab     │   │ Quiz    │
//   └─────────┘   └─────────┘   └─────────┘
//
// Strategy:
//   1. Find module nodes — these become columns, ordered topologically.
//   2. For each module: BFS downstream, stopping at the next module. Children
//      get stacked vertically in the column.
//   3. Orphan nodes (no module ancestor) get an "Unlinked" column at the end.
//   4. If the graph has zero modules, fall back to pure layered layout.

import 'dart:ui';

import '../models/course_graph.dart';

class CourseAutoLayout {
  const CourseAutoLayout({
    this.columnSpacing = 330,
    this.rowSpacing = 150,
    this.originX = 120,
    this.originY = 120,
    this.moduleGap = 170,
  });

  /// Horizontal distance between module columns.
  final double columnSpacing;

  /// Vertical distance between rows inside a column.
  final double rowSpacing;

  /// Top-left origin of the laid-out graph.
  final double originX;
  final double originY;

  /// Vertical gap between a module header and its first child.
  final double moduleGap;

  /// Returns a copy of [course] where every node's position has been replaced
  /// by an auto-computed one.
  CourseGraph apply(CourseGraph course) {
    final positions = _compute(course);
    final repositioned = course.nodes.map((n) {
      final p = positions[n.id];
      if (p == null) return n;
      return n.copyWith(position: p);
    }).toList();
    return course.copyWith(nodes: repositioned);
  }

  /// Compute new positions without mutating the course.
  Map<String, Offset> _compute(CourseGraph course) {
    final modules = course.nodes
        .where((n) => n.type == CourseNodeType.module)
        .toList();

    if (modules.isEmpty) {
      return _layered(course);
    }

    // Order modules: topological (by incoming-from-module edges), with current
    // X position as a tiebreaker so the user's manual ordering is preserved.
    final orderedModules = _topologicalOrderModules(course, modules);

    final pos = <String, Offset>{};
    final placed = <String>{};
    var columnIndex = 0;

    for (final mod in orderedModules) {
      final x = originX + columnIndex * columnSpacing;
      // Place the module header
      pos[mod.id] = Offset(x, originY);
      placed.add(mod.id);

      // BFS downstream, but stop when we hit a different module.
      final adj = course.adjacency;
      final queue = <String>[...?adj[mod.id]];
      final localOrder = <String>[];
      final visited = <String>{mod.id};
      while (queue.isNotEmpty) {
        final id = queue.removeAt(0);
        if (!visited.add(id)) continue;
        final n = course.nodeById(id);
        if (n == null) continue;
        if (n.type == CourseNodeType.module) {
          continue; // belongs to its own column
        }
        if (placed.contains(id)) continue;
        localOrder.add(id);
        final next = adj[id];
        if (next != null) queue.addAll(next);
      }

      // Place the column's children. Preserve current Y order if available.
      localOrder.sort((a, b) {
        final na = course.nodeById(a);
        final nb = course.nodeById(b);
        return (na?.position.dy ?? 0).compareTo(nb?.position.dy ?? 0);
      });
      for (var i = 0; i < localOrder.length; i++) {
        final id = localOrder[i];
        pos[id] = Offset(x, originY + moduleGap + i * rowSpacing);
        placed.add(id);
      }
      columnIndex++;
    }

    // Orphans (e.g. ghost AI drafts not connected via any module path) go in
    // a trailing column.
    final orphans = course.nodes.where((n) => !placed.contains(n.id)).toList();
    if (orphans.isNotEmpty) {
      final x = originX + columnIndex * columnSpacing;
      for (var i = 0; i < orphans.length; i++) {
        pos[orphans[i].id] = Offset(x, originY + i * rowSpacing);
      }
    }

    return pos;
  }

  // Topological ordering of module nodes by module→module edges, using the
  // current X coordinate as a tiebreaker. Falls back to current X for cycles.
  List<CourseNode> _topologicalOrderModules(
    CourseGraph course,
    List<CourseNode> modules,
  ) {
    final moduleIds = modules.map((m) => m.id).toSet();
    final inDegree = <String, int>{for (final m in modules) m.id: 0};
    final adj = <String, List<String>>{};

    for (final e in course.edges) {
      if (!moduleIds.contains(e.from) || !moduleIds.contains(e.to)) continue;
      (adj[e.from] ??= <String>[]).add(e.to);
      inDegree[e.to] = (inDegree[e.to] ?? 0) + 1;
    }

    // Kahn's algorithm. Ready queue is sorted by current X.
    final ready = modules.where((m) => (inDegree[m.id] ?? 0) == 0).toList();
    ready.sort((a, b) => a.position.dx.compareTo(b.position.dx));

    final ordered = <CourseNode>[];
    while (ready.isNotEmpty) {
      final m = ready.removeAt(0);
      ordered.add(m);
      final outs = adj[m.id];
      if (outs == null) continue;
      for (final id in outs) {
        final remaining = (inDegree[id] ?? 0) - 1;
        inDegree[id] = remaining;
        if (remaining == 0) {
          final m2 = modules.firstWhere((x) => x.id == id);
          ready.add(m2);
          ready.sort((a, b) => a.position.dx.compareTo(b.position.dx));
        }
      }
    }

    // Anything left (cycle) — append in current-X order.
    if (ordered.length < modules.length) {
      final leftovers = modules.where((m) => !ordered.contains(m)).toList()
        ..sort((a, b) => a.position.dx.compareTo(b.position.dx));
      ordered.addAll(leftovers);
    }
    return ordered;
  }

  // Fallback: pure layered layout (longest-path layering). Used when the
  // graph has no module nodes.
  Map<String, Offset> _layered(CourseGraph course) {
    final layer = <String, int>{};
    final adj = course.adjacency;
    final rev = course.reverseAdjacency;

    // Roots = nodes with no incoming edges.
    final roots = course.nodes
        .where((n) => (rev[n.id]?.isEmpty ?? true))
        .map((n) => n.id)
        .toList();

    // BFS, layer = max(predecessor layer) + 1.
    final queue = <String>[...roots];
    for (final r in roots) {
      layer[r] = 0;
    }
    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      final outs = adj[id];
      if (outs == null) continue;
      for (final nx in outs) {
        final candidate = (layer[id] ?? 0) + 1;
        if (candidate > (layer[nx] ?? -1)) {
          layer[nx] = candidate;
          queue.add(nx);
        }
      }
    }

    // Group by layer.
    final byLayer = <int, List<String>>{};
    for (final n in course.nodes) {
      final l = layer[n.id] ?? 0;
      (byLayer[l] ??= <String>[]).add(n.id);
    }

    final pos = <String, Offset>{};
    final layerKeys = byLayer.keys.toList()..sort();
    for (final l in layerKeys) {
      final ids = byLayer[l]!;
      // Stable order: by current Y, then current X.
      ids.sort((a, b) {
        final na = course.nodeById(a)!;
        final nb = course.nodeById(b)!;
        final cy = na.position.dy.compareTo(nb.position.dy);
        return cy != 0 ? cy : na.position.dx.compareTo(nb.position.dx);
      });
      for (var i = 0; i < ids.length; i++) {
        pos[ids[i]] = Offset(
          originX + l * columnSpacing,
          originY + i * rowSpacing,
        );
      }
    }
    return pos;
  }
}
