import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // Secondary
  static const Color secondary = Color(0xFFDBEAFE);
  static const Color secondaryForeground = Color(0xFF1E40AF);

  // Accent
  static const Color accent = Color(0xFF10B981);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color accentSoft = Color(0xFFD1FAE5);
  static const Color accentSoftForeground = Color(0xFF065F46);

  // Background & Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF1A1D23);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1A1D23);
  
  // Border & Inputs
  static const Color border = Color(0xFFE8EDF3);
  static const Color input = Color(0xFFF4F6FA);

  // Muted
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);

  // Semantic
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color warningForeground = Color(0xFF92400E);
  
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  
  static const Color ai = Color(0xFF7C3AED);
  static const Color aiSoft = Color(0xFFEDE9FE);
  static const Color aiForeground = Color(0xFFFFFFFF);
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color ai;
  final Color aiSoft;
  final Color aiForeground;
  final Color warningSoft;
  final Color warningForeground;
  final Color accentSoft;
  final Color accentSoftForeground;

  const AppThemeExtension({
    required this.ai,
    required this.aiSoft,
    required this.aiForeground,
    required this.warningSoft,
    required this.warningForeground,
    required this.accentSoft,
    required this.accentSoftForeground,
  });

  @override
  AppThemeExtension copyWith({
    Color? ai,
    Color? aiSoft,
    Color? aiForeground,
    Color? warningSoft,
    Color? warningForeground,
    Color? accentSoft,
    Color? accentSoftForeground,
  }) {
    return AppThemeExtension(
      ai: ai ?? this.ai,
      aiSoft: aiSoft ?? this.aiSoft,
      aiForeground: aiForeground ?? this.aiForeground,
      warningSoft: warningSoft ?? this.warningSoft,
      warningForeground: warningForeground ?? this.warningForeground,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSoftForeground: accentSoftForeground ?? this.accentSoftForeground,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      ai: Color.lerp(ai, other.ai, t)!,
      aiSoft: Color.lerp(aiSoft, other.aiSoft, t)!,
      aiForeground: Color.lerp(aiForeground, other.aiForeground, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningForeground: Color.lerp(warningForeground, other.warningForeground, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentSoftForeground: Color.lerp(accentSoftForeground, other.accentSoftForeground, t)!,
    );
  }
}
