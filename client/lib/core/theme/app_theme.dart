import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Design Tokens: "Ancient Manuscript meets Living Archive" ──
  static const Color terracotta = Color(0xFFC85A32);   // Primary – warm clay
  static const Color ochre = Color(0xFFDAA520);          // Accent – golden manuscript ink
  static const Color savannahGreen = Color(0xFF2E5A44);  // Tertiary – living archive
  static const Color charcoal = Color(0xFF2B2B2B);       // Text primary
  static const Color parchment = Color(0xFFF5EDDC);      // Background – aged papyrus
  static const Color sandstone = Color(0xFFFAF0E6);      // Surface – light linen
  static const Color warmGray = Color(0xFF6B6358);       // Text secondary – aged ink
  static const Color deepAmber = Color(0xFFB8860B);      // Error/Warning
  static const Color ivory = Color(0xFFFFFBF5);          // Cards – clean ivory
  static const Color clayLight = Color(0xFFF0DCC8);      // Subtle warm tint

  // ── Typography ──
  static TextTheme get _textTheme => GoogleFonts.notoSerifTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Noto Serif',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: charcoal,
            letterSpacing: 0.5,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Noto Serif',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: charcoal,
            letterSpacing: 0.3,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Noto Serif',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: charcoal,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Noto Serif',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: charcoal,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Noto Serif',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: charcoal,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 16,
            color: charcoal,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14,
            color: charcoal,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 12,
            color: warmGray,
            height: 1.3,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      );

  // ── Light Theme ──
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: terracotta,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFF5CABC),
          onPrimaryContainer: const Color(0xFF4A1A00),
          secondary: ochre,
          onSecondary: charcoal,
          secondaryContainer: const Color(0xFFF5E6B8),
          onSecondaryContainer: const Color(0xFF3A2E00),
          tertiary: savannahGreen,
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFB8D8CA),
          onTertiaryContainer: const Color(0xFF0D261A),
          surface: sandstone,
          onSurface: charcoal,
          surfaceContainerHighest: clayLight,
          error: deepAmber,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: parchment,
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: ivory,
          elevation: 2,
          shadowColor: charcoal.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: terracotta,
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: terracotta.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.notoSerif(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: terracotta,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: terracotta, width: 2),
            textStyle: GoogleFonts.notoSerif(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: terracotta,
            textStyle: GoogleFonts.notoSerif(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ivory,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: warmGray, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: warmGray.withOpacity(0.4), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: terracotta, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: deepAmber, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: deepAmber, width: 2),
          ),
          labelStyle: GoogleFonts.notoSans(
            color: warmGray,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.notoSans(
            color: warmGray.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIconColor: warmGray,
          suffixIconColor: warmGray,
        ),
        dividerTheme: DividerThemeData(
          color: warmGray.withOpacity(0.2),
          thickness: 1,
          space: 32,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentTextStyle: GoogleFonts.notoSans(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: ivory,
          selectedItemColor: terracotta,
          unselectedItemColor: warmGray,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.notoSans(
            fontSize: 12,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: clayLight,
          selectedColor: terracotta,
          labelStyle: GoogleFonts.notoSans(
            color: charcoal,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: terracotta,
          linearTrackColor: clayLight,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  // ── Convenience Text Styles ──
  static TextStyle get headingLarge => GoogleFonts.notoSerif(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: charcoal,
        letterSpacing: 0.5,
      );

  static TextStyle get headingMedium => GoogleFonts.notoSerif(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: charcoal,
        letterSpacing: 0.3,
      );

  static TextStyle get headingSmall => GoogleFonts.notoSerif(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: charcoal,
      );

  static TextStyle get bodyLarge => GoogleFonts.notoSans(
        fontSize: 16,
        color: charcoal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSans(
        fontSize: 14,
        color: charcoal,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.notoSans(
        fontSize: 12,
        color: warmGray,
        height: 1.3,
      );
}
