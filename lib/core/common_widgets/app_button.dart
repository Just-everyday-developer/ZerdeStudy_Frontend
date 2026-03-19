import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.maxWidth,
  }) : isSecondary = false;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.maxWidth,
  }) : isSecondary = true;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final background = isSecondary
        ? colors.surfaceSoft.withValues(alpha: 0.88)
        : colors.primary;
    final foreground = isSecondary
        ? colors.textPrimary
        : Theme.of(context).colorScheme.onPrimary;
    final border = isSecondary ? colors.divider : colors.primary;

    final button = FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border.withValues(alpha: 0.9)),
        ),
        textStyle: GoogleFonts.ibmPlexSans(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 10),
            ],
            Text(label),
          ],
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: maxWidth == null
          ? button
          : Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: SizedBox(width: double.infinity, child: button),
              ),
            ),
    );
  }
}
