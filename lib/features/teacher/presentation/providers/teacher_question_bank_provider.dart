import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final teacherQuestionBankProvider =
    NotifierProvider<TeacherQuestionBankController, List<TeacherQuestionDraft>>(
      TeacherQuestionBankController.new,
    );

class TeacherQuestionBankController
    extends Notifier<List<TeacherQuestionDraft>> {
  @override
  List<TeacherQuestionDraft> build() {
    return const <TeacherQuestionDraft>[
      TeacherQuestionDraft(
        id: 'sql_joins_1',
        module: 'SQL Fundamentals',
        difficulty: 'Intermediate',
        type: 'single_choice',
        prompt: 'Which JOIN keeps every row from the left table?',
        options: <String>[
          'INNER JOIN',
          'LEFT JOIN',
          'RIGHT JOIN',
          'CROSS JOIN',
        ],
        correctAnswer: 'LEFT JOIN',
        explanation:
            'LEFT JOIN keeps all rows from the left table and matches what it can on the right.',
        tags: <String>['sql', 'joins'],
      ),
      TeacherQuestionDraft(
        id: 'frontend_a11y_1',
        module: 'Frontend Accessibility',
        difficulty: 'Beginner',
        type: 'single_choice',
        prompt:
            'Which attribute improves screen reader context for an icon button?',
        options: <String>[
          'role="button"',
          'aria-label',
          'tabindex="-1"',
          'data-testid',
        ],
        correctAnswer: 'aria-label',
        explanation:
            'aria-label provides accessible text when the button does not have a visible label.',
        tags: <String>['frontend', 'a11y'],
      ),
      TeacherQuestionDraft(
        id: 'api_security_1',
        module: 'API Security Clinic',
        difficulty: 'Advanced',
        type: 'case_prompt',
        prompt:
            'Name one reason rate limiting should be applied at the API gateway.',
        options: <String>[
          'It changes database schema',
          'It reduces abuse and protects upstream services',
          'It replaces authentication entirely',
          'It guarantees zero downtime',
        ],
        correctAnswer: 'It reduces abuse and protects upstream services',
        explanation:
            'Rate limiting helps absorb abuse before requests overload application or data services.',
        tags: <String>['security', 'api', 'gateway'],
      ),
    ];
  }

  String exportJson() {
    return const JsonEncoder.withIndent('  ').convert(
      state.map((question) => question.toJson()).toList(growable: false),
    );
  }

  String exportCsv() {
    final buffer = StringBuffer()
      ..writeln(
        'id,module,difficulty,type,prompt,option_a,option_b,option_c,option_d,correct_answer,explanation,tags',
      );

    for (final question in state) {
      final paddedOptions = <String>[
        ...question.options.take(4),
        ...List<String>.filled(4 - question.options.take(4).length, ''),
      ];
      final cells = <String>[
        question.id,
        question.module,
        question.difficulty,
        question.type,
        question.prompt,
        paddedOptions[0],
        paddedOptions[1],
        paddedOptions[2],
        paddedOptions[3],
        question.correctAnswer,
        question.explanation,
        question.tags.join('|'),
      ];
      buffer.writeln(cells.map(_escapeCsv).join(','));
    }

    return buffer.toString().trimRight();
  }

  void importJson(String raw) {
    final decoded = jsonDecode(raw) as Object?;
    final records = switch (decoded) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map when map['questions'] is List<dynamic> =>
        map['questions'] as List<dynamic>,
      _ => throw const FormatException(
        'JSON payload must be a list or {"questions": [...]}',
      ),
    };

    final parsed = records
        .map(
          (record) =>
              TeacherQuestionDraft.fromJson(record as Map<String, dynamic>),
        )
        .toList(growable: false);
    if (parsed.isEmpty) {
      throw const FormatException('Question list is empty.');
    }

    state = parsed;
  }

  void importCsv(String raw) {
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trimRight())
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);

    if (lines.length < 2) {
      throw const FormatException(
        'CSV must include a header and at least one row.',
      );
    }

    final header = _parseCsvLine(lines.first);
    final headerIndex = <String, int>{
      for (var i = 0; i < header.length; i++) header[i].trim().toLowerCase(): i,
    };
    final requiredColumns = <String>[
      'id',
      'module',
      'difficulty',
      'type',
      'prompt',
      'correct_answer',
    ];
    for (final column in requiredColumns) {
      if (!headerIndex.containsKey(column)) {
        throw FormatException('Missing required CSV column: $column');
      }
    }

    final parsed = lines
        .skip(1)
        .map((line) {
          final columns = _parseCsvLine(line);
          String valueOf(String name) {
            final index = headerIndex[name];
            if (index == null || index >= columns.length) {
              return '';
            }
            return columns[index].trim();
          }

          final options = <String>[
            valueOf('option_a'),
            valueOf('option_b'),
            valueOf('option_c'),
            valueOf('option_d'),
          ].where((value) => value.isNotEmpty).toList(growable: false);

          return TeacherQuestionDraft(
            id: valueOf('id'),
            module: valueOf('module'),
            difficulty: valueOf('difficulty'),
            type: valueOf('type'),
            prompt: valueOf('prompt'),
            options: options,
            correctAnswer: valueOf('correct_answer'),
            explanation: valueOf('explanation'),
            tags: valueOf('tags')
                .split('|')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(growable: false),
          );
        })
        .toList(growable: false);

    if (parsed.isEmpty) {
      throw const FormatException('CSV import produced no questions.');
    }

    state = parsed;
  }
}

class TeacherQuestionDraft {
  const TeacherQuestionDraft({
    required this.id,
    required this.module,
    required this.difficulty,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.tags,
  });

  final String id;
  final String module;
  final String difficulty;
  final String type;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'module': module,
      'difficulty': difficulty,
      'type': type,
      'prompt': prompt,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'tags': tags,
    };
  }

  factory TeacherQuestionDraft.fromJson(Map<String, dynamic> json) {
    return TeacherQuestionDraft(
      id: json['id'] as String? ?? '',
      module: json['module'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      type: json['type'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => '$item')
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false),
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => '$item')
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false),
    );
  }
}

String _escapeCsv(String value) {
  final escaped = value.replaceAll('"', '""');
  if (escaped.contains(',') ||
      escaped.contains('"') ||
      escaped.contains('\n')) {
    return '"$escaped"';
  }
  return escaped;
}

List<String> _parseCsvLine(String line) {
  final result = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;

  // A tiny CSV reader is enough here because the teacher import flow is meant
  // for lightweight question bank exchange without a backend dependency.
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      final isEscapedQuote =
          inQuotes && i + 1 < line.length && line[i + 1] == '"';
      if (isEscapedQuote) {
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }
    if (char == ',' && !inQuotes) {
      result.add(buffer.toString());
      buffer.clear();
      continue;
    }
    buffer.write(char);
  }
  result.add(buffer.toString());

  return result;
}
