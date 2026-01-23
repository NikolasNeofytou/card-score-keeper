// lib/ui/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

/// Professional Theme System for Card Score Keeper
/// Following modern design principles and accessibility standards
class AppTheme {
  static ThemeData get lightTheme => _buildTheme(_lightColorScheme, false);
  static ThemeData get darkTheme => _buildTheme(_darkColorScheme, true);

  // Modern Light ColorScheme - Gaming-optimized
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    brightness: Brightness.light,
    primary: DesignTokens.primaryPurple,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFEDE9FE),
    onPrimaryContainer: DesignTokens.gray900,
    secondary: DesignTokens.electricBlue,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDBEAFE),
    onSecondaryContainer: DesignTokens.gray900,
    tertiary: DesignTokens.emeraldGreen,
    onTertiary: Colors.white,
    tertiaryContainer: DesignTokens.successBackground,
    onTertiaryContainer: DesignTokens.gray900,
    error: DesignTokens.errorPrimary,
    onError: Colors.white,
    errorContainer: DesignTokens.errorBackground,
    onErrorContainer: DesignTokens.crimsonRed,
    surface: Colors.white,
    onSurface: DesignTokens.gray900,
    onSurfaceVariant: DesignTokens.gray600,
    background: DesignTokens.gray50,
    onBackground: DesignTokens.gray900,
    outline: DesignTokens.gray300,
    outlineVariant: DesignTokens.gray200,
    surfaceVariant: DesignTokens.gray100,
  );

  // Modern Dark ColorScheme - Gaming-optimized for extended sessions
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: Color(0xFF818CF8), // Lighter indigo for dark mode
    onPrimary: DesignTokens.gray900,
    primaryContainer: Color(0xFF4338CA),
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: Color(0xFF60A5FA), // Lighter blue
    onSecondary: DesignTokens.gray900,
    secondaryContainer: Color(0xFF1E3A8A),
    onSecondaryContainer: Color(0xFFDBEAFE),
    tertiary: Color(0xFF34D399), // Lighter emerald
    onTertiary: DesignTokens.gray900,
    tertiaryContainer: Color(0xFF047857),
    onTertiaryContainer: Color(0xFFD1FAE5),
    error: Color(0xFFF87171), // Lighter red
    onError: DesignTokens.gray900,
    errorContainer: Color(0xFFDC2626),
    onErrorContainer: Color(0xFFFECACA),
    surface: DesignTokens.darkSurface,
    onSurface: DesignTokens.darkTextPrimary,
    onSurfaceVariant: DesignTokens.darkTextSecondary,
    background: DesignTokens.darkBackground,
    onBackground: DesignTokens.darkTextPrimary,
    outline: DesignTokens.darkBorder,
    outlineVariant: DesignTokens.darkDivider,
    surfaceVariant: DesignTokens.darkSurfaceVariant,
  );

  static ThemeData _buildTheme(ColorScheme colorScheme, bool isDark) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Professional Typography - Gaming focused
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Display styles - For big scores and headers
        displayLarge: GoogleFonts.jetBrainsMono(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.jetBrainsMono(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
          letterSpacing: -0.25,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colorScheme.onBackground,
          letterSpacing: -0.25,
        ),

        // Headlines - For section titles
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
          letterSpacing: -0.25,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.15,
        ),

        // Titles - For cards and components
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.1,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          letterSpacing: 0.1,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.1,
        ),

        // Body text
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colorScheme.onBackground,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.4,
        ),

        // Labels and buttons
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),

      // Modern App Bar - Clean and minimal
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: DesignTokens.space20,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
          letterSpacing: -0.15,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ),

      // Modern Cards - Subtle and elegant
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          side: BorderSide(
            color: colorScheme.outline,
            width: 0.5,
          ),
        ),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),

      // Modern Buttons - Gaming-inspired
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Modern Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          side: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
          foregroundColor: colorScheme.onSurface,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Modern Input Fields - Clean and focused
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? DesignTokens.darkSurfaceVariant : DesignTokens.gray100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // FAB - Gaming style
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: DesignTokens.elevationMedium,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
      ),

      // Modern Dialogs
      dialogTheme: DialogThemeData(
        elevation: DesignTokens.elevationLarge,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.5)
            : Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.15,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.25,
        ),
      ),

      // Snackbar theme for notifications
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? DesignTokens.darkSurfaceHighlight : DesignTokens.gray800,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: DesignTokens.elevationMedium,
      ),

      // List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 0.5,
        space: 1,
      ),

      // Chip theme for tags and filters
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? DesignTokens.darkSurfaceVariant : DesignTokens.gray200,
        disabledColor: colorScheme.onSurface.withOpacity(0.12),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        shadowColor: Colors.transparent,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
