import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

enum AppNoticeType {
  info,
  success,
  error,
}

class AppNotice {
  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String message,
    AppNoticeType type = AppNoticeType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _activeEntry?.remove();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NoticeOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
          entry.remove();
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _NoticeOverlay extends StatefulWidget {
  const _NoticeOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final AppNoticeType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_NoticeOverlay> createState() => _NoticeOverlayState();
}

class _NoticeOverlayState extends State<_NoticeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.18, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed) {
      return;
    }
    _dismissed = true;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final mediaQuery = MediaQuery.of(context);
    final accent = switch (widget.type) {
      AppNoticeType.info => colors.primary,
      AppNoticeType.success => colors.success,
      AppNoticeType.error => colors.danger,
    };

    return Positioned(
      top: mediaQuery.padding.top + 14,
      right: 14,
      left: mediaQuery.size.width < 460 ? 14 : null,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.44)),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        switch (widget.type) {
                          AppNoticeType.info => Icons.info_outline_rounded,
                          AppNoticeType.success =>
                            Icons.check_circle_outline_rounded,
                          AppNoticeType.error => Icons.error_outline_rounded,
                        },
                        color: accent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
