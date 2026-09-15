import 'package:flutter/material.dart';

/// Card theme palettes, mirrored from the mobile app (models/card_theme.dart).
class CardThemeData {
  final List<Color> gradientColors;
  final Color accent;

  const CardThemeData({required this.gradientColors, required this.accent});
}

const Map<String, CardThemeData> cardThemes = {
  'night': CardThemeData(
    gradientColors: [Color(0xFF243B6E), Color(0xFF0F2460), Color(0xFF060D1F)],
    accent: Color(0xFF4B76FA),
  ),
  'sunset': CardThemeData(
    gradientColors: [Color(0xFF6B2D4E), Color(0xFF3A1060), Color(0xFF1A0A2E)],
    accent: Color(0xFFE8614A),
  ),
  'forest': CardThemeData(
    gradientColors: [Color(0xFF1A3A2A), Color(0xFF0D2618), Color(0xFF060F0A)],
    accent: Color(0xFF3DBF7E),
  ),
  'ocean': CardThemeData(
    gradientColors: [Color(0xFF0E3A4A), Color(0xFF072535), Color(0xFF030F18)],
    accent: Color(0xFF2AB8D0),
  ),
  'desert': CardThemeData(
    gradientColors: [Color(0xFF3A2510), Color(0xFF221408), Color(0xFF100A02)],
    accent: Color(0xFFD4874A),
  ),
  'mono': CardThemeData(
    gradientColors: [Color(0xFF2A2A2A), Color(0xFF141414), Color(0xFF050505)],
    accent: Color(0xFFCCCCCC),
  ),
};

const List<double> cardGradientStops = [0.0, 0.55, 1.0];

CardThemeData themeFor(String name) => cardThemes[name] ?? cardThemes['night']!;
