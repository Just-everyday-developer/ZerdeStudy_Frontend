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
          child,
        ],
      ),
    );
  }
}
