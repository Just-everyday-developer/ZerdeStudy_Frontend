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

