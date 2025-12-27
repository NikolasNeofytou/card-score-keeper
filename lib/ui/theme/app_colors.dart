// lib/ui/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // GitHub-inspired Colors
  static const Color primary = Color(0xFF0969DA); // GitHub Blue
  static const Color primaryDark = Color(0xFF0550AE);
  static const Color primaryLight = Color(0xFF218BFF);
  
  static const Color secondary = Color(0xFF6E7781); // GitHub Gray
  static const Color secondaryDark = Color(0xFF57606A);
  static const Color secondaryLight = Color(0xFF8C959F);
  
  static const Color accent = Color(0xFF1F883D); // GitHub Green
  static const Color accentLight = Color(0xFF2DA44E); // Lighter green
  
  // Background Colors
  static const Color background = Color(0xFFF6F8FA); // GitHub Light Gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFEAEEF2);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2328);
  static const Color textSecondary = Color(0xFF656D76);
  static const Color textTertiary = Color(0xFF8C959F);
  
  // Status Colors
  static const Color success = Color(0xFF1A7F37); // GitHub Green
  static const Color error = Color(0xFFCF222E); // GitHub Red
  static const Color warning = Color(0xFF9A6700); // GitHub Orange
  static const Color info = Color(0xFF0969DA); // GitHub Blue
  
  // Border Colors
  static const Color border = Color(0xFFD0D7DE);
  static const Color borderLight = Color(0xFFE7ECF0);
  static const Color borderDark = Color(0xFFAFB8C1);
  
  // Simple backgrounds (no heavy gradients)
  static const Color cardBackground = surface;
  static const Color hoverBackground = Color(0xFFF3F4F6);
  static const Color activeBackground = Color(0xFFDDF4FF); // Light blue
  
  // Subtle accent backgrounds
  static const Color successBackground = Color(0xFFDCFFE4);
  static const Color errorBackground = Color(0xFFFFEBE9);
  static const Color warningBackground = Color(0xFFFFF8C5);
  
  // Trophy Colors (more subdued)
  static const Color gold = Color(0xFFF9C513);
  static const Color silver = Color(0xFF9CA3AF);
  static const Color bronze = Color(0xFFB87333);
  
  // Gradients (keeping for compatibility, but simpler)
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
  
  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
  
  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9C513), Color(0xFFFFB84D)],
  );
  
  // Player Colors - Professional palette
  static const List<Color> playerColors = [
    Color(0xFF0969DA), // Blue
    Color(0xFF1F883D), // Green
    Color(0xFF8250DF), // Purple
    Color(0xFFBF3989), // Pink
    Color(0xFFBC4C00), // Orange
    Color(0xFF6E7781), // Gray
    Color(0xFF0A3069), // Navy
    Color(0xFF6F42C1), // Violet
    Color(0xFF0550AE), // Dark Blue
    Color(0xFF116329), // Dark Green
  ];
  
  static Color getPlayerColor(int index) {
    return playerColors[index % playerColors.length];
  }
}

// Dark Theme Colors (GitHub Dark)
class AppColorsDark {
  // Primary Colors - Adjusted for dark mode
  static const Color primary = Color(0xFF58A6FF); // Lighter blue for contrast
  static const Color primaryDark = Color(0xFF1F6FEB);
  static const Color primaryLight = Color(0xFF79C0FF);
  
  static const Color secondary = Color(0xFF8B949E); // GitHub Gray Light
  static const Color secondaryDark = Color(0xFF6E7681);
  static const Color secondaryLight = Color(0xFFB1BAC4);
  
  static const Color accent = Color(0xFF3FB950); // GitHub Green Bright
  static const Color accentLight = Color(0xFF56D364);
  
  // Background Colors - Dark
  static const Color background = Color(0xFF0D1117); // GitHub Dark BG
  static const Color surface = Color(0xFF161B22); // GitHub Dark Surface
  static const Color surfaceDark = Color(0xFF21262D);
  static const Color surfaceVariant = Color(0xFF30363D);
  
  // Text Colors - Light on dark
  static const Color textPrimary = Color(0xFFC9D1D9);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  
  // Status Colors - Brighter for dark mode
  static const Color success = Color(0xFF3FB950);
  static const Color error = Color(0xFFFA7970);
  static const Color warning = Color(0xFFD29922);
  static const Color info = Color(0xFF58A6FF);
  
  // Border Colors - Subtle on dark
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0xFF21262D);
  static const Color borderDark = Color(0xFF484F58);
  
  // Backgrounds
  static const Color cardBackground = surface;
  static const Color hoverBackground = Color(0xFF21262D);
  static const Color activeBackground = Color(0xFF1C2938);
  
  // Accent backgrounds - Darker with opacity
  static const Color successBackground = Color(0xFF1B3021);
  static const Color errorBackground = Color(0xFF392028);
  static const Color warningBackground = Color(0xFF382A1D);
  
  // Trophy Colors - Adjusted for dark
  static const Color gold = Color(0xFFFFCC00);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD8032);
  
  // Gradients for dark mode
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
  
  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
  
  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, Color(0xFFFFD700)],
  );
  
  // Player Colors - Brighter for dark mode
  static const List<Color> playerColors = [
    Color(0xFF58A6FF), // Blue
    Color(0xFF3FB950), // Green
    Color(0xFFBC8CFF), // Purple
    Color(0xFFDB61A2), // Pink
    Color(0xFFFF7B72), // Coral
    Color(0xFF8B949E), // Gray
    Color(0xFF79C0FF), // Light Blue
    Color(0xFFA371F7), // Violet
    Color(0xFF388BFD), // Med Blue
    Color(0xFF56D364), // Light Green
  ];
  
  static Color getPlayerColor(int index) {
    return playerColors[index % playerColors.length];
  }
}
