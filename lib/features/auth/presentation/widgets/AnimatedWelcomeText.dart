import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';

class AnimatedWelcomeText extends StatelessWidget {
  final String text;
  const AnimatedWelcomeText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TyperAnimatedText(
          text,
          textStyle: TextStyle(
            fontSize: 40 * context.u,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          speed: const Duration(milliseconds: 150),
        ),
      ],
    );
  }
}
