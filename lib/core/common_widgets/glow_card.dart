import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

class GlowCard extends StatelessWidget {
  const GlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final color = accent ?? palette.primary;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}
