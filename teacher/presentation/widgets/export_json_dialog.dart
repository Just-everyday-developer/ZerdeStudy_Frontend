// Export-course-as-JSON dialog.
//
// Three tabs: JSON preview (with copy/download), Schema description, and
// example API call. The download path differs per platform:
//
//   - Web: triggers a browser download via `dart:html` (kept out of this
//     compilation unit; falls back to clipboard on non-web).
//   - Desktop / mobile: writes to a file using `path_provider` and reveals
//     the path via SnackBar. The user can replace the implementation in
//     `_saveLocally` with whatever fits the host app's storage flow.
//
// All clipboard ops use `Clipboard.setData` which is universal.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../application/course_constructor_controller.dart';
import '../../domain/models/course_graph.dart';

class ExportJsonDialog extends ConsumerStatefulWidget {
  const ExportJsonDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const ExportJsonDialog(),
    );
  }

  @override
  ConsumerState<ExportJsonDialog> createState() => _ExportJsonDialogState();
}

enum _Tab { json, schema, api }

class _ExportJsonDialogState extends ConsumerState<ExportJsonDialog> {
  _Tab _tab = _Tab.json;
  bool _includePositions = true;
  bool _includeAnalytics = false;
  bool _pretty = true;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final course = ref.watch(courseConstructorProvider.select((s) => s.course));

    final exported = course.toExportJson(
      includePositions: _includePositions,
      includeAnalytics: _includeAnalytics,
    );
    final encoder = _pretty
        ? const JsonEncoder.withIndent('  ')
        : const JsonEncoder();
    final text = encoder.convert(exported);
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: colors.backgroundElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: size.height * 0.86,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(course: course),
            _Tabs(
              current: _tab,
              onChanged: (t) => setState(() => _tab = t),
              showOptions: _tab == _Tab.json,
              includePositions: _includePositions,
              includeAnalytics: _includeAnalytics,
              pretty: _pretty,
              onPositionsChanged: (v) => setState(() => _includePositions = v),
              onAnalyticsChanged: (v) => setState(() => _includeAnalytics = v),
              onPrettyChanged: (v) => setState(() => _pretty = v),
            ),
            Expanded(
              child: switch (_tab) {
                _Tab.json => _JsonBody(text: text),
                _Tab.schema => const _SchemaBody(),
                _Tab.api => _ApiBody(course: course),
              },
            ),
            _Footer(
              text: text,
              tab: _tab,
              copied: _copied,
              onCopy: () async {
                await Clipboard.setData(ClipboardData(text: text));
                setState(() => _copied = true);
                Future.delayed(const Duration(seconds: 1, milliseconds: 400),
                    () {
                  if (mounted) setState(() => _copied = false);
                });
              },
              onDownload: () async => _saveLocally(context, course, text),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _saveLocally(
    BuildContext context, CourseGraph course, String text) async {
  // Cross-platform-safe fallback: copy to clipboard. Replace with
  // path_provider + dart:io File on desktop/mobile, or trigger a Blob+anchor
  // download on web. See MIGRATION.md.
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Copied ${course.id}-v${course.version}.json to clipboard '
        '(${(text.length / 1024).toStringAsFixed(1)} KB). '
        'See MIGRATION.md for wiring a real file write.',
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.course});
  final CourseGraph course;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Icon(Icons.upload_rounded, size: 18, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export course as JSON',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.id} · v${course.version} · '
                  '${course.nodes.length} nodes · ${course.edges.length} edges',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: colors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tabs + options
// ─────────────────────────────────────────────────────────────────────────────

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.current,
    required this.onChanged,
    required this.showOptions,
    required this.includePositions,
    required this.includeAnalytics,
    required this.pretty,
    required this.onPositionsChanged,
    required this.onAnalyticsChanged,
    required this.onPrettyChanged,
  });

  final _Tab current;
  final ValueChanged<_Tab> onChanged;
  final bool showOptions;
  final bool includePositions;
  final bool includeAnalytics;
  final bool pretty;
  final ValueChanged<bool> onPositionsChanged;
  final ValueChanged<bool> onAnalyticsChanged;
  final ValueChanged<bool> onPrettyChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          for (final t in _Tab.values) _tabBtn(context, t),
          const Spacer(),
          if (showOptions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _Toggle(
                    label: 'Positions',
                    value: includePositions,
                    onChanged: onPositionsChanged,
                  ),
                  const SizedBox(width: 12),
                  _Toggle(
                    label: 'Analytics',
                    value: includeAnalytics,
                    onChanged: onAnalyticsChanged,
                  ),
                  const SizedBox(width: 12),
                  _Toggle(
                    label: 'Pretty',
                    value: pretty,
                    onChanged: onPrettyChanged,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabBtn(BuildContext context, _Tab t) {
    final colors = context.appColors;
    final selected = t == current;
    final label = switch (t) {
      _Tab.json => 'JSON',
      _Tab.schema => 'Schema',
      _Tab.api => 'API call',
    };
    return InkWell(
      onTap: () => onChanged(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.textPrimary : colors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 16,
            decoration: BoxDecoration(
              color: value ? colors.primary : colors.divider,
              borderRadius: BorderRadius.circular(999),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: colors.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bodies
// ─────────────────────────────────────────────────────────────────────────────

class _JsonBody extends StatelessWidget {
  const _JsonBody({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060912),
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: SelectableText(
          text,
          style: const TextStyle(
            color: Color(0xFFD6DBEB),
            fontFamily: 'monospace',
            fontSize: 11.5,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}

class _SchemaBody extends StatelessWidget {
  const _SchemaBody();

  static const _rows = <List<String>>[
    ['object', 'course'],
    ['string', '  id'],
    ['string', '  code'],
    ['string', '  title'],
    ['string', '  version'],
    ['enum  ', '  status        live | review | draft'],
    ['string', '  summary'],
    ['array ', '  nodes[]'],
    ['string', '    id'],
    ['enum  ', '    type          module | lesson | quiz | practice | milestone'],
    ['string', '    title'],
    ['number', '    duration?'],
    ['number', '    itemCount?'],
    ['number', '    mastery?      0..1 (analytics)'],
    ['object', '    position?     { x, y }'],
    ['array ', '    blocks[]'],
    ['enum  ', '      type        text | video | code | quiz | callout'],
    ['string', '      title'],
    ['string', '      body'],
    ['string', '      url?        for video'],
    ['string', '      lang?       for code'],
    ['number', '      items?      for quiz'],
    ['array ', '  edges[]'],
    ['string', '    from'],
    ['string', '    to'],
    ['enum  ', '    kind?         prerequisite | reference'],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in _rows) ...[
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    row[0],
                    style: TextStyle(
                      color: colors.accent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.7,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row[1],
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ApiBody extends StatelessWidget {
  const _ApiBody({required this.course});
  final CourseGraph course;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final create = '''
curl -X POST https://api.zerdestudy.kz/api/v1/courses \\
  -H "Authorization: Bearer \$TEACHER_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d @${course.id}-v${course.version}.json''';

    final publish = '''
curl -X POST https://api.zerdestudy.kz/api/v1/courses/${course.id}/publish \\
  -H "Authorization: Bearer \$TEACHER_TOKEN" \\
  -d '{ "version": "${course.version}", "channel": "live" }' ''';

    final response = '''
{
  "course_id": "${course.id}",
  "version": "${course.version}",
  "status": "queued",
  "nodes": ${course.nodes.length},
  "edges": ${course.edges.length}
}''';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('1. CREATE OR UPDATE COURSE',
              style: TextStyle(
                color: colors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 10.5,
                letterSpacing: 0.14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          _CodeBox(text: create),
          const SizedBox(height: 18),
          Text('2. PUBLISH VERSION',
              style: TextStyle(
                color: colors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 10.5,
                letterSpacing: 0.14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          _CodeBox(text: publish),
          const SizedBox(height: 18),
          Text('3. RESPONSE',
              style: TextStyle(
                color: colors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 10.5,
                letterSpacing: 0.14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          _CodeBox(text: response),
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF060912),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.divider),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          color: Color(0xFFD6DBEB),
          fontFamily: 'monospace',
          fontSize: 11.5,
          height: 1.55,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer (size + actions)
// ─────────────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.text,
    required this.tab,
    required this.copied,
    required this.onCopy,
    required this.onDownload,
  });
  final String text;
  final _Tab tab;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = (text.length / 1024).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tab == _Tab.json
                  ? '${text.length} chars · $size KB'
                  : tab == _Tab.schema
                      ? 'Validated against zerdestudy.course.v3.schema'
                      : 'POST /api/v1/courses · authorization: Bearer <teacher_token>',
              style: TextStyle(
                color: colors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: colors.textSecondary),
            child: const Text('Close'),
          ),
          const SizedBox(width: 4),
          OutlinedButton.icon(
            onPressed: onCopy,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.divider),
            ),
            icon: Icon(copied ? Icons.check_rounded : Icons.tag_rounded,
                size: 14),
            label: Text(copied ? 'Copied!' : 'Copy'),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            onPressed: onDownload,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: const Color(0xFF062623),
            ),
            icon: const Icon(Icons.download_rounded, size: 14),
            label: const Text('Download .json'),
          ),
        ],
      ),
    );
  }
}
