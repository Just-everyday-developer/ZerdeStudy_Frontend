import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        palette: AppThemeColors.dark,
      );

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        palette: AppThemeColors.light,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemeColors palette,
  }) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
    );
    final baseTextTheme = GoogleFonts.ibmPlexSansTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: palette.primary,
        primary: palette.primary,
        secondary: palette.accent,
        surface: palette.surface,
        error: palette.danger,
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ).copyWith(
        displayLarge: GoogleFonts.orbitron(
          textStyle: baseTextTheme.displayLarge,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        displayMedium: GoogleFonts.orbitron(
          textStyle: baseTextTheme.displayMedium,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        headlineLarge: GoogleFonts.orbitron(
          textStyle: baseTextTheme.headlineLarge,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        headlineMedium: GoogleFonts.orbitron(
          textStyle: baseTextTheme.headlineMedium,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface.withValues(alpha: 0.94),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.ibmPlexSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.textSecondary,
          );
        }),
        indicatorColor: palette.primary.withValues(alpha: 0.14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceSoft.withValues(alpha: 0.92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.divider.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.divider.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.primary, width: 1.4),
        ),
        hintStyle: GoogleFonts.ibmPlexSans(
          color: palette.textSecondary,
        ),
      ),
      dividerColor: palette.divider,
      cardTheme: CardThemeData(
        color: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
