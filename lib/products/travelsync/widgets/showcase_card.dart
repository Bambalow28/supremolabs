import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../card_themes.dart';
import '../travel_card.dart';
import 'grid_painter.dart';

/// A collectible 2:3 trip card, mirroring the mobile app's CardFront —
/// themed gradient, TRAVELSYNC header, cover photo, and city/country/year.
class ShowcaseCard extends StatelessWidget {
  final TravelCard card;
  final double width;
  // 0..1 sweep position for the shine glint. Null = no shine.
  final double? shinePhase;
  final double aspectRatio;

  const ShowcaseCard({
    super.key,
    required this.card,
    this.width = 220,
    this.shinePhase,
    this.aspectRatio = 2 / 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = themeFor(card.theme);
    final radius = BorderRadius.circular(18);
    final hasImage = card.cardImageUrl != null && card.cardImageUrl!.isNotEmpty;

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        // Fixed reference size + FittedBox, matching ShowcaseCardBack, so the
        // border/shadow scale down with the card instead of staying a fixed
        // size and making the front look bigger than the back at small widths.
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 340,
            height: 510,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.gradientColors,
                  stops: cardGradientStops,
                ),
                border: Border.all(
                  color: theme.accent.withValues(alpha: 0.28),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: theme.accent.withValues(alpha: 0.18),
                    blurRadius: 40,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TRAVELSYNC',
                                style: GoogleFonts.anonymousPro(
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                '#${card.cardNumber.toString().padLeft(2, '0')}',
                                style: GoogleFonts.anonymousPro(
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Image area
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (!hasImage)
                                CustomPaint(painter: GridPainter())
                              else
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.white,
                                        ],
                                        stops: [0.0, 0.12],
                                      ).createShader(bounds),
                                  blendMode: BlendMode.dstIn,
                                  child: Image.network(
                                    card.cardImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        CustomPaint(painter: GridPainter()),
                                  ),
                                ),
                              // Bottom scrim
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.55),
                                      Colors.black.withValues(alpha: 0.88),
                                    ],
                                    stops: const [0.35, 0.65, 1.0],
                                  ),
                                ),
                              ),
                              // City / country / year
                              Positioned(
                                bottom: 14,
                                left: 14,
                                right: 14,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      card.city,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.crimsonText(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.05,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            card.country,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.anonymousPro(
                                              fontSize: 11,
                                              color: theme.accent,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          card.year,
                                          style: GoogleFonts.anonymousPro(
                                            fontSize: 11,
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (shinePhase != null)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: _CardShine(phase: shinePhase!),
                        ),
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

/// A soft diagonal glint that sweeps across the card as [phase] goes 0→1.
class _CardShine extends StatelessWidget {
  final double phase;

  const _CardShine({required this.phase});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        // Travel from off the left edge to off the right edge.
        final x = phase * (w * 1.6) - w * 0.3;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: x,
              top: -h * 0.25,
              bottom: -h * 0.25,
              child: Transform.rotate(
                angle: 0.32,
                child: Container(
                  width: w * 0.26,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Color(0x1FFFFFFF), // ~12% white peak — subtle
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
