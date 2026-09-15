import 'package:flutter/material.dart';

/// PlanSync's own palette, mirrored from the app's `lib/theme/app_theme.dart`
/// so this page reads as PlanSync rather than as a Supremo summary of it.
class PSColors {
  PSColors._();

  static const ground = Color(0xFF0A0E14);
  static const stock = Color(0xFF121821);
  static const stockHigh = Color(0xFF1A222E);
  static const stockLow = Color(0xFF0F141C);

  static const accent = Color(0xFF2DD4BF);
  static const accentAlt = Color(0xFF34D399);

  static const ink = Colors.white;
  static const inkSecondary = Color(0x8CFFFFFF);
  static const inkMuted = Color(0x59FFFFFF);
  static const warning = Color(0xFFE8614A);

  /// The teal hairline every document panel is edged with.
  static const hairline = Color(0x242DD4BF);
}
