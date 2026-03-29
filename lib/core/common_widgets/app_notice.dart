import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

enum AppNoticeType { info, success, error }

class AppNoticeEntry {
  const AppNoticeEntry({
    required this.id,
    required this.message,
    required this.type,
    required this.duration,
  });

  final String id;
  final String message;
  final AppNoticeType type;
  final Duration duration;
}

class AppNotice {
  static OverlayEntry? _overlayEntry;
  static final ValueNotifier<List<AppNoticeEntry>> _entries =
      ValueNotifier<List<AppNoticeEntry>>(<AppNoticeEntry>[]);

  static void show(
    BuildContext context, {
    required String message,
    AppNoticeType type = AppNoticeType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (_) => _NoticeStack(entries: _entries),
      );
      overlay.insert(_overlayEntry!);
    }

    final entry = AppNoticeEntry(
      id: 'notice-${DateTime.now().microsecondsSinceEpoch}',
      message: message,
      type: type,
      duration: duration,
    );

    final current = _entries.value;
    if (current.isNotEmpty &&
        current.first.message == message &&
        current.first.type == type) {
      return;
    }

    _entries.value = <AppNoticeEntry>[entry];
  }

  static void _remove(String id) {
    final nextEntries = _entries.value
        .where((entry) => entry.id != id)
        .toList(growable: false);
    _entries.value = nextEntries;
    if (nextEntries.isEmpty && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

class _NoticeStack extends StatelessWidget {
  const _NoticeStack({required this.entries});

  final ValueNotifier<List<AppNoticeEntry>> entries;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AppNoticeEntry>>(
      valueListenable: entries,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        final mediaQuery = MediaQuery.of(context);
        return Positioned(
          top: mediaQuery.padding.top + 14,
          right: 14,
          left: mediaQuery.size.width < 460 ? 14 : null,
          child: IgnorePointer(
            child: SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: items
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NoticeTile(
                            entry: entry,
                            onDismissed: () => AppNotice._remove(entry.id),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoticeTile extends StatefulWidget {
  const _NoticeTile({required this.entry, required this.onDismissed});

  final AppNoticeEntry entry;
  final VoidCallback onDismissed;

  @override
  State<_NoticeTile> createState() => _NoticeTileState();
}

class _NoticeTileState extends State<_NoticeTile>
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
    _dismissTimer = Timer(widget.entry.duration, _dismiss);
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
    final accent = switch (widget.entry.type) {
      AppNoticeType.info => colors.primary,
      AppNoticeType.success => colors.success,
      AppNoticeType.error => colors.danger,
    };

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  switch (widget.entry.type) {
                    AppNoticeType.info => Icons.info_outline_rounded,
                    AppNoticeType.success => Icons.check_circle_outline_rounded,
                    AppNoticeType.error => Icons.error_outline_rounded,
                  },
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.entry.message,
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
    );
  }
}
