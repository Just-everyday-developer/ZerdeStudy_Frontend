import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Рисуем линии между центрами нод (координаты можно потом вынести в модель)
    canvas.drawLine(const Offset(150, 50), const Offset(80, 150), paint);
    canvas.drawLine(const Offset(150, 50), const Offset(220, 150), paint);
    canvas.drawLine(const Offset(80, 150), const Offset(150, 250), paint);
    canvas.drawLine(const Offset(220, 150), const Offset(150, 250), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}