import 'package:flutter/material.dart';

/// Ported from stanverse/lib/theme/stanverse_theme.dart's StanTicker — same
/// ink/paper/mono world, no new palette invented here.
class SVColors {
  SVColors._();
  static const ink = Color(0xFF0E0D10);
  static const paper = Color(0xFFF5F2EC);
  static const paperDim = Color(0xFFD8D4CA);
  static const line = Color(0x240E0D10);
  static const mono = Color(0xFF726D6A);
}

class SVWorld {
  final String name;
  final Color color;
  final String liveCount;
  const SVWorld(this.name, this.color, this.liveCount);
}

/// Mirrors stanverse's own demoArtists (stanverse_theme.dart) so the ticker
/// and world chips show real in-app names, not invented ones.
const svWorlds = <SVWorld>[
  SVWorld('BTS', Color(0xFF7C5CFF), '18.4K'),
  SVWorld('BLACKPINK', Color(0xFFFF2FA0), '15.1K'),
  SVWorld('ED SHEERAN', Color(0xFFFF9F3E), '12.7K'),
  SVWorld('OLIVIA RODRIGO', Color(0xFF9B5CFF), '9.3K'),
  SVWorld('NOVA WREN', Color(0xFFFF3E6C), '4.2K'),
  SVWorld('THE COBALT ROOM', Color(0xFF3E86FF), '1.8K'),
];
