import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TreePainter extends CustomPainter {
  const TreePainter({
    required this.connections,
  });

  final List<List<Offset>> connections;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.24)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final edge in connections) {
      if (edge.length != 2) {
        continue;
      }
      final start = edge.first;
      final end = edge.last;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx,
          (start.dy + end.dy) / 2,
          end.dx,
          (start.dy + end.dy) / 2,
          end.dx,
          end.dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.connections != connections;
  }
}
