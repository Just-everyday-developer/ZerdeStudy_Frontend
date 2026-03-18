import 'package:flutter/material.dart';

enum AppThemeMode {
  dark(code: 'dark', label: 'Dark', materialMode: ThemeMode.dark),
  light(code: 'light', label: 'Light', materialMode: ThemeMode.light);

  const AppThemeMode({
    required this.code,
    required this.label,
    required this.materialMode,
  });

  final String code;
  final String label;
  final ThemeMode materialMode;

  static AppThemeMode fromCode(String? code) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.code == code,
      orElse: () => AppThemeMode.dark,
    );
  }
}
