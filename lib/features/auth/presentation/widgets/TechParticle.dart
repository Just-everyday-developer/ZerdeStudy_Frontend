import 'dart:math' as math;
import 'package:flutter/material.dart';

class TechParticle {
  final double yOffset; // Начальная задержка, чтобы частицы не шли одной волной
  final double speed;   // Индивидуальная скорость
  final int id;         // Уникальный ID для генерации уникального контента на каждом круге

  TechParticle({
    required this.id,
    required this.yOffset,
    required this.speed,
  });
}

class InfiniteTechPainter extends CustomPainter {
  final double animationValue; // 0.0 -> 1.0
  final Offset pointerOffset;

  static List<TechParticle>? _particles;

  // Полный пул символов и иконок
  final List<String> _symbols = ["< />", "{ }", "()", "#", "λ", "db", "api", "UI", "Go", "Dart", "SQL", "JSON", "Git", "CSS", "++", "=>"];
  final List<IconData> _icons = [Icons.code, Icons.terminal, Icons.storage, Icons.memory, Icons.settings_ethernet, Icons.shield_outlined];

  InfiniteTechPainter({required this.animationValue, this.pointerOffset = Offset.zero});

  void _initParticles() {
    if (_particles != null) return;
    // Создаем 50 частиц. Это обеспечит высокую плотность без пустых мест.
    _particles = List.generate(50, (i) => TechParticle(
      id: i,
      yOffset: i / 50, // Равномерно распределяем начальные позиции по вертикали
      speed: 0.4 + (i % 5) * 0.1, // Разные скорости для эффекта глубины
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    _initParticles();

    for (var p in _particles!) {
      // 1. Вычисляем общий прогресс движения
      // animationValue * speed + yOffset может быть больше 1.0
      double totalProgress = animationValue + p.yOffset;

      // Номер текущего "круга" (lap). Используем его как сид для рандома!
      int lap = totalProgress.floor();

      // Относительный прогресс внутри одного экрана (0.0 -> 1.0)
      double relativeY = totalProgress % 1.0;

      // 2. Генерация "личности" частицы для конкретного круга
      // Используем Random с сидом (p.id + lap), чтобы на каждом новом круге
      // у этой частицы был НОВЫЙ символ и НОВАЯ координата X.
      final lapRnd = math.Random(p.id + lap);

      double xPercent = lapRnd.nextDouble(); // Случайное X для этого круга
      double depth = 0.2 + lapRnd.nextDouble() * 0.8;

      // Выбираем контент (гарантируем появление всего пула со временем)
      bool isIcon = lapRnd.nextBool();
      String text;
      String? fontFamily;

      if (isIcon) {
        IconData icon = _icons[lapRnd.nextInt(_icons.length)];
        text = String.fromCharCode(icon.codePoint);
        fontFamily = icon.fontFamily;
      } else {
        text = _symbols[lapRnd.nextInt(_symbols.length)];
      }

      // 3. Координаты отрисовки
      // Выходим за границы (от -50 до height + 50), чтобы исчезновение было плавным
      double drawY = relativeY * (size.height + 100) - 50;
      double drawX = xPercent * size.width;

      // Эффект затишья в центре (Quiet Zone)
      double centerX = size.width / 2;
      double centerY = size.height / 2;
      double distToCenter = math.sqrt(math.pow(drawX - centerX, 2) + math.pow(drawY - centerY, 2));
      double quietZoneFactor = (distToCenter / (size.width / 1.5)).clamp(0.15, 1.0);

      // Параллакс
      drawX += pointerOffset.dx * (depth - 0.2) * 0.1;
      drawY += pointerOffset.dy * (depth - 0.2) * 0.1;

      // 4. Стилизация
      double opacity = (0.04 + (depth * 0.12)) * quietZoneFactor;
      double fontSize = 14 + (depth * 18);

      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: const Color(0xFF00E5FF).withOpacity(opacity),
            fontSize: fontSize,
            fontFamily: fontFamily ?? 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Отрисовка
      tp.paint(canvas, Offset(drawX - tp.width / 2, drawY - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(InfiniteTechPainter oldDelegate) => true;
}