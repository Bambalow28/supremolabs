import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ts_colors.dart';
import '../travel_card.dart';

/// Web port of the mobile app's CardBack — compass texture, destination map,
/// flight strip, stats, visited tags, note and passport stamp. Rendered at a
/// fixed reference size and scaled to [width] so paddings never overflow.
class ShowcaseCardBack extends StatelessWidget {
  final TravelCard card;
  final double width;
  final double aspectRatio;

  const ShowcaseCardBack({
    super.key,
    required this.card,
    this.width = 210,
    this.aspectRatio = 2 / 3,
  });

  @override
  Widget build(BuildContext context) {
    final cities = card.citiesVisited.isNotEmpty
        ? card.citiesVisited
        : [card.city];

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 340,
            height: 510,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF060D1F), Color(0xFF0F2460)],
                ),
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.22),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.18),
                    blurRadius: 40,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CustomPaint(painter: _CompassPainter()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TRAVELSYNC',
                              style: GoogleFonts.anonymousPro(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'CARD #${card.cardNumber.toString().padLeft(2, '0')} · ED.1',
                              style: GoogleFonts.anonymousPro(
                                fontSize: 9,
                                color: Colors.white.withValues(alpha: 0.3),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(
                          color: primaryBlue.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _DestinationMap(
                            city: card.city,
                            country: card.country,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FlightStrip(card: card),
                        const SizedBox(height: 16),
                        _StatsBar(
                          nights: card.nights,
                          citiesCount: cities.length,
                          year: card.year,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'VISITED',
                          style: GoogleFonts.anonymousPro(
                            fontSize: 8,
                            color: Colors.white.withValues(alpha: 0.3),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _DestinationTags(cities: cities),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    10,
                                    8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.07,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.format_quote,
                                        size: 13,
                                        color: primaryBlue.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          card.personalNote.isNotEmpty
                                              ? card.personalNote
                                              : 'No note added.',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.sourceSerif4(
                                            fontSize: 10,
                                            color: Colors.white.withValues(
                                              alpha: 0.55,
                                            ),
                                            fontStyle: FontStyle.italic,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _PassportStamp(card: card),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PassportStamp extends StatelessWidget {
  final TravelCard card;

  const _PassportStamp({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryBlue.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _monthAbbr(card.dateRange),
            style: GoogleFonts.anonymousPro(
              fontSize: 9,
              color: primaryBlue.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),
          Text(
            card.year,
            style: GoogleFonts.anonymousPro(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primaryBlue.withValues(alpha: 0.8),
            ),
          ),
          Text(
            _countryCode(card.country),
            style: GoogleFonts.anonymousPro(
              fontSize: 9,
              color: primaryBlue.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(String dateRange) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    for (final m in months) {
      if (dateRange.startsWith(m)) return m.toUpperCase();
    }
    return '---';
  }

  String _countryCode(String country) {
    const codes = {
      'Canada': 'CA',
      'France': 'FR',
      'Japan': 'JP',
      'Italy': 'IT',
      'USA': 'US',
      'Indonesia': 'ID',
    };
    return codes[country] ??
        country.substring(0, math.min(2, country.length)).toUpperCase();
  }
}

class _StatsBar extends StatelessWidget {
  final int nights;
  final int citiesCount;
  final String year;

  const _StatsBar({
    required this.nights,
    required this.citiesCount,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.nights_stay_outlined,
            value: nights > 0 ? '$nights' : '—',
            label: 'NIGHTS',
          ),
          _BarDivider(),
          _StatCell(
            icon: Icons.place_outlined,
            value: '$citiesCount',
            label: 'CITIES',
          ),
          _BarDivider(),
          _StatCell(
            icon: Icons.calendar_today_outlined,
            value: year,
            label: 'YEAR',
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 12, color: primaryBlue.withValues(alpha: 0.65)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.anonymousPro(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.anonymousPro(
              fontSize: 7,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: primaryBlue.withValues(alpha: 0.15),
    );
  }
}

class _DestinationTags extends StatelessWidget {
  final List<String> cities;

  const _DestinationTags({required this.cities});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: cities
          .map(
            (city) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryBlue.withValues(alpha: 0.28)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 8,
                    color: primaryBlue.withValues(alpha: 0.65),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    city,
                    style: GoogleFonts.anonymousPro(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FlightStrip extends StatelessWidget {
  final TravelCard card;

  const _FlightStrip({required this.card});

  String _cityCode(String city) {
    final letters = city.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (letters.isEmpty) return '---';
    return letters.substring(0, math.min(3, letters.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final originCode = card.originAirport.isNotEmpty ? card.originAirport : '—';
    final destCode = card.destinationAirport.isNotEmpty
        ? card.destinationAirport
        : _cityCode(card.city);
    return Row(
      children: [
        _AirportCode(code: originCode, label: 'FROM'),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.flight,
                      size: 14,
                      color: primaryBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                card.dateRange,
                style: GoogleFonts.anonymousPro(
                  fontSize: 7,
                  color: Colors.white.withValues(alpha: 0.2),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        _AirportCode(code: destCode, label: 'TO'),
      ],
    );
  }
}

class _AirportCode extends StatelessWidget {
  final String code;
  final String label;

  const _AirportCode({required this.code, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          code,
          style: GoogleFonts.anonymousPro(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 2,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.anonymousPro(
            fontSize: 7,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryBlue.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width * 0.78, size.height * 0.28);

    for (final r in [28.0, 56.0, 84.0, 112.0]) {
      canvas.drawCircle(center, r, paint);
    }

    paint.strokeWidth = 0.8;
    canvas.drawLine(
      Offset(center.dx - 125, center.dy),
      Offset(center.dx + 125, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 125),
      Offset(center.dx, center.dy + 125),
      paint,
    );

    paint.strokeWidth = 0.6;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * 96,
          center.dy + math.sin(angle) * 96,
        ),
        Offset(
          center.dx + math.cos(angle) * 112,
          center.dy + math.sin(angle) * 112,
        ),
        paint,
      );
    }

    paint.strokeWidth = 1.2;
    paint.color = primaryBlue.withValues(alpha: 0.07);
    canvas.drawCircle(center, 6, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(center, 6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DestinationMap extends StatelessWidget {
  final String city;
  final String country;

  const _DestinationMap({required this.city, required this.country});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1124),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryBlue.withValues(alpha: 0.15)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MapPainter(seed: city.hashCode)),
            ),
            const Positioned.fill(child: Center(child: _MapPin())),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF060D1F).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place,
                      size: 10,
                      color: primaryBlue.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$city, $country',
                      style: GoogleFonts.anonymousPro(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Text(
                'N',
                style: GoogleFonts.anonymousPro(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryBlue.withValues(alpha: 0.1),
            border: Border.all(color: primaryBlue.withValues(alpha: 0.25)),
          ),
        ),
        const Icon(Icons.location_on, size: 22, color: primaryBlue),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  final int seed;

  _MapPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final r = math.Random(seed);

    final rows = 4 + r.nextInt(2);
    final cols = 5 + r.nextInt(2);
    for (var i = 1; i < rows; i++) {
      final y = size.height * (i / rows) + (r.nextDouble() - 0.5) * 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
    for (var i = 1; i < cols; i++) {
      final x = size.width * (i / cols) + (r.nextDouble() - 0.5) * 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }

    final avenue = Paint()
      ..color = primaryBlue.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(0, size.height * (0.2 + r.nextDouble() * 0.2)),
      Offset(size.width, size.height * (0.6 + r.nextDouble() * 0.2)),
      avenue,
    );

    final river = Paint()
      ..color = primaryBlue.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.55,
        size.width * 0.55,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height,
        size.width,
        size.height * 0.85,
      );
    canvas.drawPath(path, river);

    final park = Paint()
      ..color = primaryBlue.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final px = size.width * (0.1 + r.nextDouble() * 0.15);
    final py = size.height * (0.15 + r.nextDouble() * 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px, py, size.width * 0.22, size.height * 0.25),
        const Radius.circular(4),
      ),
      park,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
