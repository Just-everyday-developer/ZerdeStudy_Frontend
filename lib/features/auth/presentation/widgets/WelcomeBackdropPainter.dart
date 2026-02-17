import 'package:flutter/material.dart';

class WelcomeBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint1 = Paint()..color = Colors.white.withOpacity(0.4);
    final paint2 = Paint()..color = Colors.white.withOpacity(0.3);
    final paint3 = Paint()..color = Colors.white.withOpacity(0.2);
    final paint4 = Paint()..color = Colors.white.withOpacity(0.1);

    // Круг справа сверху
    canvas.drawCircle(Offset(w, h * 0.01), w * 0.4, paint4);

    // Круг слева сверху
    canvas.drawCircle(Offset(0, h * 0.01), w * 0.4, paint1);

    // Круг справа снизу
    canvas.drawCircle(Offset(w, h * 0.45), w * 0.4, paint3);

    // Круг слева снизу
    canvas.drawCircle(Offset(0, h * 0.45), w * 0.4, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
