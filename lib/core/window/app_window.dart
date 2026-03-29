import 'package:flutter/widgets.dart';

import 'app_window_stub.dart' if (dart.library.io) 'app_window_io.dart' as impl;

Future<void> configureAppWindow() => impl.configureAppWindow();

bool get supportsCustomWindowFrame => impl.supportsCustomWindowFrame;

Widget buildAppWindowFrame({required Widget child}) {
  return impl.buildAppWindowFrame(child: child);
}
