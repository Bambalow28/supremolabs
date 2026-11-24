import 'package:flutter/material.dart';

/// The six hunters, copied from the game's lib/monsters.dart (12 x 16 pixel art; letters h dark, f face, g body, e eyes, m mouth).
class HfMonster {
  const HfMonster(
    this.name,
    this.haunts,
    this.trait,
    this.art,
    this.pal,
    this.headRows,
  );
  final String name, haunts, trait;
  final List<String> art;
  final Map<String, Color> pal;
  final int headRows;
}

const hfMonsters = [
  HfMonster(
    'Ghost',
    'Hotels · Apartments · Schools',
    'Balanced. Drifts through the dark and hears more than you think.',
    [
      '...hhhhhh...',
      '..hhhhhhhh..',
      '.hhffffffhh.',
      '.hhfeffefhh.',
      '.hhffffffhh.',
      '.hhffmmffhh.',
      '.hhhffffhhh.',
      'hhhhgggghhhh',
      'hhhgggggghhh',
      'hh.gggggg.hh',
      'hh.gggggg.hh',
      'h.gggggggg.h',
      '..gggggggg..',
      '.gggggggggg.',
      '.g.gg.gg.gg.',
      '..g..gg..g..',
    ],
    {
      'h': Color(0xFF0B0D12),
      'f': Color(0xFFD3DEE8),
      'g': Color(0xFFE3ECF3),
      'm': Color(0xFF220606),
      'e': Color(0xFF000000),
    },
    8,
  ),
  HfMonster(
    'Stalker',
    'Offices · Civic buildings',
    'Slow, but sees from across the floor.',
    [
      '....hhhh....',
      '...hffffh...',
      '...hffffh...',
      '...hfeefh...',
      '...hffffh...',
      '...hfmmfh...',
      '....hffh....',
      '..gggffggg..',
      '.ggggffgggg.',
      '.gg.gffg.gg.',
      '.gg.gggg.gg.',
      '.gg.gggg.gg.',
      '.ff.gggg.ff.',
      '.ff.g..g.ff.',
      '.ff.g..g.ff.',
      '....g..g....',
    ],
    {
      'h': Color(0xFF0A0A0C),
      'f': Color(0xFFCFCABD),
      'g': Color(0xFF16161C),
      'm': Color(0xFF220606),
      'e': Color(0xFF000000),
    },
    8,
  ),
  HfMonster(
    'Crawler',
    'Tunnels · Kitchens',
    'Fast, but nearly blind. Your noise is how it finds you.',
    [
      '............',
      '............',
      '............',
      '....hhhh....',
      '..hhhhhhhh..',
      '.hhffffffhh.',
      '.hfeffffefh.',
      '.hffmmmmffh.',
      'h.hhffffhh.h',
      '.h.gggggg.h.',
      'h.gggggggg.h',
      'h.gggggggg.h',
      '.h.gggggg.h.',
      'h..g.gg.g..h',
      'h..g....g..h',
      'hh........hh',
    ],
    {
      'h': Color(0xFF14100A),
      'f': Color(0xFF8A7A5A),
      'g': Color(0xFF3A2E1C),
      'm': Color(0xFF2A0808),
      'e': Color(0xFF000000),
    },
    9,
  ),
  HfMonster(
    'Grinner',
    'Stores · Theatres',
    'Quick on its feet. Never stops smiling.',
    [
      '.hh......hh.',
      'hhhh.hh.hhhh',
      '.hhhhhhhhhh.',
      '..hffffffh..',
      '..hfeffefh..',
      '..hffffffh..',
      '..hmmmmmmh..',
      '..hfmffmfh..',
      '...hffffh...',
      '..gggggggg..',
      '.gggggggggg.',
      'ffggggggggff',
      'ff.gggggg.ff',
      '...gggggg...',
      '...gg..gg...',
      '..hhh..hhh..',
    ],
    {
      'h': Color(0xFFB02A3A),
      'f': Color(0xFFF2EEE6),
      'g': Color(0xFF2A5AA8),
      'm': Color(0xFFD01830),
      'e': Color(0xFF000000),
    },
    9,
  ),
  HfMonster(
    'Patient',
    'Hospitals',
    'Gaunt and relentless. Faster than it looks.',
    [
      '..hhhhhhhh..',
      '.hhhhhhhhhh.',
      '.hhfffffhhh.',
      '.hhfeffefhh.',
      '.hhffffffhh.',
      '..hffmmffh..',
      '..hhffffhh..',
      '...gggggg...',
      '..gggggggg..',
      '.fgggggggg.f',
      'ffggggggggff',
      'ff.gggggg.ff',
      'f..gggggg..f',
      '...gggggg...',
      '...ff..ff...',
      '...ff..ff...',
    ],
    {
      'h': Color(0xFF16120E),
      'f': Color(0xFF9CB8A0),
      'g': Color(0xFFB8D0DC),
      'm': Color(0xFF1E0808),
      'e': Color(0xFF000000),
    },
    8,
  ),
  HfMonster(
    'Machine',
    'Warehouses · Plant rooms',
    'Slow and deaf to quiet, but hears every noise on the floor.',
    [
      '.....hh.....',
      '.....hh.....',
      '..hhhhhhhh..',
      '.hffffffffh.',
      '.hfeeffeefh.',
      '.hffffffffh.',
      '.hfmmmmmmfh.',
      '..hhhhhhhh..',
      '.hggggggggh.',
      'hhgggggggghh',
      'hhgggggggghh',
      'hh.gggggg.hh',
      'hh.gggggg.hh',
      '...gg..gg...',
      '..hhh..hhh..',
      '..hhh..hhh..',
    ],
    {
      'h': Color(0xFF1A1C1E),
      'f': Color(0xFF6E7478),
      'g': Color(0xFF8A5A2A),
      'm': Color(0xFF0A0A0A),
      'e': Color(0xFF000000),
    },
    8,
  ),
];

/// Paints a monster's art, with its eyes lit red when [hunting].
class HfSprite extends CustomPainter {
  HfSprite(this.m, {this.hunting = false});
  final HfMonster m;
  final bool hunting;

  @override
  void paint(Canvas c, Size s) {
    final cell = s.width / 12, p = Paint();
    for (var y = 0; y < m.art.length; y++) {
      for (var x = 0; x < 12; x++) {
        final ch = m.art[y][x];
        final col = ch == 'e' && hunting ? const Color(0xFFFF4630) : m.pal[ch];
        if (col != null)
          c.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + .5, cell + .5),
            p..color = col,
          );
      }
    }
  }

  @override
  bool shouldRepaint(HfSprite o) => o.hunting != hunting || o.m != m;
}
