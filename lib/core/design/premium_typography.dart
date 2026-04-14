/// Premium Typography System for NutriCare+ v2.0
/// Professional text styles with complete hierarchy

import 'package:flutter/material.dart';

abstract class PremiumTypography {
  // Font Family: "Plus Jakarta Sans" (must add to pubspec.yaml and assets)
  // Alternative: 'Roboto' if Plus Jakarta Sans not available
  
  static const String fontFamily = 'Plus Jakarta Sans';
  
  // ============================================
  // DISPLAY STYLES - Hero/Large Headings
  // ============================================
  
  /// Large headline for page titles (56px)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.2,
    color: Color(0xFFFFFFFF),
  );
  
  /// Medium headline (44px)
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
    color: Color(0xFFFFFFFF),
  );
  
  /// Small headline (36px)
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.3,
    color: Color(0xFFFFFFFF),
  );
  
  // ============================================
  // HEADLINE STYLES - Section Headers
  // ============================================
  
  /// Large section header (32px)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.4,
    color: Color(0xFFFFFFFF),
  );
  
  /// Medium section header (28px)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.4,
    color: Color(0xFFFFFFFF),
  );
  
  /// Small section header (24px)
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: Color(0xFFFFFFFF),
  );
  
  // ============================================
  // TITLE STYLES - Card Titles, Emphasis
  // ============================================
  
  /// Large title (20px)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: Color(0xFFFFFFFF),
  );
  
  /// Medium title (18px)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFFFFFFFF),
  );
  
  /// Small title (16px)
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFFFFFFFF),
  );
  
  // ============================================
  // BODY STYLES - Regular Text Content
  // ============================================
  
  /// Large body text (16px)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.6,
    color: Color(0xFFFFFFFF),
  );
  
  /// Medium body text (14px)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.6,
    color: Color(0xFFB0B8CC),
  );
  
  /// Small body text (12px)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.6,
    color: Color(0xFF6B7280),
  );
  
  // ============================================
  // LABEL STYLES - Tags, Badges, Small Labels
  // ============================================
  
  /// Large label (14px)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFFFFFFFF),
  );
  
  /// Medium label (12px)
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.5,
    color: Color(0xFFB0B8CC),
  );
  
  /// Small label (11px)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.5,
    color: Color(0xFF6B7280),
  );
  
  // ============================================
  // CUSTOM STYLES FOR SPECIFIC USE CASES
  // ============================================
  
  /// Button text - prominent, readable
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  /// Caption style (10px, small descriptions)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.4,
    color: Color(0xFF6B7280),
  );
  
  /// Overline style (uppercase, 12px)
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1.4,
    color: Color(0xFF6B7280),
  );
  
  /// Metric/Number style (for displaying stats)
  static const TextStyle metric = TextStyle(
    fontFamily: 'Courier New',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: Color(0xFF76FF03),
  );
  
  // ============================================
  // THEMED TEXT STYLES
  // ============================================
  
  /// Error text (red)
  static const TextStyle errorText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFFEF4444),
  );
  
  /// Success text (green)
  static const TextStyle successText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFF10B981),
  );
  
  /// Muted text (secondary color)
  static const TextStyle mutedText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFF6B7280),
  );
  
  /// Subtle text (tertiary color)
  static const TextStyle subtleText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: Color(0xFF4B5563),
  );
  
  // ============================================
  // INTERACTIVE STYLES
  // ============================================
  
  /// Link text (blue, underlined)
  static TextStyle linkText = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFF007AFF),
    decoration: TextDecoration.underline,
  );
  
  /// Disabled text (grayed out)
  static const TextStyle disabledText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: Color(0xFF4B5563),
  );
  
  // ============================================
  // UTILITY METHODS
  // ============================================
  
  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Get gradient text style (requires ShaderMask for actual gradient)
  static TextStyle gradientStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.5,
      height: 1.2,
      color: const Color(0xFF76FF03),
    );
  }
  
  // ============================================
  // TEXT THEME EXTENSION
  // ============================================
  
  /// Create a TextTheme for MaterialApp customization
  static const TextTheme appTextTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
