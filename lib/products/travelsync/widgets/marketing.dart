import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ts_colors.dart';
import '../sample_cards.dart';
import '../travel_card.dart';
import 'app_store_button.dart';
import 'showcase_card.dart';
import 'showcase_card_back.dart';

// ─── Features ─────────────────────────────────────────────────────────────────
class FeaturesSection extends StatelessWidget {
  final bool isWide;

  const FeaturesSection({super.key, required this.isWide});

  static const _features = [
    _Feature(
      icon: Icons.style_rounded,
      title: 'Collectible trip cards',
      body:
          'Every journey becomes a beautiful card — themed, numbered, and '
          'kept in your personal collection.',
    ),
    _Feature(
      icon: Icons.photo_library_rounded,
      title: 'Photo journals',
      body:
          'Fill each trip with the photos that matter and revisit them in a '
          'clean, gallery-style layout.',
    ),
    _Feature(
      icon: Icons.flight_takeoff_rounded,
      title: 'Flight routes',
      body:
          'Capture where you flew from and to — your routes are remembered '
          'right on the card.',
    ),
    _Feature(
      icon: Icons.ios_share_rounded,
      title: 'Shareable trip pages',
      body:
          'Turn any trip into a public page like this one and share it with '
          'a single link.',
    ),
    _Feature(
      icon: Icons.format_quote_rounded,
      title: 'Personal notes',
      body:
          'Add a few words to every trip — the memory behind the photo, kept '
          'right on the card.',
    ),
    _Feature(
      icon: Icons.collections_bookmark_rounded,
      title: 'Build your collection',
      body:
          'Each trip is numbered and saved — a growing collection of '
          'everywhere you’ve been.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 24),
      child: Column(
        children: [
          const _SectionHeading(
            kicker: 'WHAT YOU CAN DO',
            title: 'Your travels, beautifully kept',
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (final f in _features)
                  SizedBox(width: isWide ? 300 : double.infinity, child: f),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _Feature({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: elevatedSurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryBlue.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: primaryBlue, size: 22),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.crimsonText(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.anonymousPro(
              fontSize: 13,
              color: Colors.white60,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Passport stamps ──────────────────────────────────────────────────────────
// The stamp visuals (StampPainter, _PassportTexturePainter, the gold-on-navy
// collection card) are ported as-is from the mobile app's passport-card back
// (UI/profile/profile_screen.dart) so the site shows the exact same stamp.
class PassportSection extends StatelessWidget {
  final bool isWide;

  const PassportSection({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 24),
      child: Column(
        children: [
          const _SectionHeading(
            kicker: 'NEW IN THE APP',
            title: 'A passport for your trips',
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Your stats up front, one ink stamp per trip on the back — '
              'every journey you post earns its place in the collection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.anonymousPro(
                fontSize: isWide ? 15 : 13,
                color: Colors.white70,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 28,
            runSpacing: 28,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _LabeledCard(
                label: 'FRONT',
                child: _PassportFrontPreview(isWide: isWide),
              ),
              _LabeledCard(
                label: 'BACK',
                child: _StampCollectionPreview(isWide: isWide),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _passportGold = Color(0xFFCBAF6E);

// Same ink palette as the app's StampBadge — a different color per stamp,
// like each country used its own stamp pad.
const _inkPalette = [
  Color(0xFF9C5A4A), // faded brick red
  Color(0xFF5B7A8C), // washed-out slate blue
  Color(0xFF6E825A), // muted sage green
  Color(0xFF7C6A8C), // dusty mauve
  Color(0xFF9C8256), // aged amber/ochre
  Color(0xFF5A8484), // weathered teal
];

/// Best-effort start date pulled from freeform strings like "Apr 5–12, 2023"
/// → "Apr 5, 2023". Same helper as StampBadge._startDate.
String _stampStartDate(TravelCard card) {
  final range = card.dateRange;
  if (range.isEmpty) return card.year;
  final dash = RegExp(r'[–-]').firstMatch(range);
  if (dash == null) return range;
  var start = range.substring(0, dash.start).trim();
  final year = RegExp(r'\d{4}').firstMatch(range)?.group(0);
  if (year != null && !start.contains(year)) start = '$start, $year';
  return start.isEmpty ? card.year : start;
}

// Ported from the app's _PassportFront (profile_screen.dart), rendered at
// the same 340×510 reference size and scaled via FittedBox — the same
// pattern ShowcaseCardBack uses — so proportions match the app exactly.
// There's no signed-in user on the marketing site, so photo/username/home
// country render as loading skeletons; the stats are real numbers derived
// from the site's own sampleCards instead of being invented.
class _PassportFrontPreview extends StatelessWidget {
  final bool isWide;
  const _PassportFrontPreview({required this.isWide});

  static final int _countriesCount = sampleCards
      .map((c) => c.country)
      .toSet()
      .length;
  static final int _citiesCount = sampleCards
      .expand((c) => c.citiesVisited.isNotEmpty ? c.citiesVisited : [c.city])
      .toSet()
      .length;
  // Manually counted from sampleCards' countries (Japan/Canada/France/Italy):
  // Asia, North America, Europe.
  static const _continentsCount = 3;
  static final String _memberSinceYear = sampleCards
      .map((c) => c.year)
      .reduce((a, b) => a.compareTo(b) < 0 ? a : b);

  @override
  Widget build(BuildContext context) {
    final cardW = isWide ? 240.0 : 200.0;
    // The decorative shell (radius/border/shadow) is sized to the literal
    // card dimensions, same as the back — only the content inside is laid
    // out at the app's 340×510 reference size and scaled via FittedBox.
    // Scaling the shell itself along with the content (as before) shrank
    // its 24px corner radius down too, so it no longer matched the back.
    return SizedBox(
      width: cardW,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B2A4A), Color(0xFF0C1122)],
            ),
            border: Border.all(
              color: _passportGold.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _passportGold.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 340,
                height: 510,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _PassportTexturePainter()),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRAVELSYNC',
                                style: GoogleFonts.anonymousPro(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _passportGold,
                                  letterSpacing: 3,
                                ),
                              ),
                              Text(
                                'PASSPORT',
                                style: GoogleFonts.anonymousPro(
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 92,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A2440),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _passportGold.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _SkeletonDataField(label: 'USERNAME'),
                                        SizedBox(height: 14),
                                        _SkeletonDataField(
                                          label: 'HOME COUNTRY',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DataField(
                                      label: 'COUNTRIES',
                                      value: '$_countriesCount',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _DataField(
                                      label: 'POSTS',
                                      value: '${sampleCards.length}',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DataField(
                                      label: 'CITIES',
                                      value: '$_citiesCount',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: _DataField(
                                      label: 'DISTANCE TRAVELED',
                                      value: '24,600 km',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Expanded(
                                    child: _DataField(
                                      label: 'CONTINENTS',
                                      value: '$_continentsCount',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _DataField(
                                      label: 'MEMBER SINCE',
                                      value: _memberSinceYear,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                            height: 1,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.black.withValues(alpha: 0.18),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: const _MrzZone(name: '', userId: ''),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A passport data field: small grey caps label above, bold white value
/// below — ported from the app's _DataField.
class _DataField extends StatelessWidget {
  final String label;
  final String value;

  const _DataField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.anonymousPro(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: GoogleFonts.anonymousPro(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Same shape as _DataField (label + value) but the value is a loading
/// skeleton bar — used where the site has no signed-in user's data to show.
class _SkeletonDataField extends StatelessWidget {
  final String label;

  const _SkeletonDataField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.anonymousPro(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Stylized machine-readable-zone lines — ported from the app's _MrzZone.
/// With no signed-in user, [name]/[userId] are empty, which the same
/// fallback logic below already handles gracefully (reads "TRAVELER"
/// instead of a real surname); the join date always falls back too.
class _MrzZone extends StatelessWidget {
  final String name;
  final String userId;

  const _MrzZone({required this.name, required this.userId});

  static const _lineLen = 44;
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  @override
  Widget build(BuildContext context) {
    final upperName = name.toUpperCase();
    final surname = upperName.replaceAll(RegExp(r'[^A-Z ]'), '').trim();
    final parts = surname.split(' ').where((p) => p.isNotEmpty).toList();
    final last = parts.isNotEmpty ? parts.last : 'TRAVELER';
    final first = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('<')
        : '';
    final line1 = 'P<<TSY<<$last<<<<$first'
        .padRight(_lineLen, '<')
        .substring(0, _lineLen);

    final rand = math.Random(userId.hashCode);
    final pseudoId = (userId.hashCode.abs() % 999999).toString().padLeft(
      6,
      '0',
    );
    final joined = DateTime(2024, 1, 1);
    final joinDigits =
        '${(joined.year % 100).toString().padLeft(2, '0')}'
        '${joined.month.toString().padLeft(2, '0')}'
        '${joined.day.toString().padLeft(2, '0')}';
    final prefix = '$pseudoId$joinDigits';
    final buffer = StringBuffer(prefix);
    var i = prefix.length;
    while (i < _lineLen) {
      buffer.write(_chars[rand.nextInt(_chars.length)]);
      i++;
      for (var k = 0; k < 3 && i < _lineLen; k++, i++) {
        buffer.write('<');
      }
    }
    final line2 = buffer.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _JustifiedMrzLine(text: line1),
        const SizedBox(height: 6),
        _JustifiedMrzLine(text: line2),
      ],
    );
  }
}

/// An MRZ line stretched to fill the full available width — ported from the
/// app's _JustifiedMrzLine.
class _JustifiedMrzLine extends StatelessWidget {
  final String text;

  const _JustifiedMrzLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.anonymousPro(
      fontSize: 10,
      color: _passportGold.withValues(alpha: 0.85),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
        final extra = text.isEmpty
            ? 0.0
            : (constraints.maxWidth - tp.width) / text.length;
        return Text(
          text,
          style: style.copyWith(letterSpacing: extra.clamp(0.0, 3.0)),
        );
      },
    );
  }
}

// Mirrors StampCollection's container: gradient navy card, gold border, and
// a passport-paper texture, holding a handful of tilted ink stamps.
// Same 2:3 aspect ratio and width the other showcased trip cards on this
// page use (see ThemeShowcase's cardW), so this reads as "a regular card"
// alongside them instead of a wide banner.
class _StampCollectionPreview extends StatelessWidget {
  final bool isWide;
  const _StampCollectionPreview({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cardW = isWide ? 240.0 : 200.0;
    return SizedBox(
      width: cardW,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B2A4A), Color(0xFF0C1122)],
            ),
            border: Border.all(
              color: _passportGold.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _PassportTexturePainter()),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header mirrors StampCollection's exactly: identity on
                      // the left, "STAMP COLLECTION" label on the right. No
                      // signed-in user on the marketing site, so the identity
                      // side renders as a loading skeleton instead of real data.
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _SkeletonHeaderIdentity(),
                          Spacer(),
                          _StampCollectionLabel(),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(child: _ScatteredSampleStamps()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StampCollectionLabel extends StatelessWidget {
  const _StampCollectionLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'STAMP\nCOLLECTION',
      textAlign: TextAlign.right,
      style: GoogleFonts.anonymousPro(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: _passportGold,
        letterSpacing: 1.6,
        height: 1.3,
      ),
    );
  }
}

// Same shape/position as the app's _StampHeaderIdentity (34px circular
// avatar + name, gold border) but with no signed-in user to show on the
// marketing site, so it renders as a static loading skeleton. The name bar
// is a fixed, short width rather than Expanded so it doesn't run into the
// "STAMP COLLECTION" label.
class _SkeletonHeaderIdentity extends StatelessWidget {
  const _SkeletonHeaderIdentity();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A2440),
            border: Border.all(color: _passportGold.withValues(alpha: 0.3)),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// One trip's worth of stamp data. A real user racks up many more stamps than
// the site has sample trips for, so this preview repeats sampleCards (with
// distinct ids, so each copy still gets its own seeded position/tilt/ink)
// until the card actually looks full, the way a well-used passport does.
class _StampData {
  final String id;
  final String city;
  final String country;
  final String date;

  const _StampData({
    required this.id,
    required this.city,
    required this.country,
    required this.date,
  });
}

// Ported from the app's _ScatteredStamps/_ScatteredStamp: stamps land in a
// stable, seeded "random" order and position instead of a neat grid. Unlike
// the app (which only animates a freshly-earned stamp), every stamp here
// plays that same press-in entrance, staggered by index, so the whole
// collection appears to get stamped onto the page one at a time.
class _ScatteredSampleStamps extends StatelessWidget {
  const _ScatteredSampleStamps();

  List<_StampData> get _shuffled {
    final list = [
      for (var round = 0; round < 2; round++)
        for (final c in sampleCards)
          _StampData(
            id: round == 0 ? c.id : '${c.id}-$round',
            city: c.city,
            country: c.country,
            date: _stampStartDate(c),
          ),
    ];
    list.sort(
      (a, b) =>
          (a.id.hashCode ^ 0x5bd1e995).compareTo(b.id.hashCode ^ 0x5bd1e995),
    );
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final stamps = _shuffled;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scaled down from the app's 104 to fit this card-sized preview
        // (the app's passport back fills a whole phone screen).
        const size = 74.0;
        // One cell per stamp, sized to spread them across the whole card —
        // not to the stamp size — so every corner gets covered instead of
        // leaving big gaps that pure-random placement left behind. Cells
        // end up smaller than the stamp itself, so neighbors still overlap.
        final n = stamps.length;
        final cols = math.max(1, math.sqrt(n).ceil());
        final rows = math.max(1, (n / cols).ceil());
        final order = List.generate(cols * rows, (i) => i)
          ..shuffle(math.Random(1));
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < stamps.length; i++)
              _ScatteredStamp(
                stamp: stamps[i],
                areaWidth: constraints.maxWidth,
                areaHeight: constraints.maxHeight,
                slot: order[i],
                cols: cols,
                rows: rows,
                size: size,
                delay: Duration(milliseconds: i * 130),
              ),
          ],
        );
      },
    );
  }
}

class _ScatteredStamp extends StatefulWidget {
  final _StampData stamp;
  final double areaWidth;
  final double areaHeight;
  final int slot;
  final int cols;
  final int rows;
  final double size;
  final Duration delay;

  const _ScatteredStamp({
    required this.stamp,
    required this.areaWidth,
    required this.areaHeight,
    required this.slot,
    required this.cols,
    required this.rows,
    required this.size,
    required this.delay,
  });

  // Same seeded tilt as the app's _ScatteredStamp._restTiltFor.
  static double _restTiltFor(_StampData stamp) {
    final tiltRand = math.Random(stamp.id.hashCode ^ 0x5DEECE66D);
    return (tiltRand.nextDouble() - 0.5) * 1.4;
  }

  @override
  State<_ScatteredStamp> createState() => _ScatteredStampState();
}

// Plays the same "stamp landing" entrance the app uses for a freshly-earned
// stamp (profile_screen.dart's _ScatteredStampState) — it thumps down,
// straightening out of a hard tilt while scaling and fading up to its
// resting position, so it reads as a stamp being pressed onto the page.
class _ScatteredStampState extends State<_ScatteredStamp>
    with SingleTickerProviderStateMixin {
  static const _impact = 0.35;

  late final AnimationController _controller;
  late final Animation<double> _inkCurve;
  late final Animation<double> _inkOpacity;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _inkCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_impact, 1.0, curve: Curves.elasticOut),
    );
    _inkOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        _impact - 0.03,
        _impact + 0.1,
        curve: Curves.easeOut,
      ),
    );
    _startTimer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stamp = widget.stamp;
    final size = widget.size;
    final seed = stamp.id.hashCode;
    final rand = math.Random(seed);
    final maxX = math.max(0.0, widget.areaWidth - size);
    final maxY = math.max(0.0, widget.areaHeight - size);
    final cellW = widget.areaWidth / widget.cols;
    final cellH = widget.areaHeight / widget.rows;
    final col = widget.slot % widget.cols;
    final row = widget.slot ~/ widget.cols;
    // Jitter up to a full cell around its center — cells are smaller than
    // the stamp, so this still lets neighboring stamps overlap.
    final cx = (col + 0.5) * cellW + (rand.nextDouble() - 0.5) * cellW;
    final cy = (row + 0.5) * cellH + (rand.nextDouble() - 0.5) * cellH;
    final left = (cx - size / 2).clamp(0.0, maxX);
    final top = (cy - size / 2).clamp(0.0, maxY);

    final badge = Transform.rotate(
      angle: _ScatteredStamp._restTiltFor(stamp),
      child: CustomPaint(
        painter: StampPainter(
          city: stamp.city.toUpperCase(),
          country: stamp.country.toUpperCase(),
          date: stamp.date,
          seed: seed,
          ink: _inkPalette[seed.abs() % _inkPalette.length],
        ),
      ),
    );

    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _inkCurve.value;
          return Opacity(
            opacity: _inkOpacity.value.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: (1 - t) * -0.6,
              child: Transform.scale(scale: 0.5 + t * 0.5, child: child),
            ),
          );
        },
        child: badge,
      ),
    );
  }
}

/// Fine crosshatch lines + faint guilloche rings, like security printing on a
/// passport page — ported from _PassportTexturePainter.
class _PassportTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hatch = Paint()
      ..color = _passportGold.withValues(alpha: 0.035)
      ..strokeWidth = 0.6;
    const spacing = 10.0;
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        hatch,
      );
      canvas.drawLine(
        Offset(x + size.height, 0),
        Offset(x, size.height),
        hatch,
      );
    }

    final ring = Paint()
      ..color = _passportGold.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    for (final r in [40.0, 70.0, 100.0, 130.0, 160.0]) {
      canvas.drawCircle(center, r, ring);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Round ink-stamp badge: city curves along the top rim, the trip's start
/// date sits in the center, and the country curves along the bottom rim —
/// ported verbatim from the mobile app's StampPainter.
class StampPainter extends CustomPainter {
  final String city;
  final String country;
  final String date;
  final int seed;
  final Color ink;

  StampPainter({
    required this.city,
    required this.country,
    required this.date,
    required this.seed,
    required this.ink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final rand = math.Random(seed * 991 + 7);

    // Worn double ring — skips little arcs at random so it looks pressed by
    // hand rather than machine-perfect.
    _drawWornRing(canvas, center, radius, rand, alpha: 0.75);
    _drawWornRing(canvas, center, radius - 5, rand, alpha: 0.5);

    _drawArcText(
      canvas,
      city,
      center,
      radius: radius - 12,
      baseAngle: -math.pi / 2,
      clockwise: true,
    );
    _drawArcText(
      canvas,
      country,
      center,
      radius: radius - 12,
      baseAngle: math.pi / 2,
      clockwise: false,
    );

    // Start date, centered, with a thin rule under it like a postmark date line.
    final dateStyle = GoogleFonts.anonymousPro(
      fontSize: radius * 0.2,
      fontWeight: FontWeight.bold,
      color: ink.withValues(alpha: 0.85),
      letterSpacing: 0.4,
    );
    final tp = TextPainter(
      text: TextSpan(text: date, style: dateStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: radius * 1.5);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    _drawStar(
      canvas,
      center - Offset(0, tp.height / 2 + radius * 0.16),
      radius * 0.08,
    );
    canvas.drawLine(
      center + Offset(-radius * 0.42, radius * 0.28),
      center + Offset(radius * 0.42, radius * 0.28),
      Paint()
        ..color = ink.withValues(alpha: 0.4)
        ..strokeWidth = 0.8,
    );
  }

  /// Small 5-point star, like the one stamped above a date on a real visa/
  /// postmark stamp.
  void _drawStar(Canvas canvas, Offset center, double size) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? size : size * 0.42;
      final a = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + r * math.cos(a),
        center.dy + r * math.sin(a),
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = ink.withValues(alpha: 0.85));
  }

  void _drawWornRing(
    Canvas canvas,
    Offset center,
    double radius,
    math.Random rand, {
    required double alpha,
  }) {
    final paint = Paint()
      ..color = ink.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const stepDeg = 4.0;
    for (var deg = 0.0; deg < 360; deg += stepDeg) {
      if (rand.nextDouble() < 0.08) continue; // gap: worn/faded ink
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        deg * math.pi / 180,
        stepDeg * math.pi / 180,
        false,
        paint,
      );
    }
  }

  /// Draws [text] curved along a circle of [radius] centered at [center].
  /// [clockwise] true curves it over the top rim (letters upright, outward);
  /// false curves it under the bottom rim (letters upright, inward) so both
  /// read normally to the viewer, as on a real circular stamp.
  void _drawArcText(
    Canvas canvas,
    String text,
    Offset center, {
    required double radius,
    required double baseAngle,
    required bool clockwise,
  }) {
    if (text.isEmpty || text.length == 1) return;
    const maxSpan = 2.6; // radians (~150°)
    final fontSize =
        radius * (text.length <= 8 ? 0.34 : 0.34 * 8 / text.length);
    final anglePerChar = math.min(0.34, maxSpan / (text.length - 1));
    final totalSpan = anglePerChar * (text.length - 1);
    final style = GoogleFonts.anonymousPro(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: ink.withValues(alpha: 0.85),
      letterSpacing: 0.5,
    );

    for (var i = 0; i < text.length; i++) {
      final offset = -totalSpan / 2 + anglePerChar * i;
      final angle = clockwise ? baseAngle + offset : baseAngle - offset;
      final pos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(text: text[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(clockwise ? angle + math.pi / 2 : angle - math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant StampPainter oldDelegate) =>
      oldDelegate.city != city ||
      oldDelegate.country != country ||
      oldDelegate.date != date ||
      oldDelegate.ink != ink;
}

// ─── Theme showcase ─────────────────────────────────────────────────────────
class ThemeShowcase extends StatelessWidget {
  final bool isWide;

  const ThemeShowcase({super.key, required this.isWide});

  // Mirrors the mobile app's card themes (models/card_theme.dart).
  static const _themes = <_ThemeSwatch>[
    _ThemeSwatch('Night', [
      Color(0xFF243B6E),
      Color(0xFF0F2460),
      Color(0xFF060D1F),
    ], Color(0xFF4B76FA)),
    _ThemeSwatch('Sunset', [
      Color(0xFF6B2D4E),
      Color(0xFF3A1060),
      Color(0xFF1A0A2E),
    ], Color(0xFFE8614A)),
    _ThemeSwatch('Forest', [
      Color(0xFF1A3A2A),
      Color(0xFF0D2618),
      Color(0xFF060F0A),
    ], Color(0xFF3DBF7E)),
    _ThemeSwatch('Ocean', [
      Color(0xFF0E3A4A),
      Color(0xFF072535),
      Color(0xFF030F18),
    ], Color(0xFF2AB8D0)),
    _ThemeSwatch('Desert', [
      Color(0xFF3A2510),
      Color(0xFF221408),
      Color(0xFF100A02),
    ], Color(0xFFD4874A)),
    _ThemeSwatch('Mono', [
      Color(0xFF2A2A2A),
      Color(0xFF141414),
      Color(0xFF050505),
    ], Color(0xFFCCCCCC)),
  ];

  @override
  Widget build(BuildContext context) {
    // Use a night-themed sample so the front matches the (blue) back design.
    final sample = sampleCards.firstWhere(
      (c) => c.theme == 'night',
      orElse: () => sampleCards.first,
    );
    final cardW = isWide ? 240.0 : 200.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 24),
      child: Column(
        children: [
          const _SectionHeading(
            kicker: 'MAKE IT YOURS',
            title: 'Two sides to every trip',
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'A cover worth framing on the front — your route, map, stats and '
              'a personal note on the back.',
              textAlign: TextAlign.center,
              style: GoogleFonts.anonymousPro(
                fontSize: isWide ? 15 : 13,
                color: Colors.white70,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 36),
          // Front + back of a real card
          Wrap(
            spacing: 28,
            runSpacing: 28,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _LabeledCard(
                label: 'FRONT',
                child: ShowcaseCard(card: sample, width: cardW),
              ),
              _LabeledCard(
                label: 'BACK',
                child: ShowcaseCardBack(card: sample, width: cardW),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text(
            'SIX THEMES TO STYLE IT',
            style: GoogleFonts.anonymousPro(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: [for (final t in _themes) _ThemeCard(swatch: t)],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.anonymousPro(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _ThemeSwatch {
  final String name;
  final List<Color> colors;
  final Color accent;

  const _ThemeSwatch(this.name, this.colors, this.accent);
}

class _ThemeCard extends StatelessWidget {
  final _ThemeSwatch swatch;

  const _ThemeCard({required this.swatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: swatch.colors,
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: swatch.accent.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRAVELSYNC',
                  style: GoogleFonts.anonymousPro(
                    fontSize: 7,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '#01',
                  style: GoogleFonts.anonymousPro(
                    fontSize: 7,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: swatch.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              swatch.name,
              style: GoogleFonts.crimsonText(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Download CTA ─────────────────────────────────────────────────────────────
class DownloadCta extends StatelessWidget {
  final bool isWide;

  const DownloadCta({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 48 : 24, 48, isWide ? 48 : 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 28,
              vertical: isWide ? 48 : 36,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradTop, gradMid, gradBot],
                stops: [0.0, 0.55, 1.0],
              ),
              border: Border.all(color: primaryBlue.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.18),
                  blurRadius: 50,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Start your collection',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.crimsonText(
                    fontSize: isWide ? 40 : 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Download TravelSync and turn every trip into something '
                  'worth keeping.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.anonymousPro(
                    fontSize: isWide ? 15 : 13,
                    color: Colors.white70,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 28),
                const AppStoreButton(large: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared heading ─────────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  final String kicker;
  final String title;

  const _SectionHeading({required this.kicker, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          kicker,
          style: GoogleFonts.anonymousPro(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.crimsonText(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
