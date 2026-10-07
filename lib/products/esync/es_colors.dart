import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ESYNC's own palette, mirrored from the app's `theme.dart` (the
/// "illuminated amplifier faceplate": lit instruments on black glass).
class ESColors {
  ESColors._();

  static const glass = Color(0xFF05080B);
  static const panelA = Color(0xFF121A21);
  static const panelB = Color(0xFF090D11);
  static const ink = Color(0xFFE9F1F5);
  static const ink2 = Color(0xFF8FA2AE);
  static const hair = Color(0x14FFFFFF);
  static const bezel = Color(0x24FFFFFF);
  static const volt = Color(0xFF2EE6FF);
  static const voltDim = Color(0xFF0F8FBF);
  static const amber = Color(0xFFFFB02E);
  static const over = Color(0xFFFF5D3A);
  static const go = Color(0xFF3BE59A);
  static const onVolt = Color(0xFF00151A);
}

/// The app's expo-out ease.
const esEase = Cubic(0.16, 1, 0.3, 1);

/// Saira readout: light, tabular, used for figures only — the app's own rule.
TextStyle esRead(
  double size, {
  double weight = 300,
  Color color = ESColors.ink,
  bool glow = false,
}) => GoogleFonts.saira(
  fontSize: size,
  color: color,
  height: 1,
  letterSpacing: 0.01 * size,
  fontWeight: FontWeight.values[((weight / 100).round().clamp(1, 9)) - 1],
  fontFeatures: const [FontFeature.tabularFigures()],
  shadows: glow
      ? [Shadow(color: ESColors.volt.withValues(alpha: .55), blurRadius: 16)]
      : null,
);

TextStyle esText(
  double size, {
  Color color = ESColors.ink,
  FontWeight weight = FontWeight.w400,
  double height = 1.4,
}) => GoogleFonts.hankenGrotesk(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
);
