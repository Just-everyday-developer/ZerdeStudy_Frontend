import 'package:flutter/material.dart';

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
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colors.divider.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            topBar,
                            const SizedBox(height: 24),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
