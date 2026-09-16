import 'package:flutter/material.dart';

/// NoteSync's own palette, mirrored from the app's `AppColors.dark` — true
/// iOS system-grouped colours, not the old bespoke navy/green theme. The app
/// also ships a light theme now; this page stays on dark to match the rest
/// of the studio's chrome.
class NSColors {
  NSColors._();

  static const ground = Color(0xFF000000);
  static const surface = Color(0xFF1C1C1E);
  static const elevated = Color(0xFF2C2C2E);
  static const ink = Color(0xFFF2F2F7);
  static const inkMuted = Color(0xFF8E8E93);
  // Apple's dark separator: #545458 at 60%.
  static const border = Color(0x99545458);
  static const accent = Color(0xFF0A84FF);

  /// The pad's horizontal rules — faint enough to write over.
  static const rule = Color(0x1FFFFFFF);
}

/// No custom family — the app itself sets no `fontFamily` now, so the
/// platform's own face carries the UI (SF Pro on iOS). Here that means the
/// system stack, not a hand-picked one.
const nsFont = '.SF Pro Text';
const nsFallback = ['-apple-system', 'Helvetica Neue', 'Arial', 'sans-serif'];

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
