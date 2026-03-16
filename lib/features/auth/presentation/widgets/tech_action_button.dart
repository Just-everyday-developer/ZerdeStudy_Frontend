import 'package:flutter/material.dart';

import '../../../../core/common_widgets/app_button.dart';

class TechActionButton extends StatelessWidget {
  const TechActionButton({
    super.key,
    required this.title,
    required this.isPrimary,
    required this.onTap,
    this.icon,
  });

  final String title;
  final bool isPrimary;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return isPrimary
        ? AppButton.primary(
            label: title,
            onPressed: onTap,
            icon: icon,
          )
        : AppButton.secondary(
            label: title,
            onPressed: onTap,
            icon: icon,
          );
  }
}
