import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.backgroundElevated,
    required this.surface,
    required this.surfaceSoft,
    required this.primary,
    required this.accent,
    required this.success,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.pageGradient,
    required this.authGradient,
    required this.treeTrunk,
    required this.treeTrunkGlow,
  });

  final Color background;
  final Color backgroundElevated;
  final Color surface;
  final Color surfaceSoft;
  final Color primary;
  final Color accent;
  final Color success;
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final List<Color> pageGradient;
  final List<Color> authGradient;
  final Color treeTrunk;
  final Color treeTrunkGlow;

  static const AppThemeColors dark = AppThemeColors(
    background: Color(0xFF0A0F1D),
    backgroundElevated: Color(0xFF11192D),
    surface: Color(0xFF131A2A),
    surfaceSoft: Color(0xFF172238),
    primary: Color(0xFF00E5FF),
    accent: Color(0xFFFF9100),
    success: Color(0xFF6EE7B7),
    danger: Color(0xFFFF6B7A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF8B95A9),
    divider: Color(0xFF24314E),
    pageGradient: <Color>[
      Color(0xFF0A0F1D),
      Color(0xFF08111F),
      Color(0xFF050A14),
    ],
    authGradient: <Color>[
      Color(0xFF0A0F1D),
      Color(0xFF11192D),
      Color(0xFF0A0F1D),
    ],
    treeTrunk: Color(0xFF6D4A2D),
    treeTrunkGlow: Color(0xFF8B6A4E),
  );

  static const AppThemeColors light = AppThemeColors(
    background: Color(0xFFF9F9FB),
    backgroundElevated: Color(0xFFF1F1F5),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFECECEF),
    primary: Color(0xFF4F46E5),
    accent: Color(0xFFF59E0B),
    success: Color(0xFF10B981),
    danger: Color(0xFFEF4444),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    divider: Color(0xFFE5E7EB),
    pageGradient: <Color>[
      Color(0xFFF9F9FB),
      Color(0xFFF3F4F6),
      Color(0xFFECECEF),
    ],
    authGradient: <Color>[
      Color(0xFFF9F9FB),
      Color(0xFFF3F4F6),
      Color(0xFFF9F9FB),
    ],
    treeTrunk: Color(0xFF8B5A2B),
    treeTrunkGlow: Color(0xFFA0522D),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? backgroundElevated,
    Color? surface,
    Color? surfaceSoft,
    Color? primary,
    Color? accent,
    Color? success,
    Color? danger,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    List<Color>? pageGradient,
    List<Color>? authGradient,
    Color? treeTrunk,
    Color? treeTrunkGlow,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      pageGradient: pageGradient ?? this.pageGradient,
      authGradient: authGradient ?? this.authGradient,
      treeTrunk: treeTrunk ?? this.treeTrunk,
      treeTrunkGlow: treeTrunkGlow ?? this.treeTrunkGlow,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      background: Color.lerp(background, other.background, t) ?? background,
      backgroundElevated:
          Color.lerp(backgroundElevated, other.backgroundElevated, t) ??
          backgroundElevated,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t) ?? surfaceSoft,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      success: Color.lerp(success, other.success, t) ?? success,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      pageGradient: <Color>[
        for (var index = 0; index < pageGradient.length; index++)
          Color.lerp(pageGradient[index], other.pageGradient[index], t) ??
              pageGradient[index],
      ],
      authGradient: <Color>[
        for (var index = 0; index < authGradient.length; index++)
          Color.lerp(authGradient[index], other.authGradient[index], t) ??
              authGradient[index],
      ],
      treeTrunk: Color.lerp(treeTrunk, other.treeTrunk, t) ?? treeTrunk,
      treeTrunkGlow:
          Color.lerp(treeTrunkGlow, other.treeTrunkGlow, t) ?? treeTrunkGlow,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.dark;
}
