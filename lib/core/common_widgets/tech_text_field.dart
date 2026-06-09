import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

class TechTextField extends StatelessWidget {
  const TechTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isObscure = false,
    this.readOnly = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isObscure;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextField(
      controller: controller,
      obscureText: isObscure,
      readOnly: readOnly,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: colors.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }
}
