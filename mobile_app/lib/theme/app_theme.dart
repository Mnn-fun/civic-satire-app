import 'package:flutter/material.dart';

class AppTheme {
  // Deep, dark primary colors for a sleek, high-contrast civic satire look
  static const Color background = Color(0xFF09090B); // Deep dark background (zinc-950)
  static const Color surface = Color(0xFF18181B); // Dark surface (zinc-900)
  static const Color surfaceContainer = Color(0xFF27272A); // Card background (zinc-800)
  static const Color primary = Color(0xFFE11D48); // Striking crimson/rose for satire/civic alerts
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF3B82F6); // Bold civic blue
  static const Color onSecondary = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Colors.white;

  static const Color textHighContrast = Color(0xFFFAFAFA); // Crisp white
  static const Color textMediumContrast = Color(0xFFA1A1AA); // Zinc 400
  static const Color textLowContrast = Color(0xFF71717A); // Zinc 500

  static ThemeData get darkTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surface,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
    ).copyWith(
      surface: surface,
      surfaceContainerHighest: surfaceContainer,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      // Clean, high-contrast typography using native system fonts (default sans-serif)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textHighContrast,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textHighContrast,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: textHighContrast,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: textHighContrast,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: textHighContrast,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textHighContrast,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textHighContrast,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textHighContrast,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textHighContrast,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textHighContrast,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textHighContrast,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: textMediumContrast,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textHighContrast,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: textMediumContrast,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: textLowContrast,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textHighContrast,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textHighContrast,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF3F3F46), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF27272A),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: textHighContrast,
      ),
    );
  }
}
