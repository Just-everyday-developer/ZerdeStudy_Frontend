// Course constructor domain models.
//
// These are the data structures that back the Course Builder, and which
// round-trip through the JSON export schema `zerdestudy.course.v3`.
//
// The model is intentionally separate from the existing `DemoCatalog` /
// `LearningTrack` / `LessonItem` types — those are the LEARNER's view of a
// course, while these are the AUTHOR's view (a knowledge-graph of authoring
// nodes whose content is built from typed blocks).
//
// Adapters between this model and `LearningTrack` live in
// `lib/features/teacher/domain/services/course_graph_to_track.dart` (later
// migration phase).

import 'dart:ui';

/// Top-level type of a node in the course graph.
enum CourseNodeType {
  module,
  lesson,
  quiz,
  practice,
  milestone,
  ghost; // AI-drafted, not yet approved.

  static CourseNodeType fromCode(String? code) {
    return CourseNodeType.values.firstWhere(
      (t) => t.name == code,
      orElse: () => CourseNodeType.lesson,
    );
  }

  String get code => name;
}

/// Lifecycle of the course as a whole.
enum CourseStatus {
  draft,
  review,
  live;

  static CourseStatus fromCode(String? code) {
    return CourseStatus.values.firstWhere(
      (s) => s.name == code,
      orElse: () => CourseStatus.draft,
    );
  }

  String get code => name;
}

/// Type of a content block inside a node.
enum CourseBlockType {
  text,
  video,
  code,
  quiz,
  callout;

  static CourseBlockType fromCode(String? code) {
    return CourseBlockType.values.firstWhere(
      (t) => t.name == code,
      orElse: () => CourseBlockType.text,
    );
  }
}

/// Visual tone for a callout block.
enum CourseCalloutTone {
  primary,
  warn,
  danger,
  success;

  static CourseCalloutTone fromCode(String? code) {
    return CourseCalloutTone.values.firstWhere(
      (t) => t.name == code,
      orElse: () => CourseCalloutTone.primary,
    );
  }

  String get code => name;
}

/// Edge between two nodes.
enum CourseEdgeKind {
  prerequisite,
  reference;

  static CourseEdgeKind fromCode(String? code) {
    return CourseEdgeKind.values.firstWhere(
      (k) => k.name == code,
      orElse: () => CourseEdgeKind.prerequisite,
    );
  }

  String get code => name;
}

// ─────────────────────────────────────────────────────────────────────────────
// Blocks
// ─────────────────────────────────────────────────────────────────────────────

/// One block of content inside a course node (lesson / quiz / practice / …).
///
/// We use a single class rather than a sealed hierarchy because (a) the JSON
/// schema is flat, (b) `ReorderableListView` is much simpler with a uniform
/// item type, and (c) renderers can switch on [type].
class CourseBlock {
  const CourseBlock({
    required this.id,
    required this.type,
    required this.title,
    this.body = '',
    this.url,
    this.language,
    this.durationMinutes,
    this.itemCount,
    this.tone,
  });

  final String id;
  final CourseBlockType type;
  final String title;
  final String body;

  /// Video URL, when [type] is [CourseBlockType.video].
  final String? url;

  /// Source language identifier, when [type] is [CourseBlockType.code].
  final String? language;

  /// Length in minutes (video / lesson estimate).
  final int? durationMinutes;

  /// Number of quiz items, when [type] is [CourseBlockType.quiz].
  final int? itemCount;

  /// Visual tone for callouts.
  final CourseCalloutTone? tone;

  CourseBlock copyWith({
    String? title,
    String? body,
    String? url,
    String? language,
    int? durationMinutes,
    int? itemCount,
    CourseCalloutTone? tone,
  }) {
    return CourseBlock(
      id: id,
      type: type,
      title: title ?? this.title,
      body: body ?? this.body,
      url: url ?? this.url,
      language: language ?? this.language,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      itemCount: itemCount ?? this.itemCount,
      tone: tone ?? this.tone,
    );
  }

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{
      'id': id,
      'type': type.name,
      'title': title,
    };
    if (body.isNotEmpty) out['body'] = body;
    if (url != null && url!.isNotEmpty) out['url'] = url;
    if (language != null && language!.isNotEmpty) out['lang'] = language;
    if (durationMinutes != null) out['duration'] = durationMinutes;
    if (itemCount != null) out['items'] = itemCount;
    if (tone != null) out['tone'] = tone!.code;
    return out;
  }

  factory CourseBlock.fromJson(Map<String, dynamic> json) {
    return CourseBlock(
      id: json['id'] as String? ?? _autoId('b'),
      type: CourseBlockType.fromCode(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      url: json['url'] as String?,
      language: json['lang'] as String?,
      durationMinutes: (json['duration'] as num?)?.toInt(),
      itemCount: (json['items'] as num?)?.toInt(),
      tone: json['tone'] == null
          ? null
          : CourseCalloutTone.fromCode(json['tone'] as String),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nodes & edges
// ─────────────────────────────────────────────────────────────────────────────

/// A node in the knowledge graph that the teacher authors.
class CourseNode {
  const CourseNode({
    required this.id,
    required this.type,
    required this.title,
    required this.position,
    this.durationMinutes,
    this.itemCount,
    this.lessonCount,
    this.mastery,
    this.risk = false,
    this.blocks = const <CourseBlock>[],
    this.hint,
  });

  final String id;
  final CourseNodeType type;
  final String title;
  final Offset position;

  /// Estimated duration in minutes, for lessons.
  final int? durationMinutes;

  /// Number of items, for quizzes / practice labs.
  final int? itemCount;

  /// Number of child lessons, for modules.
  final int? lessonCount;

  /// Learner mastery 0..1, populated by analytics (optional in export).
  final double? mastery;

  /// True when analytics flagged this node as at-risk (drop-off).
  final bool risk;

  /// Authored content blocks.
  final List<CourseBlock> blocks;

  /// Short hint shown on ghost / AI nodes.
  final String? hint;

  CourseNode copyWith({
    String? title,
    Offset? position,
    int? durationMinutes,
    int? itemCount,
    int? lessonCount,
    double? mastery,
    bool? risk,
    List<CourseBlock>? blocks,
    String? hint,
  }) {
    return CourseNode(
      id: id,
      type: type,
      title: title ?? this.title,
      position: position ?? this.position,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      itemCount: itemCount ?? this.itemCount,
      lessonCount: lessonCount ?? this.lessonCount,
      mastery: mastery ?? this.mastery,
      risk: risk ?? this.risk,
      blocks: blocks ?? this.blocks,
      hint: hint ?? this.hint,
    );
  }

  Map<String, dynamic> toJson({
    bool includePosition = true,
    bool includeAnalytics = false,
  }) {
    final out = <String, dynamic>{
      'id': id,
      'type': type.code,
      'title': title,
    };
    if (durationMinutes != null) out['duration'] = durationMinutes;
    if (itemCount != null) out['itemCount'] = itemCount;
    if (lessonCount != null) out['lessonCount'] = lessonCount;
    if (hint != null && hint!.isNotEmpty) out['hint'] = hint;
    if (includePosition) {
      out['position'] = {
        'x': position.dx.round(),
        'y': position.dy.round(),
      };
    }
    if (includeAnalytics) {
      if (mastery != null) out['mastery'] = double.parse(mastery!.toStringAsFixed(2));
      if (risk) out['risk'] = true;
    }
    if (blocks.isNotEmpty) {
      out['blocks'] = blocks.map((b) => b.toJson()).toList();
    }
    return out;
  }

  factory CourseNode.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>?;
    return CourseNode(
      id: json['id'] as String? ?? _autoId('n'),
      type: CourseNodeType.fromCode(json['type'] as String?),
      title: json['title'] as String? ?? 'Untitled',
      position: Offset(
        (pos?['x'] as num?)?.toDouble() ?? 0,
        (pos?['y'] as num?)?.toDouble() ?? 0,
      ),
      durationMinutes: (json['duration'] as num?)?.toInt(),
      itemCount: (json['itemCount'] as num?)?.toInt(),
      lessonCount: (json['lessonCount'] as num?)?.toInt(),
      mastery: (json['mastery'] as num?)?.toDouble(),
      risk: json['risk'] as bool? ?? false,
      hint: json['hint'] as String?,
      blocks: (json['blocks'] as List<dynamic>? ?? const <dynamic>[])
          .map((b) => CourseBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A directed edge from one node to another.
class CourseEdge {
  const CourseEdge({
    required this.from,
    required this.to,
    this.kind = CourseEdgeKind.prerequisite,
  });

  final String from;
  final String to;
  final CourseEdgeKind kind;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'from': from,
      'to': to,
      'kind': kind.code,
    };
  }

  factory CourseEdge.fromJson(Map<String, dynamic> json) {
    return CourseEdge(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      kind: CourseEdgeKind.fromCode(json['kind'] as String?),
    );
  }

  bool get isValid => from.isNotEmpty && to.isNotEmpty && from != to;
}

// ─────────────────────────────────────────────────────────────────────────────
// Course (root aggregate)
// ─────────────────────────────────────────────────────────────────────────────

/// Root aggregate of an authored course.
class CourseGraph {
  const CourseGraph({
    required this.id,
    required this.code,
    required this.title,
    required this.version,
    required this.status,
    this.summary = '',
    this.nodes = const <CourseNode>[],
    this.edges = const <CourseEdge>[],
  });

  final String id;
  final String code;
  final String title;
  final String version;
  final CourseStatus status;
  final String summary;
  final List<CourseNode> nodes;
  final List<CourseEdge> edges;

  CourseGraph copyWith({
    String? title,
    String? version,
    CourseStatus? status,
    String? summary,
    List<CourseNode>? nodes,
    List<CourseEdge>? edges,
  }) {
    return CourseGraph(
      id: id,
      code: code,
      title: title ?? this.title,
      version: version ?? this.version,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
    );
  }

  CourseNode? nodeById(String id) {
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// All nodes downstream from [moduleId] up to but not including the next
  /// module — useful for the left-side outline tree.
  List<CourseNode> descendantsOf(String moduleId) {
    final adj = _adjacency();
    final visited = <String>{moduleId};
    final stack = <String>[...?adj[moduleId]];
    final result = <CourseNode>[];
    while (stack.isNotEmpty) {
      final id = stack.removeLast();
      if (!visited.add(id)) continue;
      final n = nodeById(id);
      if (n == null) continue;
      if (n.type == CourseNodeType.module) continue;
      result.add(n);
      final next = adj[id];
      if (next != null) stack.addAll(next);
    }
    result.sort((a, b) => a.position.dy.compareTo(b.position.dy));
    return result;
  }

  Map<String, List<String>> _adjacency() {
    final m = <String, List<String>>{};
    for (final e in edges) {
      (m[e.from] ??= <String>[]).add(e.to);
    }
    return m;
  }

  Map<String, List<String>> get adjacency => _adjacency();

  /// Reverse adjacency — for each node, the list of nodes that have an edge
  /// INTO it. Useful for computing prerequisites in the editor.
  Map<String, List<String>> get reverseAdjacency {
    final m = <String, List<String>>{};
    for (final e in edges) {
      (m[e.to] ??= <String>[]).add(e.from);
    }
    return m;
  }

  // ── JSON ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toExportJson({
    bool includePositions = true,
    bool includeAnalytics = false,
  }) {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'title': title,
      'version': version,
      'status': status.code,
      'summary': summary,
      'nodes': nodes
          .map((n) => n.toJson(
                includePosition: includePositions,
                includeAnalytics: includeAnalytics,
              ))
          .toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'schema': 'zerdestudy.course.v3',
    };
  }

  factory CourseGraph.fromJson(Map<String, dynamic> json) {
    return CourseGraph(
      id: json['id'] as String? ?? _autoId('c'),
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled course',
      version: json['version'] as String? ?? '1.0',
      status: CourseStatus.fromCode(json['status'] as String?),
      summary: json['summary'] as String? ?? '',
      nodes: (json['nodes'] as List<dynamic>? ?? const <dynamic>[])
          .map((n) => CourseNode.fromJson(n as Map<String, dynamic>))
          .toList(),
      edges: (json['edges'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => CourseEdge.fromJson(e as Map<String, dynamic>))
          .where((e) => e.isValid)
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Cheap deterministic-ish id generator. Replace with `package:uuid` when
/// wiring into the real backend.
String _autoId(String prefix) {
  final n = DateTime.now().microsecondsSinceEpoch;
  return '$prefix${n.toRadixString(36)}';
}

/// Public id generator used by the controller when adding new nodes/blocks.
String generateNodeId() => _autoId('n');
String generateBlockId() => _autoId('b');
