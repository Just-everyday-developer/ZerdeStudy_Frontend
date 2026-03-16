import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.safeAreaTop = true,
    this.bottomNavigationBar,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool safeAreaTop;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: safeAreaTop,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: bottomNavigationBar,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              actions: actions,
            ),
      body: Stack(
        children: [
          const Positioned.fill(child: _Backdrop()),
          content,
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0F1D),
            Color(0xFF08111F),
            Color(0xFF050A14),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -50,
            child: _GlowOrb(
              color: AppColors.primary.withValues(alpha: 0.18),
              size: 220,
            ),
          ),
          Positioned(
            top: 180,
            right: -60,
            child: _GlowOrb(
              color: AppColors.accent.withValues(alpha: 0.16),
              size: 180,
            ),
          ),
          Positioned(
            bottom: -30,
            left: 50,
            child: _GlowOrb(
              color: AppColors.success.withValues(alpha: 0.12),
              size: 160,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

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
