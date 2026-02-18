import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SkillNode extends StatelessWidget {
  final double x;
  final double y;
  final IconData icon;
  final Color color;

  const SkillNode({
    super.key,
    required this.x,
    required this.y,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - 25,
      top: y - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}