import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HundredFold's own palette, mirrored from the game's theme.dart: matte near-black with a fluorescent-tube green,
/// LED red for the clock and danger, amber for pay, carbon-copy paper only on forms.
class HFColors {
  HFColors._();
  static const ground = Color(0xFF050806);
  static const floor = Color(0xFF0B100D);
  static const panel = Color(0xFF121914);
  static const rule = Color(0xFF26332A);
  static const ink = Color(0xFFE2EBDB);
  static const dim = Color(0xFF8A9889);
  static const red = Color(0xFFFF4630);
  static const amber = Color(0xFFFFB020);
  static const tube = Color(0xFF86E898);
  static const paper = Color(0xFFE8E3D2);
  static const paperInk = Color(0xFF1B1A16);
}

TextStyle hfDisplay(double size, {Color color = HFColors.ink}) =>
    GoogleFonts.bigShouldersDisplay(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: color,
      height: .92,
      letterSpacing: size * .015,
    );

TextStyle hfBody(
  double size, {
  Color color = HFColors.dim,
  FontWeight weight = FontWeight.w400,
  double height = 1.55,
}) => GoogleFonts.hankenGrotesk(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

TextStyle hfLabel({Color color = HFColors.dim}) => GoogleFonts.hankenGrotesk(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: color,
  letterSpacing: 2.2,
);
