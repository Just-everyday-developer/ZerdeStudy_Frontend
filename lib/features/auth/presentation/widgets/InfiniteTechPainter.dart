import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'BackgroundAssets.dart';
import 'TechParticle.dart';

class InfiniteTechPainter extends CustomPainter {
  final double animationValue;
  final Offset pointerOffset;

  static List<TechParticle>? _particles;

  // Константы для настройки "движка" фона
  static const double _viewThreshold = 100.0; // Запас для появления/исчезновения
  static const double _baseFontSize = 14.0;
  static const double _highlightChance = 0.85;

  InfiniteTechPainter({required this.animationValue, this.pointerOffset = Offset.zero});

  @override
  void paint(Canvas canvas, Size size) {
    _initParticles();

    for (var p in _particles!) {
      // 1. Физика и логика "кругов" (Laps)
      final double totalProgress = animationValue + p.yOffset;
      final int lap = totalProgress.floor();
      final double relativeY = totalProgress % 1.0;
      final math.Random lapRnd = math.Random(p.id + lap);

      // 2. Генерация свойств (Personality)
      final double xPercent = lapRnd.nextDouble();
      final double depth = 0.2 + lapRnd.nextDouble() * 0.8;
      final bool isHighlighted = lapRnd.nextDouble() > _highlightChance;

      // 3. Вызов специализированного метода отрисовки
      _drawSingleParticle(
        canvas: canvas,
        size: size,
        rnd: lapRnd,
        xPercent: xPercent,
        yPercent: relativeY,
        depth: depth,
        isHighlighted: isHighlighted,
      );
    }
  }

  void _drawSingleParticle({
    required Canvas canvas,
    required Size size,
    required math.Random rnd,
    required double xPercent,
    required double yPercent,
    required double depth,
    required bool isHighlighted,
  }) {
    // Выбор контента
    final bool isIcon = rnd.nextBool();
    final String text;
    String? fontFamily;

    if (isIcon) {
      final icon = BackgroundAssets.icons[rnd.nextInt(BackgroundAssets.icons.length)];
      text = String.fromCharCode(icon.codePoint);
      fontFamily = icon.fontFamily;
    } else {
      text = BackgroundAssets.symbols[rnd.nextInt(BackgroundAssets.symbols.length)];
    }

    // Стиль
    final Color baseColor = isHighlighted ? const Color(0xFF00FF66) : const Color(0xFF00E5FF);
    final double opacity = ((0.04 + (depth * 0.12)) * (isHighlighted ? 2.5 : 1.0)).clamp(0.0, 1.0);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: baseColor.withOpacity(opacity),
          fontSize: _baseFontSize + (depth * 18),
          fontFamily: fontFamily ?? 'monospace',
          fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.bold,
          shadows: isHighlighted ? [Shadow(color: baseColor.withOpacity(0.5), blurRadius: 8)] : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Позиционирование
    final double halfWidth = tp.width / 2;
    double drawX = (xPercent * size.width).clamp(halfWidth, size.width - halfWidth);
    double drawY = yPercent * (size.height + _viewThreshold) - (_viewThreshold / 2);

    // Параллакс
    drawX += pointerOffset.dx * (depth - 0.2) * 0.1;
    drawY += pointerOffset.dy * (depth - 0.2) * 0.1;

    // Quiet Zone (Затишье в центре)
    final double distToCenter = (Offset(drawX, drawY) - size.center(Offset.zero)).distance;
    final double quietZoneFactor = (distToCenter / (size.width / 1.5)).clamp(0.2, 1.0);

    // Финальный рендеринг
    canvas.save();
    canvas.translate(drawX - halfWidth, drawY - tp.height / 2);
    final paint = Paint()..color = Colors.white.withOpacity(quietZoneFactor);
    canvas.saveLayer(Rect.fromLTWH(0, 0, tp.width, tp.height), paint);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
    canvas.restore();
  }

  void _initParticles() {
    if (_particles != null) return;
    _particles = List.generate(50, (i) => TechParticle(
      id: i,
      yOffset: i / 50,
      speed: 0.3 + (i % 5) * 0.1,
    ));
  }

  @override
  bool shouldRepaint(InfiniteTechPainter oldDelegate) => true;
}