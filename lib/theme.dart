import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Old-money palette — see DESIGN.md. Restrained: ground + ink + one brass accent.
class SLColors {
  static const ground = Color(0xFF15130F);
  static const surface = Color(0xFF1D1A15);
  static const hairline = Color(0xFF3A362C);
  static const divider = Color(0xFF2A271F);
  static const ink = Color(0xFFEDE7DA);
  static const inkMuted = Color(0xFFA8A08C);
  static const brass = Color(0xFFB08D57);
  static const brassHover = Color(0xFFC7A66E);
}

class SLType {
  static TextStyle display(double size, {FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: SLColors.ink, height: 1.05);

  static TextStyle displayItalic(double size) => display(size).copyWith(fontStyle: FontStyle.italic);

  static TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? SLColors.inkMuted, height: 1.5);

  static TextStyle eyebrow(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 2.2,
      );
}

ThemeData slTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SLColors.ground,
    colorScheme: const ColorScheme.dark(
      surface: SLColors.ground,
      primary: SLColors.brass,
    ),
    dividerColor: SLColors.divider,
    textTheme: TextTheme(bodyMedium: SLType.body(16)),
  );
}
