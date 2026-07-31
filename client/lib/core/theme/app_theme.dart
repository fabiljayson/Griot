import 'package:flutter/material.dart';

class AppTheme {
  // Color palette inspired by African textiles and manuscripts
  static const Color primaryColor = Color(0xFF8B4513); // Saddle Brown (Manuscript)
  static const Color secondaryColor = Color(0xFFDAA520); // Goldenrod (Gold accents)
  static const Color accentColor = Color(0xFF228B22); // Forest Green (Living Archive)
  static const Color backgroundColor = Color(0xFFF5F5DC); // Beige (Parchment)
  static const Color surfaceColor = Color(0xFFFAF0E6); // Linen
  static const Color errorColor = Color(0xFFB22222); // Firebrick
  static const Color textPrimary = Color(0xFF2F2F2F); // Dark Gray
  static const Color textSecondary = Color(0xFF696969); // Dim Gray
  
  // Typography
  static const String primaryFontFamily = 'Georgia'; // Manuscript-like font
  static const String secondaryFontFamily = 'Roboto'; // Modern readable font
  
  static TextStyle get headingLarge => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle get headingMedium => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle get headingSmall => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 16,
    color: textPrimary,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 14,
    color: textPrimary,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 12,
    color: textSecondary,
  );
  
  // Light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      headlineSmall: headingSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    ),
  );
}