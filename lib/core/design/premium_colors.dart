/// Premium Color System for NutriCare+ v2.0
/// Advanced professional color palette with gradient support

import 'package:flutter/material.dart';

abstract class PremiumColors {
  // ============================================
  // PRIMARY NEON GREEN GRADIENT SYSTEM
  // ============================================
  
  static const Color primaryNeon = Color(0xFF76FF03);
  static const Color primaryNeonLight = Color(0xFF9FFF4F);
  static const Color primaryNeonDark = Color(0xFF64DD00);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF64DD00), Color(0xFF76FF03), Color(0xFF9FFF4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryGradientReverse = LinearGradient(
    colors: [Color(0xFF9FFF4F), Color(0xFF76FF03), Color(0xFF64DD00)],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );
  
  // ============================================
  // DARK LUXURY BACKGROUNDS
  // ============================================
  
  static const Color darkLuxury = Color(0xFF0A0E1A);
  static const Color darkLuxuryLight = Color(0xFF121829);
  static const Color darkLuxuryLighter = Color(0xFF1A1F2E);
  static const Color darkLuxurySurface = Color(0xFF1E232F);
  
  // ============================================
  // ACCENT COLORS - COMPLEMENTARY PALETTE
  // ============================================
  
  // BLUES (Professional, Tech)
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentBlueLarge = Color(0xFF0055FF);
  static const Color accentBluePale = Color(0xFF5B9FFF);
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5B9FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // PURPLES (Premium, Luxury)
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleLight = Color(0xFFA78BFA);
  static const Color accentPurpleDark = Color(0xFF7C3AED);
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ORANGES (Energy, Activity)
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentOrangePale = Color(0xFFFF8C42);
  static const Color accentOrangeDark = Color(0xFFFF5722);
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // PINKS (Health, Wellness)
  static const Color accentPink = Color(0xFFFF1493);
  static const Color accentPinkLight = Color(0xFFFF68B8);
  static const Color accentPinkDark = Color(0xFFC2185B);
  
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF1493), Color(0xFFFF68B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // TEAL (Hydration, Recovery)
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentTealLight = Color(0xFF2DD4BF);
  
  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================
  // SEMANTIC COLORS
  // ============================================
  
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  
  // ============================================
  // GLASS & TRANSPARENCY EFFECTS
  // ============================================
  
  static const Color glassLight = Color(0x1A9FFF4F);  // 10% opacity green
  static const Color glassMedium = Color(0x33FFFFFF);  // 20% opacity white
  static const Color glassDark = Color(0x4D1A1F2E);    // 30% opacity dark
  static const Color glassBlue = Color(0x19007AFF);    // 10% opacity blue
  static const Color glassPurple = Color(0x198B5CF6);  // 10% opacity purple
  
  // ============================================
  // TEXT COLORS - HIERARCHY
  // ============================================
  
  static const Color textPrimary = Color(0xFFFFFFFF);    // White
  static const Color textSecondary = Color(0xFFB0B8CC);  // Light gray
  static const Color textTertiary = Color(0xFF6B7280);   // Medium gray
  static const Color textQuaternary = Color(0xFF4B5563); // Dark gray
  
  // ============================================
  // DIVIDER & BORDERS
  // ============================================
  
  static const Color divider = Color(0xFF2D3748);
  static const Color dividerLight = Color(0xFF3F4956);
  static const Color border = Color(0xFF424C5A);
  
  // ============================================
  // UTILITY COLORS
  // ============================================
  
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  
  static const Color shadow = Color(0x00000000);
  
  // ============================================
  // COLOR SCHEMES BY CONTEXT
  // ============================================
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF64DD00),
      Color(0xFF76FF03),
      Color(0xFF007AFF),
      Color(0xFF8B5CF6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.33, 0.66, 1],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0x1A9FFF4F),
      Color(0x0D76FF03),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFF64DD00),
      Color(0xFF76FF03),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // ============================================
  // DARK MODE ADJUSTMENTS
  // ============================================
  
  static const Map<int, Color> darkPalette = {
    0: darkLuxury,
    1: darkLuxuryLight,
    2: darkLuxuryLighter,
    3: darkLuxurySurface,
  };
  
  // ============================================
  // COLOR UTILITIES
  // ============================================
  
  /// Get a list of accent colors for cycling/iteration
  static List<Color> get accentColors => [
    primaryNeon,
    accentBlue,
    accentPurple,
    accentOrange,
    accentPink,
    accentTeal,
  ];
  
  /// Get a list of accent gradients
  static List<LinearGradient> get accentGradients => [
    primaryGradient,
    blueGradient,
    purpleGradient,
    orangeGradient,
    pinkGradient,
    tealGradient,
  ];
  
  /// Get accent color for index
  static Color accentForIndex(int index) => accentColors[index % accentColors.length];
  
  /// Get accent gradient for index
  static LinearGradient gradientForIndex(int index) => accentGradients[index % accentGradients.length];
}
