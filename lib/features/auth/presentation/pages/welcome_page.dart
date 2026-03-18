import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../widgets/animated_welcome_text.dart';
import '../widgets/auth_background_wrapper.dart';
import '../widgets/tech_action_button.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final l10n = context.l10n;
    final colors = context.appColors;

    return AuthBackgroundWrapper(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: LocaleSelector(
                      currentLocale: state.locale,
                      onChanged: controller.changeLocale,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlowCard(
                    accent: colors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 14,
                        //     vertical: 8,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(999),
                        //     color: AppColors.primary.withValues(alpha: 0.14),
                        //   ),
                        //   child: Text(
                        //     l10n.text('presentation_ready'),
                        //     style: const TextStyle(
                        //       color: AppColors.primary,
                        //       fontWeight: FontWeight.w700,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 18),
                        AnimatedWelcomeText(
                          text: l10n.text('app_name'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.text('tagline'),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colors.textSecondary,
                                height: 1.45,
                              ),
                        ),
                        // const SizedBox(height: 22),
                        // const Wrap(
                        //   spacing: 12,
                        //   runSpacing: 12,
                        //   children: [
                        //     _SignalPill(label: '14 branches'),
                        //     _SignalPill(label: 'AI mentor'),
                        //     _SignalPill(label: 'RU / EN / KZ'),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // const GlowCard(
                  //   accent: AppColors.accent,
                  //   child: Wrap(
                  //     spacing: 12,
                  //     runSpacing: 12,
                  //     children: [
                  //       _FeatureCard(
                  //         title: 'Knowledge tree',
                  //         subtitle: 'CS Core plus IT spheres on one map',
                  //       ),
                  //       _FeatureCard(
                  //         title: 'Stateful demo',
                  //         subtitle: 'XP, streak, progress, quizzes, achievements',
                  //       ),
                  //       _FeatureCard(
                  //         title: 'Lesson flow',
                  //         subtitle: 'Theory, output quiz, memory lab, practice, AI help',
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TechActionButton(
                          title: l10n.text('login'),
                          isPrimary: false,
                          icon: Icons.mail_outline_rounded,
                          onTap: () => context.go(AppRoutes.login),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TechActionButton(
                          title: l10n.text('signup'),
                          isPrimary: false,
                          icon: Icons.person_add_alt_1_rounded,
                          onTap: () => context.go(AppRoutes.signup),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TechActionButton(
                          title: l10n.text('github'),
                          isPrimary: false,
                          icon: Icons.code_rounded,
                          onTap: () {
                            controller.loginWithProvider('github');
                            context.go(AppRoutes.home);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TechActionButton(
                          title: l10n.text('apple'),
                          isPrimary: false,
                          icon: Icons.apple_rounded,
                          onTap: () {
                            controller.loginWithProvider('apple');
                            context.go(AppRoutes.home);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _SignalPill extends StatelessWidget {
  const _SignalPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.surfaceSoft.withValues(alpha: 0.88),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ignore: unused_element
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
