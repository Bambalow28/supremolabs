import 'package:flutter/material.dart';

/// NoteSync's own palette, mirrored from the app's dark `AppColors`.
class NSColors {
  NSColors._();

  static const ground = Color(0xFF0B0F1A);
  static const surface = Color(0xFF131A2E);
  static const elevated = Color(0xFF1A2440);
  static const ink = Colors.white;
  static const inkMuted = Color(0xFF94A0B8);
  static const border = Color(0x1FFFFFFF);
  static const accent = Color(0xFF4CAF55);

  /// The pad's horizontal rules — faint enough to write over.
  static const rule = Color(0x12FFFFFF);
}

/// The app is set in one family, deliberately — matches noteSyncTheme()'s
/// `fontFamily: 'Helvetica'`. Size and weight carry the whole hierarchy.
const nsFont = 'Helvetica';
const nsFallback = ['Helvetica Neue', 'Arial', 'sans-serif'];

TextStyle nsText(
  double size, {
  Color color = NSColors.ink,
  FontWeight weight = FontWeight.w400,
  double height = 1.2,
  double letterSpacing = 0,
}) => TextStyle(
  fontFamily: nsFont,
  fontFamilyFallback: nsFallback,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);
