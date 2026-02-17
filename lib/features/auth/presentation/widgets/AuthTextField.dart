import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final u = context.u;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * u,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 6 * u),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 15 * u,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12 * u, vertical: 14 * u),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF7F8FB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * u),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * u),
              borderSide: const BorderSide(color: Color(0xFF2C76C5), width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
