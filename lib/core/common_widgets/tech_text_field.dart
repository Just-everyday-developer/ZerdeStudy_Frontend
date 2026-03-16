import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class TechTextField extends StatelessWidget {
  const TechTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isObscure = false,
  });

  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isObscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }
}
