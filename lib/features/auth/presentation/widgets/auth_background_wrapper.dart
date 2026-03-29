import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../main.dart';
import 'infinite_tech_painter.dart';

class AuthBackgroundWrapper extends StatelessWidget {
  const AuthBackgroundWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors.authGradient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ListenableBuilder(
              listenable: backgroundController,
              builder: (context, _) {
                return CustomPaint(
                  painter: InfiniteTechPainter(
                    animationValue: backgroundController.value,
                    primary: colors.primary,
                    accent: colors.accent,
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: -40,
            top: 80,
            child: _GlowOrb(color: colors.primary.withValues(alpha: 0.22)),
          ),
          Positioned(
            right: -50,
            bottom: 140,
            child: _GlowOrb(color: colors.accent.withValues(alpha: 0.18)),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.08), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
