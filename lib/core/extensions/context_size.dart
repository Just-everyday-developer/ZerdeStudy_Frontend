import 'package:flutter/material.dart';

extension ContextSize on BuildContext {
  Size get size => MediaQuery.sizeOf(this);
  double get w => size.width;
  double get h => size.height;
  double get u => size.width / 390.0; // Множитель для разных экранов

  double get safeTop => MediaQuery.paddingOf(this).top;
  double get safeBottom => MediaQuery.paddingOf(this).bottom;
}