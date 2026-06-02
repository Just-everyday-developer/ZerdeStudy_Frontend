// Sample course seed for the constructor. Mirrors the prototype data, so the
// Flutter version of the page boots into the same SQL/01 graph.

import 'dart:ui';

import '../../domain/models/course_graph.dart';

class SampleCourse {
  static CourseGraph sqlForAnalysts() {
    final nodes = <CourseNode>[
      // ── M1 · Foundations ─────────────────────────────────────────────
      CourseNode(id: 'n1',  type: CourseNodeType.module,    title: 'M1 · Foundations',      position: const Offset(120,  120), mastery: 0.94, lessonCount: 4),
      CourseNode(id: 'n2',  type: CourseNodeType.lesson,    title: 'Relational model',      position: const Offset(120,  280), mastery: 0.92, durationMinutes: 14),
      CourseNode(id: 'n3',  type: CourseNodeType.lesson,    title: 'Tables & schemas',      position: const Offset(120,  400), mastery: 0.89, durationMinutes: 12),
      CourseNode(id: 'n4',  type: CourseNodeType.quiz,      title: 'Quiz · Vocabulary',     position: const Offset(120,  520), mastery: 0.86, itemCount: 8),

      // ── M2 · Query basics ───────────────────────────────────────────
      CourseNode(id: 'n5',  type: CourseNodeType.module,    title: 'M2 · Query basics',     position: const Offset(420,  120), mastery: 0.81, lessonCount: 5),
      CourseNode(id: 'n6',  type: CourseNodeType.lesson,    title: 'SELECT & projection',   position: const Offset(420,  280), mastery: 0.84, durationMinutes: 18),
      CourseNode(id: 'n7',  type: CourseNodeType.lesson,    title: 'WHERE & predicates',    position: const Offset(420,  400), mastery: 0.79, durationMinutes: 16),
      CourseNode(id: 'n8',  type: CourseNodeType.practice,  title: 'Lab · Filters',         position: const Offset(420,  520), mastery: 0.74, itemCount: 12),
      CourseNode(id: 'n9',  type: CourseNodeType.quiz,      title: 'Quiz · Basics',         position: const Offset(420,  640), mastery: 0.77, itemCount: 10),

      // ── M3 · Joins & sets (at-risk module) ──────────────────────────
      CourseNode(id: 'n10', type: CourseNodeType.module,    title: 'M3 · Joins & sets',     position: const Offset(720,  120), mastery: 0.48, lessonCount: 6, risk: true),
      CourseNode(id: 'n11', type: CourseNodeType.lesson,    title: 'INNER JOIN intuition',  position: const Offset(720,  280), mastery: 0.61, durationMinutes: 22),
      CourseNode(id: 'n12', type: CourseNodeType.lesson,    title: 'OUTER joins',           position: const Offset(720,  400), mastery: 0.42, durationMinutes: 24, risk: true,
        blocks: _outerJoinsBlocks()),
      CourseNode(id: 'n13', type: CourseNodeType.lesson,    title: 'Self & cross joins',    position: const Offset(720,  520), mastery: 0.36, durationMinutes: 20, risk: true),
      CourseNode(id: 'n14', type: CourseNodeType.practice,  title: 'Lab · 12 join puzzles', position: const Offset(720,  640), mastery: 0.39, itemCount: 12, risk: true),
      CourseNode(id: 'n15', type: CourseNodeType.quiz,      title: 'Quiz · Joins',          position: const Offset(720,  760), mastery: 0.44, itemCount: 14),

      // ── M4 · Aggregation ────────────────────────────────────────────
      CourseNode(id: 'n16', type: CourseNodeType.module,    title: 'M4 · Aggregation',      position: const Offset(1020, 120), mastery: 0.68, lessonCount: 4),
      CourseNode(id: 'n17', type: CourseNodeType.lesson,    title: 'GROUP BY',              position: const Offset(1020, 280), mastery: 0.72, durationMinutes: 18),
      CourseNode(id: 'n18', type: CourseNodeType.lesson,    title: 'HAVING vs WHERE',       position: const Offset(1020, 400), mastery: 0.65, durationMinutes: 14),
      CourseNode(id: 'n19', type: CourseNodeType.lesson,    title: 'Window functions',     position: const Offset(1020, 520), mastery: 0.58, durationMinutes: 26),
      CourseNode(id: 'n20', type: CourseNodeType.practice,  title: 'Lab · Reports',         position: const Offset(1020, 640), mastery: 0.62, itemCount: 10),

      // ── M5 · Capstone ───────────────────────────────────────────────
      CourseNode(id: 'n21', type: CourseNodeType.module,    title: 'M5 · Capstone',         position: const Offset(1320, 120), mastery: 0.55, lessonCount: 3),
      CourseNode(id: 'n22', type: CourseNodeType.lesson,    title: 'Schema review',         position: const Offset(1320, 280), mastery: 0.61, durationMinutes: 20),
      CourseNode(id: 'n23', type: CourseNodeType.practice,  title: 'Capstone project',      position: const Offset(1320, 400), mastery: 0.54, itemCount: 1),
      CourseNode(id: 'n24', type: CourseNodeType.milestone, title: 'Certificate',           position: const Offset(1320, 560), mastery: 0.48),

      // ── AI ghost draft ──────────────────────────────────────────────
      CourseNode(id: 'n25', type: CourseNodeType.ghost,     title: 'Bridge · Join warm-up', position: const Offset(720,  900),
        hint: 'AI draft · 4 min',
        blocks: _ghostBlocks()),
    ];

    final edges = <CourseEdge>[
      // M1
      const CourseEdge(from: 'n1',  to: 'n2'),
      const CourseEdge(from: 'n2',  to: 'n3'),
      const CourseEdge(from: 'n3',  to: 'n4'),
      // M1 → M2 → children
      const CourseEdge(from: 'n1',  to: 'n5'),
      const CourseEdge(from: 'n5',  to: 'n6'),
      const CourseEdge(from: 'n6',  to: 'n7'),
      const CourseEdge(from: 'n7',  to: 'n8'),
      const CourseEdge(from: 'n8',  to: 'n9'),
      // M2 → M3 → children
      const CourseEdge(from: 'n5',  to: 'n10'),
      const CourseEdge(from: 'n10', to: 'n11'),
      const CourseEdge(from: 'n11', to: 'n12'),
      const CourseEdge(from: 'n12', to: 'n13'),
      const CourseEdge(from: 'n13', to: 'n14'),
      const CourseEdge(from: 'n14', to: 'n15'),
      // M3 → M4 → children
      const CourseEdge(from: 'n10', to: 'n16'),
      const CourseEdge(from: 'n16', to: 'n17'),
      const CourseEdge(from: 'n17', to: 'n18'),
      const CourseEdge(from: 'n18', to: 'n19'),
      const CourseEdge(from: 'n19', to: 'n20'),
      // M4 → M5 → children
      const CourseEdge(from: 'n16', to: 'n21'),
      const CourseEdge(from: 'n21', to: 'n22'),
      const CourseEdge(from: 'n22', to: 'n23'),
      const CourseEdge(from: 'n23', to: 'n24'),
      // Ghost bridge into n12
      const CourseEdge(from: 'n25', to: 'n12'),
    ];

    return CourseGraph(
      id: 'sql-analysts',
      code: 'SQL/01',
      title: 'SQL for Analysts',
      version: '3.2',
      status: CourseStatus.live,
      summary:
          'A 24-lesson course for working analysts. Hands-on labs, AI-graded quizzes, mastery-driven graph.',
      nodes: nodes,
      edges: edges,
    );
  }

  static List<CourseBlock> _outerJoinsBlocks() {
    return <CourseBlock>[
      const CourseBlock(
        id: 'b1',
        type: CourseBlockType.text,
        title: 'Hook',
        body:
            'Outer joins exist because the world has missing data. Customers without orders, employees without managers, days with no sales. INNER JOIN throws them away. OUTER JOIN keeps them.',
      ),
      const CourseBlock(
        id: 'b2',
        type: CourseBlockType.video,
        title: 'INNER vs OUTER',
        body: '5 min diagram walkthrough',
        url: 'https://cdn.zerdestudy.kz/v/outer-intro.mp4',
        durationMinutes: 5,
      ),
      const CourseBlock(
        id: 'b3',
        type: CourseBlockType.code,
        title: 'LEFT JOIN walkthrough',
        body:
            'SELECT u.name, o.id\nFROM users u\nLEFT JOIN orders o ON o.user_id = u.id;',
        language: 'sql',
      ),
      const CourseBlock(
        id: 'b4',
        type: CourseBlockType.quiz,
        title: 'Quick check · 3 items',
        body: 'Interleaved practice',
        itemCount: 3,
      ),
      const CourseBlock(
        id: 'b5',
        type: CourseBlockType.callout,
        title: 'Common mistake',
        body:
            'Filtering NULL in a WHERE clause silently turns your LEFT JOIN back into an INNER JOIN.',
        tone: CourseCalloutTone.warn,
      ),
    ];
  }

  static List<CourseBlock> _ghostBlocks() {
    return <CourseBlock>[
      const CourseBlock(
        id: 'gb1',
        type: CourseBlockType.text,
        title: 'NULL is not zero',
        body:
            "NULL means 'we don't know'. Comparing anything to NULL produces NULL — not true and not false. Two short SQL examples below.",
      ),
      const CourseBlock(
        id: 'gb2',
        type: CourseBlockType.code,
        title: 'Comparing with NULL',
        body:
            'SELECT 1 = NULL;       -- → NULL\nSELECT 1 IS NULL;      -- → false\nSELECT NULL IS NULL;   -- → true',
        language: 'sql',
      ),
      const CourseBlock(
        id: 'gb3',
        type: CourseBlockType.quiz,
        title: 'Truth table check',
        body: '2 quick MCQs',
        itemCount: 2,
      ),
    ];
  }
}
