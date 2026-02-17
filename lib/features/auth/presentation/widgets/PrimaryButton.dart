import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final u = context.u;

    return SizedBox(
      height: 52 * u,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C76C5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * u),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16 * u,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
