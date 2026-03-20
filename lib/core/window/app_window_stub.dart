import 'package:flutter/widgets.dart';

Future<void> configureAppWindow() async {}

bool get supportsCustomWindowFrame => false;

Widget buildAppWindowFrame({
  required Widget child,
}) {
  return child;
}

