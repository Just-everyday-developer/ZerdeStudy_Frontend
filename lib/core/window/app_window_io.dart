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

class _DesktopWindowFrame extends StatelessWidget {
  const _DesktopWindowFrame({
    required this.child,
  });

  final Widget child;

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
                  FutureBuilder<bool>(
                    future: windowManager.isMaximized(),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return WindowCaptionButton.unmaximize(
                          brightness:
                              isDark ? Brightness.dark : Brightness.light,
                          onPressed: () => windowManager.unmaximize(),
                        );
                      }
                      return WindowCaptionButton.maximize(
                        brightness:
                            isDark ? Brightness.dark : Brightness.light,
                        onPressed: () => windowManager.maximize(),
                      );
                    },
                  ),
                  WindowCaptionButton.close(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                    onPressed: () => windowManager.close(),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
