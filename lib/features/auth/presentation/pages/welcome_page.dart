import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';
import 'package:frontend_flutter/features/auth/presentation/widgets/AnimatedWelcomeText.dart';
import '../widgets/WelcomeBackdropPainter.dart';
import '../widgets/WelcomePageBottom.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Screen size: ${context.w} x ${context.h}");
    debugPrint("Scale factor: ${context.u}");

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Фон с волнами/кружками
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1E5AA8), // верх
                      Color(0xFF2C76C5), // низ
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: WelcomeBackdropPainter(),

                /// Рисует декоративные круги
              ),
            ),
            Positioned(
              left: context.u * 0.05,
              right: context.u * 0.05,
              top: context.h * 0.18,
              child: Center(
                child: AnimatedWelcomeText(text: "Welcome to \nZerdeStudy"),
              ),
            ),
            WelcomePageBottom(),
          ],
        ),
      ),
    );
  }
}
