import 'package:flutter/material.dart';
import 'app_colors.dart';
export 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.cardForeground,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTypography.getTextTheme(),
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        ai: AppColors.ai,
        aiSoft: AppColors.aiSoft,
        aiForeground: AppColors.aiForeground,
        warningSoft: AppColors.warningSoft,
        warningForeground: AppColors.warningForeground,
        accentSoft: AppColors.accentSoft,
        accentSoftForeground: AppColors.accentSoftForeground,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      error: AppColors.danger,
      onError: Colors.white,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: AppTypography.getDarkTextTheme(),
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        ai: AppColors.ai,
        aiSoft: Color(0xFF2C1654), // Darker ai soft
        aiForeground: Colors.white,
        warningSoft: Color(0xFF4D3300), // Darker warning soft
        warningForeground: AppColors.warning,
        accentSoft: Color(0xFF003322), // Darker accent soft
        accentSoftForeground: AppColors.accent,
      ),
    ],
  );
}
