import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlexColorTheme {
  // Beautiful gaming-inspired themes
  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: Color(0xFF6B46C1), // Deep purple
      primaryContainer: Color(0xFFE9D5FF), // Light purple
      secondary: Color(0xFF3B82F6), // Bright blue
      secondaryContainer: Color(0xFFDBEAFE), // Light blue
      tertiary: Color(0xFFFFD700), // Gold
      tertiaryContainer: Color(0xFFFFF7B6), // Light gold
      surface: Color(0xFFFCFCFC),
      surfaceVariant: Color(0xFFF5F5F7),
      background: Color(0xFFFFFBFE),
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onPrimaryContainer: Color(0xFF3C1361),
      onSecondary: Colors.white,
      onSecondaryContainer: Color(0xFF1E3A8A),
      onTertiary: Color(0xFF3C1361),
      onTertiaryContainer: Color(0xFF3C1361),
      onSurface: Color(0xFF1D1B20),
      onSurfaceVariant: Color(0xFF49454F),
      onBackground: Color(0xFF1D1B20),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: Color(0xFF9333EA), // Bright purple for dark mode
      primaryContainer: Color(0xFF4C1D95), // Dark purple
      secondary: Color(0xFF60A5FA), // Bright blue
      secondaryContainer: Color(0xFF1E40AF), // Dark blue
      tertiary: Color(0xFFFFD700), // Gold
      tertiaryContainer: Color(0xFFFAAF00), // Darker gold
      surface: Color(0xFF131316),
      surfaceVariant: Color(0xFF1F1F23),
      background: Color(0xFF0F0F11),
      error: Color(0xFFFF6B6B),
      onPrimary: Colors.white,
      onPrimaryContainer: Color(0xFFE9D5FF),
      onSecondary: Colors.white,
      onSecondaryContainer: Color(0xFFDBEAFE),
      onTertiary: Color(0xFF3C1361),
      onTertiaryContainer: Color(0xFF3C1361),
      onSurface: Color(0xFFE6E1E5),
      onSurfaceVariant: Color(0xFFCAC4D0),
      onBackground: Color(0xFFE6E1E5),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Gaming-inspired color constants
  static const Color gamingPurple = Color(0xFF6B46C1);
  static const Color gamingGold = Color(0xFFFFD700);
  static const Color gamingBlue = Color(0xFF3B82F6);
  static const Color gamingSuccess = Color(0xFF10B981);
  static const Color gamingError = Color(0xFFDC2626);
}
