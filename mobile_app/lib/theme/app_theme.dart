import 'package:flutter/material.dart';

/// Global Canvas Theme: Google Stitch 'StreetVoice' Light UI Design
/// Features solid white (#FFFFFF) background, clean low-density layout,
/// and flat un-congested rectangular boundaries with exactly 8dp border radius.
class AppTheme {
  // Pure White foundation and airy Google Stitch palette
  static const Color scaffoldBackground = Color(0xFFFFFFFF); // Solid white (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF6FAFF); // Airy light tint
  static const Color surfaceContainerHigh = Color(0xFFEAEEF4);
  static const Color surfaceVariant = Color(0xFFDEE3E8);

  // Google Signature Colors
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleBlueDark = Color(0xFF0058BD);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC04);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleGreenDark = Color(0xFF047857);
  static const Color neutralOutline = Color(0xFF70757A);
  static const Color borderLight = Color(0xFFDEE3E8);

  // High-legibility typography colors
  static const Color textPrimary = Color(0xFF171C20); // Off-black
  static const Color textSecondary = Color(0xFF424753); // Medium grey
  static const Color textTertiary = Color(0xFF70757A); // Subtle grey

  static ThemeData get lightTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: googleBlue,
      brightness: Brightness.light,
      surface: surface,
      primary: googleBlueDark,
      onPrimary: Colors.white,
      secondary: googleGreenDark,
      onSecondary: Colors.white,
      error: googleRed,
      onError: Colors.white,
    ).copyWith(
      surface: surface,
      surfaceContainerHighest: surfaceContainerHigh,
      outline: neutralOutline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      fontFamily: 'Roboto', // Clean system sans-serif font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: TextStyle(
          color: textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Exactly 8dp radius
          side: const BorderSide(color: borderLight, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      ),
      // Configure interactive buttons with flat, un-congested rectangular boundaries (8dp radius),
      // translucent base color fills, and sharp 1.5dp colored accent outline (Google Blue for main actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: googleBlue.withValues(alpha: 0.10), // Translucent fill
          foregroundColor: googleBlueDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Exactly 8dp radius
            side: const BorderSide(color: googleBlue, width: 1.5), // Sharp 1.5dp outline
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: googleGreen.withValues(alpha: 0.10), // Translucent Google Green for media/secondary
          foregroundColor: googleGreenDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Exactly 8dp radius
            side: const BorderSide(color: googleGreen, width: 1.5), // Sharp 1.5dp Google Green outline
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: googleBlueDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface, // White rectangular shape
        hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Exactly 8dp radius
          borderSide: const BorderSide(color: borderLight, width: 1.5), // Light translucent gray boundary
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: googleBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: googleRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: googleRed, width: 2.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    );
  }

  // Alias darkTheme to lightTheme to enforce the Google Stitch StreetVoice Light UI across the entire application
  static ThemeData get darkTheme => lightTheme;
}
