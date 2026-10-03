import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Studio palette — see DESIGN.md. Cool graphite ground + white ink;
/// `accent` is the neutral "interchange" signal color used at the hub, while
/// each product carries its own "line" color (Product.accent).
class SLColors {
  static const ground = Color(0xFF0B0D10);
  static const surface = Color(0xFF13161B);
  static const hairline = Color(0xFF262B33);
  static const divider = Color(0xFF1C2026);
  static const ink = Color(0xFFF2F4F7);
  static const inkMuted = Color(0xFF8B93A1);
  static const accent = Color(0xFFFFB020);
  static const accentHover = Color(0xFFFFC04D);
}

/// A product's line color, lifted until it clears 4.5:1 against the studio
/// ground. Each accent was picked for that product's *own* surfaces —
/// a deep product accent can be legible on that product's own surfaces and not legible
/// as 12px type on near-black — so the chrome uses this, never the raw value.
Color lineInk(Color c) {
  const target = 0.20; // luminance that clears 4.5:1 against SLColors.ground
  if (c.computeLuminance() >= target) return c;
  var hsl = HSLColor.fromColor(c);
  while (hsl.lightness < 0.95 && hsl.toColor().computeLuminance() < target) {
    hsl = hsl.withLightness((hsl.lightness + 0.04).clamp(0.0, 1.0));
  }
  return hsl.toColor();
}

class SLType {
  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
  }) => GoogleFonts.bigShouldersDisplay(
    fontSize: size,
    fontWeight: weight,
    color: SLColors.ink,
    height: 1.0,
  );

  static TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.hankenGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color ?? SLColors.inkMuted,
    height: 1.5,
  );

  static TextStyle eyebrow(Color color) => GoogleFonts.hankenGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 2.2,
  );

  /// Catalog numbers and sleeve credits — tabular so SL 001 and SL 011 align.
  static TextStyle label(Color color) => eyebrow(
    color,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

ThemeData slTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SLColors.ground,
    colorScheme: const ColorScheme.dark(
      surface: SLColors.ground,
      primary: SLColors.accent,
    ),
    dividerColor: SLColors.divider,
    textTheme: TextTheme(bodyMedium: SLType.body(16)),
  );
}
