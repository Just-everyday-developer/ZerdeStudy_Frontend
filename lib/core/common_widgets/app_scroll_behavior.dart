import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  bool get _hideDesktopScrollbarOnWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        ...super.dragDevices,
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (_hideDesktopScrollbarOnWindows) {
      return child;
    }
    return super.buildScrollbar(context, child, details);
  }
}
