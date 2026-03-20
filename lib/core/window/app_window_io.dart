import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_theme_colors.dart';

bool get supportsCustomWindowFrame => Platform.isWindows;

Future<void> configureAppWindow() async {
  if (!Platform.isWindows) {
    return;
  }

  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(1440, 920),
    minimumSize: Size(980, 720),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Widget buildAppWindowFrame({
  required Widget child,
}) {
  if (!Platform.isWindows) {
    return child;
  }
  return _DesktopWindowFrame(child: child);
}

class _DesktopWindowFrame extends StatefulWidget {
  const _DesktopWindowFrame({
    required this.child,
  });

  final Widget child;

  @override
  State<_DesktopWindowFrame> createState() => _DesktopWindowFrameState();
}

class _DesktopWindowFrameState extends State<_DesktopWindowFrame>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _refreshWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => _refreshWindowState();

  @override
  void onWindowUnmaximize() => _refreshWindowState();

  @override
  void onWindowRestore() => _refreshWindowState();

  Future<void> _refreshWindowState() async {
    final maximized = await windowManager.isMaximized();
    if (!mounted) {
      return;
    }
    setState(() => _isMaximized = maximized);
  }

  Future<void> _toggleWindowSize() async {
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    await _refreshWindowState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return VirtualWindowFrame(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
        ),
        child: Column(
          children: [
            Container(
              height: 38,
              color: colors.backgroundElevated.withValues(alpha: 0.98),
              child: Row(
                children: [
                  Expanded(
                    child: DragToMoveArea(
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  WindowCaptionButton.minimize(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                    onPressed: () async {
                      final isMinimized = await windowManager.isMinimized();
                      if (isMinimized) {
                        await windowManager.restore();
                      } else {
                        await windowManager.minimize();
                      }
                    },
                  ),
                  (_isMaximized
                          ? WindowCaptionButton.unmaximize
                          : WindowCaptionButton.maximize)(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                    onPressed: _toggleWindowSize,
                  ),
                  WindowCaptionButton.close(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                    onPressed: () => windowManager.close(),
                  ),
                ],
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
