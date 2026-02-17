import 'package:flutter/material.dart';

extension ContextSize on BuildContext {
  Size get size => MediaQuery.sizeOf(this);
  double get w => size.width;
  double get h => size.height;
  double get u => size.width / 390.0; // Условная "масштабная единица" — удобно привязывать размеры к экрану
// 390 — типичная ширина iPhone 12/13

  double get safeTop => MediaQuery.paddingOf(this).top;
  double get safeBottom => MediaQuery.paddingOf(this).bottom;
}