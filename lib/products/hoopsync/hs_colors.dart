import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HoopSync's "night game" palette, mirrored from hoopsync's
/// `lib/app/theme/tokens.dart` (Hs).
class HSColors {
  HSColors._();

  static const ink = Color(0xFF09090B);
  static const night = Color(0xFF121214);
  static const surface = Color(0xFF18181B);
  static const border = Color(0xFF3F3F46);
  static const text = Color(0xFFF4F4F5);
  static const mute = Color(0xFFA1A1AA);
  static const hot = Color(0xFFFF6A1F);
  static const ember = Color(0xFFFF3D5A);
  static const gold = Color(0xFFFFC53D);
  static const heat = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A2E), ember],
  );
}

TextStyle hsDisplay(double size, {Color color = HSColors.text}) =>
    GoogleFonts.bigShouldersDisplay(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      height: 1,
    );

TextStyle hsBody(
  double size, {
  Color color = HSColors.mute,
  FontWeight weight = FontWeight.w400,
}) => GoogleFonts.hankenGrotesk(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: 1.5,
);
