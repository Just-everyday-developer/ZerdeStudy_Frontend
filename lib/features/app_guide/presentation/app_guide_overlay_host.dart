import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme_colors.dart';
import 'app_guide_controller.dart';
import 'app_guide_copy.dart';
import 'app_guide_target.dart';

class AppGuideOverlayHost extends ConsumerStatefulWidget {
  const AppGuideOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppGuideOverlayHost> createState() =>
      _AppGuideOverlayHostState();
}

class _AppGuideOverlayHostState extends ConsumerState<AppGuideOverlayHost> {
  @override
  Widget build(BuildContext context) {
    final guideState = ref.watch(appGuideControllerProvider);
    final step = guideState.currentStep;

    return Stack(
      children: [
        widget.child,
        if (guideState.isActive && step != null)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final fade = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(fade);
                return FadeTransition(
                  opacity: fade,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>(guideState.overlayPageKey),
                child: _GuideOverlaySurface(
                  step: step,
                  currentIndex: math.min(
                    guideState.currentStepIndex + 1,
                    appGuideSteps.length - 1,
                  ),
                  totalSteps: appGuideSteps.length - 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GuideOverlaySurface extends ConsumerStatefulWidget {
  const _GuideOverlaySurface({
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
  });

  final AppGuideStep step;
  final int currentIndex;
  final int totalSteps;

  @override
  ConsumerState<_GuideOverlaySurface> createState() =>
      _GuideOverlaySurfaceState();
}

class _GuideOverlaySurfaceState extends ConsumerState<_GuideOverlaySurface> {
  static const int _maxProbeAttempts = 12;

  Timer? _probeTimer;
  int _probeAttempts = 0;

  @override
  void initState() {
    super.initState();
    _scheduleProbe();
  }

  @override
  void didUpdateWidget(covariant _GuideOverlaySurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _probeAttempts = 0;
      _scheduleProbe();
    }
  }

  @override
  void dispose() {
    _probeTimer?.cancel();
    super.dispose();
  }

  void _scheduleProbe() {
    _probeTimer?.cancel();
    if (widget.step.targetId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final registry = ref.read(appGuideTargetRegistryProvider);
      final hasRect = registry.globalRectFor(widget.step.targetId!) != null;
      if (hasRect || _probeAttempts >= _maxProbeAttempts) {
        setState(() {});
        return;
      }

      _probeAttempts += 1;
      _probeTimer = Timer(const Duration(milliseconds: 70), () {
        if (mounted) {
          setState(() {});
          _scheduleProbe();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppGuideCopy.step(context, widget.step.id);
    final colors = context.appColors;
    final mediaQuery = MediaQuery.of(context);
    final overlayBox = context.findRenderObject() as RenderBox?;
    final targetRect = _resolveTargetRect(overlayBox);
    final spotlightRect = _inflateRect(
      targetRect,
      widget.step.spotlightPadding,
    );
    final isCompletion = widget.step.id == AppGuideStepId.completion;

    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: CustomPaint(
                    painter: _GuideBackdropPainter(
                      spotlightRect: isCompletion ? null : spotlightRect,
                      spotlightRadius: widget.step.spotlightRadius,
                      accent: colors.primary,
                    ),
                  ),
                ),
              ),
              _buildPositionedCard(
                context: context,
                mediaQuery: mediaQuery,
                spotlightRect: spotlightRect,
                copy: copy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Rect? _resolveTargetRect(RenderBox? overlayBox) {
    final targetId = widget.step.targetId;
    if (targetId == null || overlayBox == null) {
      return null;
    }

    final registry = ref.read(appGuideTargetRegistryProvider);
    final globalRect = registry.globalRectFor(targetId);
    if (globalRect == null) {
      return null;
    }

    final topLeft = overlayBox.globalToLocal(globalRect.topLeft);
    final bottomRight = overlayBox.globalToLocal(globalRect.bottomRight);
    return Rect.fromPoints(topLeft, bottomRight);
  }

  Rect? _inflateRect(Rect? rect, EdgeInsets padding) {
    if (rect == null) {
      return null;
    }
    return Rect.fromLTRB(
      rect.left - padding.left,
      rect.top - padding.top,
      rect.right + padding.right,
      rect.bottom + padding.bottom,
    );
  }

  Widget _buildPositionedCard({
    required BuildContext context,
    required MediaQueryData mediaQuery,
    required Rect? spotlightRect,
    required AppGuidePanelCopy copy,
  }) {
    final size = mediaQuery.size;
    final safePadding = mediaQuery.padding;
    final isCompletion = widget.step.id == AppGuideStepId.completion;
    final compactCard = size.width < 640;
    final horizontalMargin = 16.0;
    final cardWidth = compactCard
        ? size.width - (horizontalMargin * 2)
        : math.min(392.0, size.width * 0.42);
    final largeSpotlight =
        spotlightRect != null &&
        (spotlightRect.height >= size.height * 0.58 ||
            spotlightRect.width >= size.width * 0.8);

    final card = Hero(
      tag: 'app-guide-card',
      child: Material(
        color: Colors.transparent,
        child: _GuideCard(
          copy: copy,
          currentIndex: widget.currentIndex,
          totalSteps: widget.totalSteps,
          isCompletion: isCompletion,
          onNext: ref.read(appGuideControllerProvider.notifier).next,
          onClose: ref.read(appGuideControllerProvider.notifier).dismiss,
        ),
      ),
    );

    if (isCompletion ||
        widget.step.panelSide == AppGuidePanelSide.center ||
        largeSpotlight ||
        spotlightRect == null) {
      return Positioned.fill(
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: card,
            ),
          ),
        ),
      );
    }

    if (compactCard) {
      final anchorNearBottom = spotlightRect.center.dy > (size.height * 0.62);
      return Positioned(
        left: horizontalMargin,
        right: horizontalMargin,
        top: anchorNearBottom ? safePadding.top + 16 : null,
        bottom: anchorNearBottom
            ? null
            : math.max(16.0, safePadding.bottom) + 16,
        child: card,
      );
    }

    final maxLeft = size.width - cardWidth - horizontalMargin;
    final preferredLeft = spotlightRect.center.dx - (cardWidth / 2);
    final clampedLeft = math.max(
      horizontalMargin,
      math.min(preferredLeft, maxLeft),
    );
    final availableAbove =
        spotlightRect.top - safePadding.top - horizontalMargin;
    final availableBelow =
        size.height -
        spotlightRect.bottom -
        safePadding.bottom -
        horizontalMargin;
    final showBelow = switch (widget.step.panelSide) {
      AppGuidePanelSide.below => true,
      AppGuidePanelSide.above => false,
      AppGuidePanelSide.auto => availableBelow >= availableAbove,
      AppGuidePanelSide.center => true,
    };

    if (showBelow) {
      return Positioned(
        left: clampedLeft,
        width: cardWidth,
        top: spotlightRect.bottom + 18,
        child: card,
      );
    }

    return Positioned(
      left: clampedLeft,
      width: cardWidth,
      bottom: size.height - spotlightRect.top + 18,
      child: card,
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.copy,
    required this.currentIndex,
    required this.totalSteps,
    required this.isCompletion,
    required this.onNext,
    required this.onClose,
  });

  final AppGuidePanelCopy copy;
  final int currentIndex;
  final int totalSteps;
  final bool isCompletion;
  final Future<void> Function() onNext;
  final Future<void> Function() onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: colors.surface.withValues(alpha: 0.98),
        border: Border.all(color: colors.primary.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: colors.primary.withValues(alpha: 0.14),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  AppGuideCopy.stepCounter(
                    context,
                    current: currentIndex,
                    total: totalSteps,
                    isCompletion: isCompletion,
                  ),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            copy.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            copy.body,
            style: TextStyle(color: colors.textSecondary, height: 1.45),
          ),
          if (copy.tips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              AppGuideCopy.tipsTitle(context),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ...copy.tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.bolt_rounded, color: colors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: colors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (copy.hotkeys.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              AppGuideCopy.hotkeysTitle(context),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: copy.hotkeys
                  .map(
                    (hotkey) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: colors.backgroundElevated,
                        border: Border.all(color: colors.divider),
                      ),
                      child: Text(
                        hotkey,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onNext,
              icon: Icon(
                isCompletion
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(copy.actionLabel ?? AppGuideCopy.nextLabel(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideBackdropPainter extends CustomPainter {
  const _GuideBackdropPainter({
    required this.spotlightRect,
    required this.spotlightRadius,
    required this.accent,
  });

  final Rect? spotlightRect;
  final double spotlightRadius;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()..addRect(Offset.zero & size);
    if (spotlightRect != null) {
      final holePath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            spotlightRect!,
            Radius.circular(spotlightRadius),
          ),
        );
      final maskedPath = Path.combine(
        PathOperation.difference,
        overlayPath,
        holePath,
      );
      canvas.drawPath(
        maskedPath,
        Paint()..color = Colors.black.withValues(alpha: 0.7),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          spotlightRect!,
          Radius.circular(spotlightRadius),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = accent.withValues(alpha: 0.95),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          spotlightRect!,
          Radius.circular(spotlightRadius),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
          ..color = accent.withValues(alpha: 0.18),
      );
      return;
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _GuideBackdropPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect ||
        oldDelegate.spotlightRadius != spotlightRadius ||
        oldDelegate.accent != accent;
  }
}
