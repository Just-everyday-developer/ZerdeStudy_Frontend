import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppBreakpoint {
  compact,
  medium,
  wide;

  static AppBreakpoint fromWidth(double width) {
    if (width >= 1024) {
      return AppBreakpoint.wide;
    }
    if (width >= 700) {
      return AppBreakpoint.medium;
    }
    return AppBreakpoint.compact;
  }
}

extension AppBreakpointX on BuildContext {
  AppBreakpoint get appBreakpoint {
    return AppBreakpoint.fromWidth(MediaQuery.sizeOf(this).width);
  }

  bool get isNativeWindowsApp {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  bool get isCompactLayout => appBreakpoint == AppBreakpoint.compact;

  bool get isMediumLayout => appBreakpoint == AppBreakpoint.medium;

  bool get isWideLayout => appBreakpoint == AppBreakpoint.wide;

  double get appPageMaxWidth {
    switch (appBreakpoint) {
      case AppBreakpoint.compact:
        return 560;
      case AppBreakpoint.medium:
        return isNativeWindowsApp ? 1040 : 900;
      case AppBreakpoint.wide:
        return isNativeWindowsApp ? 1560 : 1360;
    }
  }

  double get appPageHorizontalPadding {
    switch (appBreakpoint) {
      case AppBreakpoint.compact:
        return 16;
      case AppBreakpoint.medium:
        return isNativeWindowsApp ? 20 : 24;
      case AppBreakpoint.wide:
        return isNativeWindowsApp ? 24 : 32;
    }
  }
}
