import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';
import '../theme/app_theme_colors.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.bottomNavigationBar,
    this.maxContentWidth,
    this.horizontalPadding,
    this.expandContent = false,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final Widget? bottomNavigationBar;
  final double? maxContentWidth;
  final double? horizontalPadding;
  final bool expandContent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final navigator = Navigator.maybeOf(context);
    final canPop = navigator?.canPop() ?? false;
    final hasActions = actions != null && actions!.isNotEmpty;
    final showBackOnlyBar = !context.isCompactLayout && canPop;
    final showAppBar = title != null || hasActions || showBackOnlyBar;

    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: bottomNavigationBar,
      appBar: !showAppBar
          ? null
          : AppBar(
              leading: canPop
                  ? IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                    )
                  : null,
              title: title == null
                  ? null
                  : Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              actions: actions,
            ),
      body: Stack(
        children: [
          const Positioned.fill(child: _Backdrop()),
          SafeArea(
            top: safeAreaTop,
            bottom: safeAreaBottom,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    this.horizontalPadding ?? context.appPageHorizontalPadding;
                final availableWidth =
                    constraints.maxWidth - (horizontalPadding * 2);
                final contentWidth = maxContentWidth ?? context.appPageMaxWidth;
                final clampedWidth = availableWidth <= 0
                    ? constraints.maxWidth
                    : availableWidth;

                final content = Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: expandContent
                      ? child
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: clampedWidth < contentWidth
                                ? clampedWidth
                                : contentWidth,
                          ),
                          child: child,
                        ),
                );

                return Align(
                  alignment:
                      expandContent ||
                          context.isCompactLayout ||
                          context.isNativeWindowsApp
                      ? Alignment.topLeft
                      : Alignment.topCenter,
                  child: content,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.pageGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -50,
            child: _GlowOrb(
              color: colors.primary.withValues(alpha: 0.18),
              size: 220,
            ),
          ),
          Positioned(
            top: 180,
            right: -60,
            child: _GlowOrb(
              color: colors.accent.withValues(alpha: 0.16),
              size: 180,
            ),
          ),
          Positioned(
            bottom: -30,
            left: 50,
            child: _GlowOrb(
              color: colors.success.withValues(alpha: 0.12),
              size: 160,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
