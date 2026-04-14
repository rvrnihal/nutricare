import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutriTheme {
  // 🎨 COLORS
  static const Color primary = Color(0xFF76FF03); // High Contrast Neon Green
  static const Color background = Colors.black; // Global Black Background
  static const Color surface = Color(0xFF1E1E1E); // Dark Grey Surface
  static const Color text = Colors.white; // Global White Text
  static const Color textSecondary = Colors.grey;
  static const Color error = Color(0xFFFF4B4B);

  // 🌙 DARK COLORS (Redundant but kept for structure)
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;

  // 🖌️ TEXT STYLES
  static TextTheme get textTheme {
    return GoogleFonts.outfitTextTheme().apply(
      bodyColor: text,
      displayColor: text,
    );
  }

  // 🌓 THEME DATA
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark, // Must match ColorScheme.dark
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        // Force Dark Scheme
        primary: primary,
        secondary: Colors.white,
        surface: surface,
        error: error,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: text,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: primary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: Colors.white,
        surface: darkSurface,
        error: error,
      ),
      textTheme: textTheme.apply(bodyColor: darkText, displayColor: darkText),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: darkText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
