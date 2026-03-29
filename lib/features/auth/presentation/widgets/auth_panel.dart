import 'package:flutter/material.dart';

import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'auth_background_wrapper.dart';

class AuthPanel extends StatelessWidget {
  const AuthPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.topBar,
    this.maxWidth = 620,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget topBar;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AuthBackgroundWrapper(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 980;
            final horizontalPadding = isDesktop ? 28.0 : 20.0;
            final panelMaxWidth = isDesktop
                ? constraints.maxWidth - (horizontalPadding * 2)
                : maxWidth;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                20,
              ),
              child: Align(
                // Desktop auth screens stay wide and left-aligned instead of
                // sitting in a narrow centered card.
                alignment: isDesktop ? Alignment.topLeft : Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelMaxWidth),
                  child: GlowCard(
                    accent: colors.primary,
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        topBar,
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: colors.textSecondary,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 28),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
