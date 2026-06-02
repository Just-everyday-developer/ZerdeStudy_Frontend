// Shared widget library for the new Teacher Studio look — Phase 2.
//
// Built to coexist with the older `teacher_workspace_widgets.dart` (we keep
// it around to avoid touching files that haven't been migrated yet) and
// match the HTML prototype's "refined dark cyber" design language:
//
//   - thin hairline borders, no heavy glow
//   - monospace eyebrows in tracked uppercase (ed-sm)
//   - tabular-numeric stat numbers
//   - sparklines + rings + tags with toned borders
//
// All widgets accept `Color` accents, resolve via `context.appColors`, and
// stay mobile-friendly: they don't enforce a width, just use `Expanded` /
// `Wrap` / `LayoutBuilder` around them as appropriate.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page scaffolding
// ─────────────────────────────────────────────────────────────────────────────

/// Outer scroll container with consistent padding for studio pages.
class TsPageScrollView extends StatelessWidget {
  const TsPageScrollView({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 700 ? 14.0 : 24.0;
    return ListView(
      padding:
          padding ?? EdgeInsets.fromLTRB(horizontal, 20, horizontal, 32),
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) SizedBox(height: width < 700 ? 12 : 16),
        ],
      ],
    );
  }
}

/// Header above each page: monospace eyebrow + big title + subtitle +
/// optional right-aligned action buttons.
class TsPageHeader extends StatelessWidget {
  const TsPageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actions = const <Widget>[],
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = MediaQuery.sizeOf(context).width < 700;

    Widget textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          TsEyebrow(eyebrow!),
          const SizedBox(height: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: compact ? 20 : 24,
                height: 1.15,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                  fontSize: compact ? 12.5 : 13.5,
                ),
          ),
        ],
      ],
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textBlock,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: textBlock),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 16),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tiny atoms — eyebrow / tag / delta / dot
// ─────────────────────────────────────────────────────────────────────────────

class TsEyebrow extends StatelessWidget {
  const TsEyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color ?? colors.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.14,
        fontFamily: 'monospace',
      ),
    );
  }
}

/// Pill chip — monospace label, toned background, accented border.
class TsTag extends StatelessWidget {
  const TsTag({super.key, required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

/// Delta indicator (▲ +9% / ▼ −4% / ±0).
class TsDelta extends StatelessWidget {
  const TsDelta({super.key, required this.value});
  final num value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (value == 0) {
      return Text(
        '±0',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 11.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
        ),
      );
    }
    final up = value > 0;
    return Text(
      (up ? '▲ ${value.abs()}%' : '▼ ${value.abs()}%'),
      style: TextStyle(
        color: up ? colors.success : colors.danger,
        fontSize: 11.5,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class TsDot extends StatelessWidget {
  const TsDot({super.key, required this.color, this.size = 6});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card primitives
// ─────────────────────────────────────────────────────────────────────────────

/// Refined card — hairline border, no big glow.
class TsCard extends StatelessWidget {
  const TsCard({
    super.key,
    required this.child,
    this.padding,
    this.accentBar,
  });
  final Widget child;
  final EdgeInsets? padding;

  /// If provided, draws a thin coloured strip across the top of the card.
  final Color? accentBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final width = MediaQuery.sizeOf(context).width;
    final pad = padding ??
        EdgeInsets.all(width < 700 ? 14 : 18);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider.withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (accentBar != null)
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentBar!,
                    accentBar!.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          Padding(padding: pad, child: child),
        ],
      ),
    );
  }
}

/// Header inside a TsCard: eyebrow (+dot) + title + subtitle + actions row.
class TsCardHeader extends StatelessWidget {
  const TsCardHeader({
    super.key,
    this.eyebrow,
    this.eyebrowDot,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
  });

  final String? eyebrow;
  final Color? eyebrowDot;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null)
                  Row(
                    children: [
                      if (eyebrowDot != null) ...[
                        TsDot(color: eyebrowDot!),
                        const SizedBox(width: 8),
                      ],
                      Flexible(child: TsEyebrow(eyebrow!)),
                    ],
                  ),
                if (eyebrow != null) const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          height: 1.45,
                          fontSize: 12.5,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 8),
            Wrap(spacing: 6, runSpacing: 6, children: actions),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI card (sparkline + big stat + delta)
// ─────────────────────────────────────────────────────────────────────────────

class TsKpiCard extends StatelessWidget {
  const TsKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.delta,
    this.subtitle,
    this.spark,
    this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final num? delta;
  final String? subtitle;
  final List<double>? spark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TsCard(
      accentBar: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TsDot(color: accent),
              const SizedBox(width: 8),
              Expanded(child: TsEyebrow(label)),
              if (delta != null) TsDelta(value: delta!),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              if (spark != null && spark!.isNotEmpty)
                SizedBox(
                  width: 64,
                  height: 22,
                  child: TsSparkline(values: spark!, color: accent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkline + ring (CustomPainter)
// ─────────────────────────────────────────────────────────────────────────────

class TsSparkline extends StatelessWidget {
  const TsSparkline({super.key, required this.values, required this.color});
  final List<double> values;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SparklinePainter(values: values, color: color));
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);
    final path = Path();
    final fill = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minV) / span) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fill, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}

class TsRing extends StatelessWidget {
  const TsRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 64,
    this.stroke = 6,
    this.center,
  });
  final double value;
  final Color color;
  final double size;
  final double stroke;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              value: value.clamp(0, 1),
              color: color,
              track: colors.divider,
              stroke: stroke,
            ),
          ),
          if (center != null) center!,
          if (center == null)
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.27,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.stroke,
  });
  final double value;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - stroke) / 2;
    final base = Paint()
      ..color = track
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(c, r, base);
    if (value <= 0) return;
    final fg = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Status row (tag + title + meta + right action)
// ─────────────────────────────────────────────────────────────────────────────

class TsStatusLine extends StatelessWidget {
  const TsStatusLine({
    super.key,
    required this.tag,
    required this.tagColor,
    required this.title,
    this.meta,
    this.trailing,
    this.onTap,
  });

  final String tag;
  final Color tagColor;
  final String title;
  final String? meta;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = MediaQuery.sizeOf(context).width < 600;

    final left = Row(
      children: [
        TsTag(label: tag, color: tagColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              if (meta != null) ...[
                const SizedBox(height: 4),
                Text(
                  meta!,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final body = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              if (trailing != null) ...[
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: trailing!),
              ],
            ],
          )
        : Row(
            children: [
              Expanded(child: left),
              if (trailing != null) ...[
                const SizedBox(width: 14),
                trailing!,
              ],
            ],
          );

    return Material(
      color: colors.surfaceSoft.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.divider.withValues(alpha: 0.55)),
          ),
          child: body,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Buttons (compact, monospace-feel)
// ─────────────────────────────────────────────────────────────────────────────

class TsButton extends StatelessWidget {
  const TsButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.primary = false,
  });

  factory TsButton.primary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
  }) =>
      TsButton(
        key: key,
        label: label,
        icon: icon,
        onPressed: onPressed,
        primary: true,
      );

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (primary) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: const Color(0xFF062623),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 14),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.divider),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 14),
      label: Text(label),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Responsive helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Lays out children in N columns based on viewport width.
/// Mobile (< 700) → 1 col. Tablet (< 1100) → 2. Wide → `desktopCols`.
class TsResponsiveGrid extends StatelessWidget {
  const TsResponsiveGrid({
    super.key,
    required this.children,
    this.desktopCols = 4,
    this.gap = 12,
  });

  final List<Widget> children;
  final int desktopCols;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        int cols;
        if (w < 700) {
          cols = 1;
        } else if (w < 1100) {
          cols = math.min(2, desktopCols);
        } else {
          cols = desktopCols;
        }
        final itemWidth = (w - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Two-column split that collapses to a single column under [breakpoint].
class TsResponsiveSplit extends StatelessWidget {
  const TsResponsiveSplit({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.gap = 16,
    this.breakpoint = 900,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;
  final double gap;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              SizedBox(height: gap),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: leftFlex, child: left),
            SizedBox(width: gap),
            Expanded(flex: rightFlex, child: right),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mastery / quality color helper
// ─────────────────────────────────────────────────────────────────────────────

Color tsQualityColor(double v, AppThemeColors c) {
  if (v >= 0.85) return c.success;
  if (v >= 0.70) return c.primary;
  if (v >= 0.55) return const Color(0xFFFBBF24);
  if (v >= 0.40) return c.accent;
  return c.danger;
}

// ─────────────────────────────────────────────────────────────────────────────
// Callout card (toned background, accent border)
// ─────────────────────────────────────────────────────────────────────────────

class TsCallout extends StatelessWidget {
  const TsCallout({
    super.key,
    required this.color,
    required this.title,
    required this.body,
    this.dashed = false,
    this.icon,
    this.actions = const <Widget>[],
  });
  final Color color;
  final String title;
  final String body;
  final bool dashed;
  final IconData? icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          style: dashed ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 8),
              ],
              TsEyebrow(title, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12.5,
              height: 1.55,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}
