import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../sample_cards.dart';
import '../travel_card.dart';
import 'showcase_card.dart';

/// A dramatic, gently floating fan of sample trip cards for the top of the
/// landing page. Cards are rotated and offset like a hand of cards; the center
/// card sits highest and on top.
class HeroCardFan extends StatefulWidget {
  final bool isWide;

  const HeroCardFan({super.key, required this.isWide});

  @override
  State<HeroCardFan> createState() => _HeroCardFanState();
}

class _HeroCardFanState extends State<HeroCardFan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  // Fixed design canvas — scaled to fit via FittedBox.
  static const _canvasW = 660.0;
  static const _canvasH = 412.0;
  static const _cardW = 210.0;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = sampleCards;
    final n = cards.length;
    final center = (n - 1) / 2.0;

    // Paint order: outermost first so the center card lands on top.
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) => (b - center).abs().compareTo((a - center).abs()));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _canvasW),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedBuilder(
          animation: _bob,
          builder: (context, _) {
            final t = _bob.value * 2 * math.pi;
            return SizedBox(
              width: _canvasW,
              height: _canvasH,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  for (final i in order) _positioned(cards[i], i, center, t),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _positioned(TravelCard card, int i, double center, double t) {
    final offset = i - center; // …-1.5, -0.5, 0.5, 1.5…
    final angle = offset * 0.12; // radians (~7°)
    final dx = offset * 104.0;
    // Raise the whole fan a touch so it sits more centered (outer cards are
    // pushed down by their |offset|, which otherwise makes it bottom-heavy).
    final dy = offset.abs() * 24.0 - 16.0;
    final scale = 1 - offset.abs() * 0.05;
    // Subtle per-card vertical bob, phase-shifted along the fan.
    final bob = math.sin(t + i * 0.9) * 7.0;
    // Shine glint sweeps on the same clock, offset per card so they don't
    // all sparkle at once.
    final shinePhase = (_bob.value + i * 0.37) % 1.0;

    return Transform.translate(
      offset: Offset(dx, dy + bob),
      child: Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: scale,
          child: ShowcaseCard(
            card: card,
            width: _cardW,
            shinePhase: shinePhase,
          ),
        ),
      ),
    );
  }
}
