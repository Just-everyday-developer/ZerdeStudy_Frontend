import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

class InlineMarkdownText extends StatelessWidget {
  const InlineMarkdownText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final baseStyle = DefaultTextStyle.of(context).style.merge(style);

    return SelectableText.rich(
      TextSpan(
        style: baseStyle,
        children: _buildInlineMarkdownSpans(
          text: text,
          baseStyle: baseStyle,
          colors: colors,
        ),
      ),
    );
  }
}

List<InlineSpan> _buildInlineMarkdownSpans({
  required String text,
  required TextStyle baseStyle,
  required AppThemeColors colors,
}) {
  final spans = <InlineSpan>[];
  final buffer = StringBuffer();
  var index = 0;

  void flushPlain() {
    if (buffer.isEmpty) {
      return;
    }
    spans.add(TextSpan(text: buffer.toString()));
    buffer.clear();
  }

  while (index < text.length) {
    if (_startsWith(text, index, '**')) {
      final end = text.indexOf('**', index + 2);
      if (end != -1) {
        flushPlain();
        spans.add(
          TextSpan(
            text: text.substring(index + 2, end),
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
        index = end + 2;
        continue;
      }
    }

    if (text[index] == '`') {
      final end = text.indexOf('`', index + 1);
      if (end != -1) {
        flushPlain();
        spans.add(
          TextSpan(
            text: text.substring(index + 1, end),
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              backgroundColor: colors.surfaceSoft,
              color: colors.primary,
            ),
          ),
        );
        index = end + 1;
        continue;
      }
    }

    buffer.write(text[index]);
    index++;
  }

  flushPlain();
  return spans;
}

bool _startsWith(String source, int index, String marker) {
  if (index + marker.length > source.length) {
    return false;
  }
  return source.substring(index, index + marker.length) == marker;
}
