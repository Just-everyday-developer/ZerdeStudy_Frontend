import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/AnimatedWelcomeText.dart';
import '../widgets/AuthBackgroundWrapper.dart';
import '../widgets/TechActionButton.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundWrapper(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  const AnimatedWelcomeText(text: 'Welcome to ZerdeStudy'),
                  const SizedBox(height: 36),

                  TechActionButton(
                    title: 'Log In',
                    isPrimary: true,
                    onTap: () => context.go('/login'),
                  ),
                  const SizedBox(height: 16),
                  TechActionButton(
                    title: 'Sign Up',
                    isPrimary: false,
                    onTap: () => context.go('/signup'),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

