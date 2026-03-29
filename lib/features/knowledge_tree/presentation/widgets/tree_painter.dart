import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TreePainter extends CustomPainter {
  const TreePainter({
    required this.connections,
    this.trunkPaths = const <List<Offset>>[],
  });

  final List<List<Offset>> connections;
  final List<List<Offset>> trunkPaths;

  @override
  void paint(Canvas canvas, Size size) {
    final trunkGlow = Paint()
      ..color = const Color(0xFF8B6A4E).withValues(alpha: 0.18)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final trunkPaint = Paint()
      ..color = const Color(0xFF6D4A2D).withValues(alpha: 0.92)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final pathPoints in trunkPaths) {
      if (pathPoints.length < 2) {
        continue;
      }
      final path = _buildPath(pathPoints);
      canvas.drawPath(path, trunkGlow);
      canvas.drawPath(path, trunkPaint);
    }

    for (final edge in connections) {
      if (edge.length != 2) {
        continue;
      }
      final start = edge.first;
      final end = edge.last;
      final branchDepth = ((start.dy + end.dy) / 2 / size.height).clamp(
        0.0,
        1.0,
      );
      final width = lerpDouble(11, 4, branchDepth) ?? 6;
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.12)
        ..strokeWidth = width + 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      final branchPaint = Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            const Color(0xFF7E5738).withValues(alpha: 0.96),
            AppColors.primary.withValues(alpha: 0.62),
          ],
        ).createShader(Rect.fromPoints(start, end))
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx,
          start.dy - ((start.dy - end.dy).abs() * 0.28),
          end.dx,
          end.dy + ((start.dy - end.dy).abs() * 0.18),
          end.dx,
          end.dy,
        );

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, branchPaint);
    }
  }

  Path _buildPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }

    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final midPoint = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(
        previous.dx,
        previous.dy,
        midPoint.dx,
        midPoint.dy,
      );
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.connections != connections ||
        oldDelegate.trunkPaths != trunkPaths;
  }
}
