import 'package:flutter/material.dart';

/// WorkIt's own palette, mirrored 1:1 from the app's `WorkItColors.dark()`
/// (workit/lib/theme.dart) — a calibrated-instrument register, not a
/// fitness-marketing gradient. The plate colors are reserved for real
/// readouts here too, exactly as the app reserves them for data.
class WIColors {
  WIColors._();

  static const ground = Color(0xFF0B0C0E);
  static const surface = Color(0xFF1B1C1F);
  static const surfaceAlt = Color(0xFF232428);
  static const ink = Color(0xFFEDEDF0);
  static const inkMuted = Color(0xFFAFB1B8);
  static const inkFaint = Color(0xFF7D7F87);
  static const rule = Color(0xFF2E3035);
  static const tint = Color(0xFF4A9DFF);
  static const plate25 = Color(0xFFE84A3E); // red
  static const plate20 = Color(0xFF4A8DE0); // blue
  static const plate15 = Color(0xFFF0C441); // gold
  static const plate10 = Color(0xFF43C57C); // green
}

/// System/SF-native stack, matching the app's own reliance on Cupertino's
/// default text rendering rather than an imported display face.
const wiFontFallback = ['-apple-system', 'SF Pro Text', 'Segoe UI', 'Roboto'];

TextStyle wiText(
  double size, {
  Color color = WIColors.ink,
  FontWeight weight = FontWeight.w400,
  double height = 1.2,
  double letterSpacing = 0,
  bool tabularFigures = false,
}) => TextStyle(
  fontFamilyFallback: wiFontFallback,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
  fontFeatures: tabularFigures ? const [FontFeature.tabularFigures()] : null,
);
