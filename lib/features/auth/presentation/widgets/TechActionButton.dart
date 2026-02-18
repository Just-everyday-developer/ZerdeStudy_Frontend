import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TechActionButton extends StatelessWidget {
  const TechActionButton({
    super.key,
    required this.title,
    required this.isPrimary,
    required this.onTap,
  });

  final String title;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isPrimary ? AppColors.primary : AppColors.textSecondary;
    final textColor = isPrimary ? AppColors.primary : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
