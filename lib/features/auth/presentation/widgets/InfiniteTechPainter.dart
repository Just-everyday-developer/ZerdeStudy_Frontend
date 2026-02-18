import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'TechParticle.dart';

class TechBackgroundPainter extends CustomPainter {
  final double animationValue; // От 0.0 до 1.0
  final Offset pointerOffset;

  // Статический кэш частиц, чтобы создавать их только один раз
  static List<TechParticle>? _cachedParticles;
  static Size? _lastSize;

  // Настройки палитры
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF00FF66);

  TechBackgroundPainter({
    required this.animationValue,
    this.pointerOffset = Offset.zero,
  });

  void _initParticles(Size size) {
    if (_cachedParticles != null && _lastSize == size) return;

    final math.Random rnd = math.Random(42); // Фиксированный сид
    final List<TechParticle> particles = [];

    // Пул символов и иконок
    final List<String> symbols = ["< />", "{ }", "()", "#", "λ", "db", "api", "UI", "Go", "Dart", "SQL"];
    final List<IconData> icons = [
      Icons.code, Icons.terminal, Icons.storage,
      Icons.security, Icons.memory, Icons.functions
    ];

    const int particleCount = 40; // 25-45 частиц

    for (int i = 0; i < particleCount; i++) {
      double depth = 0.2 + rnd.nextDouble() * 0.8; // 0.2 .. 1.0

      // Генерация позиции с учетом "Quiet Zone" (Тихой зоны) в центре
      double x = rnd.nextDouble() * size.width;
      double y = rnd.nextDouble() * size.height;

      // Проверка на попадание в центр (x: 20%-80%, y: 30%-70%)
      bool inQuietZone = x > size.width * 0.2 && x < size.width * 0.8 &&
          y > size.height * 0.3 && y < size.height * 0.7;

      if (inQuietZone) {
        // Выталкиваем частицу ближе к краям или оставляем, но с очень низкой глубиной (чтобы была тусклой)
        if (rnd.nextBool()) {
          x = rnd.nextBool() ? (rnd.nextDouble() * size.width * 0.2) : (size.width * 0.8 + rnd.nextDouble() * size.width * 0.2);
        } else {
          depth = 0.2 + rnd.nextDouble() * 0.15; // Делаем ее еле заметной
        }
      }

      // Выбираем тип контента (символ или иконка)
      bool isIcon = rnd.nextBool();
      String text;
      String? fontFamily;

      if (isIcon) {
        IconData icon = icons[rnd.nextInt(icons.length)];
        text = String.fromCharCode(icon.codePoint);
        fontFamily = icon.fontFamily; // Подтягиваем шрифт MaterialIcons
      } else {
        text = symbols[rnd.nextInt(symbols.length)];
      }

      // 10% шанс на зеленый акцент
      Color color = rnd.nextDouble() > 0.9 ? accentGreen : primaryCyan;

      particles.add(TechParticle(
        text: text,
        fontFamily: fontFamily,
        depth: depth,
        color: color,
        baseX: x,
        baseY: y,
        phaseX: rnd.nextDouble() * 2 * math.pi,
        phaseY: rnd.nextDouble() * 2 * math.pi,
        amplitude: 10.0 + rnd.nextDouble() * 20.0,
        // Скорость дрейфа. Целое число кругов для бесшовного loop (0..1)
        speed: 1.0 + rnd.nextInt(3).toDouble(),
        verticalSpeed: 50.0 + rnd.nextDouble() * 100.0, // Пикселей за цикл
        blinkPhase: rnd.nextDouble() * 2 * math.pi,
        rotationPhase: rnd.nextDouble() * 2 * math.pi,
      ));
    }

    _cachedParticles = particles;
    _lastSize = size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _initParticles(size);

    // animationValue идет от 0.0 до 1.0. Превращаем в радианы для sin/cos
    final double time = animationValue * 2 * math.pi;

    for (var particle in _cachedParticles!) {
      // 1. Вычисление физики и позиций

      // Непрерывный дрейф sin/cos
      double dx = math.sin(time * particle.speed + particle.phaseX) * (particle.amplitude * particle.depth);

      // Вертикальный flow: медленно плывут вниз (или вверх) с зацикливанием
      double flowY = (animationValue * particle.verticalSpeed * particle.depth);
      double currentY = (particle.baseY + flowY) % size.height; // Бесшовный Wrap
      double currentX = particle.baseX + dx;

      // Параллакс от указателя (максимум 8-14 dp)
      double parallaxX = pointerOffset.dx * (particle.depth - 0.2) * 0.08;
      double parallaxY = pointerOffset.dy * (particle.depth - 0.2) * 0.08;

      // Ограничение параллакса
      parallaxX = parallaxX.clamp(-14.0, 14.0);
      parallaxY = parallaxY.clamp(-14.0, 14.0);

      // Итоговая позиция
      Offset finalPos = Offset(currentX + parallaxX, currentY + parallaxY);

      // 2. Внешний вид (Оптическая иллюзия глубины)

      // Дальние - маленькие и тусклые. Ближние - крупные и яркие.
      double baseOpacity = 0.04 + (particle.depth * 0.14); // 0.04 .. 0.18
      double fontSize = 12.0 + (particle.depth * 24.0); // 16 .. 36

      // Плавный Blink (редкие вспышки)
      // sin() дает от -1 до 1. Сдвигаем и масштабируем, чтобы блик был редким.
      double blinkVal = math.sin(time * 2.0 + particle.blinkPhase);
      if (blinkVal > 0.8) {
        baseOpacity += (blinkVal - 0.8) * 0.25; // Прибавка макс +0.05
      }

      // Небольшое вращение (1-3% визуально)
      double rotation = math.sin(time + particle.rotationPhase) * 0.05 * particle.depth;

      // 3. Отрисовка

      // Сохраняем стейт холста для вращения конкретной частицы
      canvas.save();
      canvas.translate(finalPos.dx, finalPos.dy);
      canvas.rotate(rotation);

      // Настройка кисти для текста
      final TextStyle textStyle = TextStyle(
        color: particle.color.withOpacity(baseOpacity),
        fontSize: fontSize,
        fontFamily: particle.fontFamily ?? 'monospace', // Кодовый шрифт для текста, MaterialIcons для иконок
        fontWeight: FontWeight.w600,
      );

      final TextSpan span = TextSpan(text: particle.text, style: textStyle);
      final TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      // Центрируем отрисовку относительно координаты
      Offset drawOffset = Offset(-tp.width / 2, -tp.height / 2);

      // Рисуем слой Glow (Имитация Blur через масштабирование и низкую прозрачность)
      // Это работает в разы быстрее, чем MaskFilter
      if (particle.depth > 0.5) { // Свечение рисуем только для средних и ближних
        canvas.save();
        canvas.scale(1.2); // Увеличиваем на 20%
        final TextPainter glowTp = TextPainter(
          text: TextSpan(
            text: particle.text,
            style: textStyle.copyWith(color: particle.color.withOpacity(baseOpacity * 0.3)),
          ),
          textDirection: TextDirection.ltr,
        );
        glowTp.layout();
        glowTp.paint(canvas, Offset(-glowTp.width / 2, -glowTp.height / 2));
        canvas.restore();
      }

      // Рисуем Core (Ядро)
      tp.paint(canvas, drawOffset);

      canvas.restore(); // Возвращаем холст в нормальное состояние для следующей частицы
    }
  }

  @override
  bool shouldRepaint(covariant TechBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pointerOffset != pointerOffset;
  }
}