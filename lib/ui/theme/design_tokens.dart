// lib/ui/theme/design_tokens.dart
import 'package:flutter/material.dart';

/// Professional Design System for Card Score Keeper
/// Following modern design principles from Linear, Vercel, and game UI best practices
class DesignTokens {
  /// ==================== COLOR SYSTEM ====================
  /// Modern color palette optimized for gaming/scoring apps
  /// Uses perceptually uniform color spaces and accessibility standards

  // Brand Colors - Inspired by premium gaming interfaces
  static const Color primaryBlue = Color(0xFF0F172A); // Rich midnight blue
  static const Color primaryPurple = Color(0xFF6366F1); // Modern indigo
  static const Color primaryGreen = Color(0xFF10B981); // Success green
  static const Color primaryOrange = Color(0xFFF59E0B); // Warning amber
  static const Color primaryRed = Color(0xFFEF4444); // Error red

  // Neutral Grays - Carefully calibrated for readability
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // Gaming-specific accent colors with proper contrast ratios
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color emeraldGreen = Color(0xFF059669);
  static const Color goldenYellow = Color(0xFFD97706);
  static const Color crimsonRed = Color(0xFFDC2626);
  static const Color royalPurple = Color(0xFF7C3AED);
  static const Color oceanTeal = Color(0xFF0891B2);

  // Success states for gaming achievements
  static const Color successPrimary = Color(0xFF10B981);
  static const Color successSecondary = Color(0xFF6EE7B7);
  static const Color successBackground = Color(0xFFECFDF5);

  // Warning states for critical game moments
  static const Color warningPrimary = Color(0xFFF59E0B);
  static const Color warningSecondary = Color(0xFFFBBF24);
  static const Color warningBackground = Color(0xFFFFFBEB);

  // Error states for invalid moves/scores
  static const Color errorPrimary = Color(0xFFEF4444);
  static const Color errorSecondary = Color(0xFFF87171);
  static const Color errorBackground = Color(0xFFFEF2F2);

  /// ==================== DARK THEME COLORS ====================

  // Dark mode - Optimized for extended gaming sessions
  static const Color darkBackground = Color(0xFF0A0E1A); // Deep space blue
  static const Color darkSurface = Color(0xFF111827); // Elevated surface
  static const Color darkSurfaceVariant = Color(0xFF1F2937); // Cards/containers
  static const Color darkSurfaceHighlight =
      Color(0xFF374151); // Interactive elements

  // Dark text colors with optimal contrast
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);
  static const Color darkTextDisabled = Color(0xFF6B7280);

  // Dark borders and dividers
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkBorderLight = Color(0xFF4B5563);
  static const Color darkDivider = Color(0xFF1F2937);

  /// ==================== PLAYER COLORS ====================
  /// Distinctive, accessible colors for player identification
  /// Designed to work in both light and dark themes

  static const List<PlayerColorSet> playerColorSets = [
    PlayerColorSet(
      primary: Color(0xFF3B82F6), // Blue
      secondary: Color(0xFF93C5FD),
      dark: Color(0xFF1E40AF),
      background: Color(0xFFDbeafe),
      name: 'Ocean Blue',
    ),
    PlayerColorSet(
      primary: Color(0xFF10B981), // Emerald
      secondary: Color(0xFF6EE7B7),
      dark: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      name: 'Emerald Green',
    ),
    PlayerColorSet(
      primary: Color(0xFF7C3AED), // Violet
      secondary: Color(0xFFA78BFA),
      dark: Color(0xFF5B21B6),
      background: Color(0xFFE9D5FF),
      name: 'Royal Violet',
    ),
    PlayerColorSet(
      primary: Color(0xFFEF4444), // Red
      secondary: Color(0xFFF87171),
      dark: Color(0xFFDC2626),
      background: Color(0xFFFECaca),
      name: 'Crimson Red',
    ),
    PlayerColorSet(
      primary: Color(0xFFF59E0B), // Amber
      secondary: Color(0xFFFBBF24),
      dark: Color(0xFFD97706),
      background: Color(0xFFFEF3C7),
      name: 'Golden Amber',
    ),
    PlayerColorSet(
      primary: Color(0xFF8B5CF6), // Purple
      secondary: Color(0xFFA78BFA),
      dark: Color(0xFF7C2D12),
      background: Color(0xFFEDE9FE),
      name: 'Magic Purple',
    ),
    PlayerColorSet(
      primary: Color(0xFF06B6D4), // Cyan
      secondary: Color(0xFF67E8F9),
      dark: Color(0xFF0891B2),
      background: Color(0xFFCFFAFE),
      name: 'Cyan Blue',
    ),
    PlayerColorSet(
      primary: Color(0xFFEC4899), // Pink
      secondary: Color(0xFFF472B6),
      dark: Color(0xFFBE185D),
      background: Color(0xFFFCE7F3),
      name: 'Hot Pink',
    ),
  ];

  /// ==================== TROPHY COLORS ====================
  /// Luxurious metallic colors for achievements

  static const Color goldPrimary = Color(0xFFEAB308);
  static const Color goldSecondary = Color(0xFFFCD34D);
  static const Color goldBackground = Color(0xFFFEF9C3);

  static const Color silverPrimary = Color(0xFF71717A);
  static const Color silverSecondary = Color(0xFFA1A1AA);
  static const Color silverBackground = Color(0xFFF4F4F5);

  static const Color bronzePrimary = Color(0xFFEA580C);
  static const Color bronzeSecondary = Color(0xFFFB923C);
  static const Color bronzeBackground = Color(0xFFFED7AA);

  /// ==================== SPACING SYSTEM ====================
  /// Consistent spacing scale based on 4px grid

  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;

  /// ==================== BORDER RADIUS ====================

  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 100.0;

  /// ==================== ELEVATION ====================

  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 16.0;

  /// ==================== ANIMATION DURATIONS ====================

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationExtraSlow = Duration(milliseconds: 500);

  /// ==================== HELPER METHODS ====================

  static PlayerColorSet getPlayerColorSet(int index) {
    return playerColorSets[index % playerColorSets.length];
  }

  static Color getPlayerColor(int index) {
    return playerColorSets[index % playerColorSets.length].primary;
  }

  /// Check if a color meets WCAG AA contrast requirements
  static bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    final contrast = (lighter + 0.05) / (darker + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }
}

/// Model class for player color sets
class PlayerColorSet {
  final Color primary;
  final Color secondary;
  final Color dark;
  final Color background;
  final String name;

  const PlayerColorSet({
    required this.primary,
    required this.secondary,
    required this.dark,
    required this.background,
    required this.name,
  });
}
