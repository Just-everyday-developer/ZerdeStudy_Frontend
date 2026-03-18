import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'background_assets.dart';
import 'tech_particle.dart';

class InfiniteTechPainter extends CustomPainter {
  InfiniteTechPainter({
    required this.animationValue,
    required this.primary,
    required this.accent,
  });

  final double animationValue;
  final Color primary;
  final Color accent;

  static final List<TechParticle> _particles = List<TechParticle>.generate(
    54,
    (index) => TechParticle(
      id: index,
      yOffset: index / 54,
      speed: 0.24 + (index % 5) * 0.03,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      final progress = (animationValue * particle.speed + particle.yOffset) % 1;
      final random = math.Random(particle.id);
      final isIcon = random.nextBool();
      final particleAccent = random.nextBool() ? primary : accent;
      final depth = 0.35 + random.nextDouble() * 0.75;
      final x = (random.nextDouble() * size.width).clamp(24, size.width - 24);
      final y = progress * (size.height + 120) - 60;
      final opacity = (0.08 + depth * 0.18).clamp(0.08, 0.28);

      final symbol = isIcon
          ? String.fromCharCode(
              BackgroundAssets.icons[random.nextInt(BackgroundAssets.icons.length)]
                  .codePoint,
            )
          : BackgroundAssets.symbols[random.nextInt(BackgroundAssets.symbols.length)];
      final fontFamily = isIcon
          ? BackgroundAssets.icons[random.nextInt(BackgroundAssets.icons.length)]
              .fontFamily
          : 'monospace';

      final painter = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            color: particleAccent.withValues(alpha: opacity.toDouble()),
            fontSize: 12 + depth * 12,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(canvas, Offset(x.toDouble(), y));
    }
  }

  @override
  bool shouldRepaint(covariant InfiniteTechPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
