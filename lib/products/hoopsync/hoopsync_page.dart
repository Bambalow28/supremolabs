// THESIS: /hoopsync is a scoreboard, not a sales page — what the app is in two
// lines, then the numbers that prove it is in use.
// OWN-WORLD: night-game ink, court orange gradient on figures, Big Shoulders
// Display — ported from hoopsync's tokens.dart. Counts are read live from
// HoopSync's own Firestore; a failed read shows a dash, never a made-up number.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_icon.dart';
import '../../app/motion.dart';
import '../../app/site_shell.dart';
import '../../data/products.dart';
import 'hoopsync_minis.dart';
import 'hoopsync_stats.dart';
import 'hs_colors.dart';

final _appUrl = Uri.parse('https://hoopsync.ca');
final _demoUrl = Uri.parse('https://hoopsync.ca/hoopsync-test');

class HoopSyncPage extends StatefulWidget {
  const HoopSyncPage({super.key});

  @override
  State<HoopSyncPage> createState() => _HoopSyncPageState();
}

class _HoopSyncPageState extends State<HoopSyncPage> {
  late final Future<HoopSyncStats?> _stats = loadHoopSyncStats();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final product = productForRoute('/hoopsync')!;
    return SiteShell(
      ground: HSColors.ink,
      children: [
        SLPage(
          maxWidth: 1000,
          padding: EdgeInsets.fromLTRB(20, wide ? 56 : 32, 20, 96),
          child: FutureBuilder<HoopSyncStats?>(
            future: _stats,
            builder: (context, snap) {
              final done = snap.connectionState == ConnectionState.done;
              final s = snap.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    child: _Intro(product: product, wide: wide),
                  ),
                  SizedBox(height: wide ? 72 : 48),
                  FadeSlideIn(
                    child: _Counters(
                      wide: wide,
                      loading: !done,
                      figures: [
                        ('Players', s?.players),
                        ('Teams', s?.teams),
                        ('Leagues', s?.leagues),
                        if (hoopSyncLocations.isNotEmpty)
                          ('Locations', hoopSyncLocations.length),
                      ],
                    ),
                  ),
                  if (hoopSyncLocations.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    FadeSlideIn(child: _Places(hoopSyncLocations)),
                  ],
                  SizedBox(height: wide ? 88 : 56),
                  FadeSlideIn(child: _Screens(wide: wide)),
                  const SizedBox(height: 64),
                  const FadeSlideIn(child: _Close()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  final Product product;
  final bool wide;
  const _Intro({required this.product, required this.wide});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          AppIcon(product: product, size: 48, shadow: true),
          const SizedBox(width: 14),
          Text('HOOPSYNC', style: hsDisplay(28)),
        ],
      ),
      const SizedBox(height: 32),
      Text('Built for the game.', style: hsDisplay(wide ? 96 : 56)),
      const SizedBox(height: 20),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Text(
          'A league platform for basketball: rosters and drafts, live stat '
          'tracking courtside, standings, records and a public page for '
          'every league. Built for the leagues I run.',
          style: hsBody(17),
        ),
      ),
      const SizedBox(height: 28),
      Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [_OpenButton(), _DemoLink()],
      ),
    ],
  );
}

class _DemoLink extends StatelessWidget {
  const _DemoLink();

  @override
  Widget build(BuildContext context) => Hover(
    onTap: () => launchUrl(_demoUrl, webOnlyWindowName: '_blank'),
    builder: (context, hovered) => Text(
      'See a demo league →',
      style: hsBody(15, weight: FontWeight.w700).copyWith(
        color: hovered ? HSColors.hot : Colors.white,
        decoration: TextDecoration.underline,
      ),
    ),
  );
}

class _OpenButton extends StatelessWidget {
  const _OpenButton();

  @override
  Widget build(BuildContext context) => Hover(
    onTap: () => launchUrl(_appUrl, webOnlyWindowName: '_blank'),
    builder: (context, hovered) => AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: HSColors.heat,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HSColors.hot.withValues(alpha: hovered ? .5 : .3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'OPEN HOOPSYNC',
            style: hsDisplay(
              20,
              color: HSColors.ink,
            ).copyWith(letterSpacing: 1),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.north_east_rounded, size: 20, color: HSColors.ink),
        ],
      ),
    ),
  );
}

/// Three screens recreated from the app itself — the live scoreboard, the
/// standings table and a player card — in its own night-game look.
class _Screens extends StatelessWidget {
  final bool wide;
  const _Screens({required this.wide});

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> items, {List<int>? flex}) {
      if (!wide) {
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              items[i],
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(flex: flex?[i] ?? 1, child: items[i]),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FROM THE APP',
          style: hsBody(
            12,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1.6),
        ),
        const SizedBox(height: 16),
        row(const [StatSheet(), DraftBoard()], flex: const [6, 5]),
        const SizedBox(height: 14),
        row(const [_ScoreCard(), _StandingsCard(), _PlayerCard()]),
        const SizedBox(height: 14),
        row(const [CoachLinks(), RecordBook()]),
        const SizedBox(height: 12),
        Text('Sample league data.', style: hsBody(12)),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: HSColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: HSColors.border.withValues(alpha: .6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: hsBody(
            11,
            color: HSColors.hot,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1.6),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'LIVE FROM TIP',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: HSColors.ink,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NORTHSIDE', style: hsDisplay(16, color: HSColors.mute)),
              Text('54', style: hsDisplay(34, color: HSColors.gold)),
              Text('Q3', style: hsDisplay(14, color: HSColors.hot)),
              Text('51', style: hsDisplay(34, color: HSColors.gold)),
              Text('EASTEND', style: hsDisplay(16, color: HSColors.mute)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('+3', style: hsDisplay(56, color: HSColors.gold)),
        const SizedBox(height: 6),
        Text(
          'Jordan scores from deep, 4:12 left in the third.',
          style: hsBody(14),
        ),
      ],
    ),
  );
}

class _StandingsCard extends StatelessWidget {
  const _StandingsCard();

  static const _rows = [
    ('NORTHSIDE', '7', '1', '+62'),
    ('EASTEND', '6', '2', '+38'),
    ('HARBOUR', '4', '4', '+5'),
    ('UPTOWN', '2', '6', '-41'),
  ];

  @override
  Widget build(BuildContext context) {
    TextStyle head() =>
        hsBody(11, weight: FontWeight.w700).copyWith(letterSpacing: 1.2);
    return _Panel(
      title: 'STANDINGS',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('TEAM', style: head())),
              for (final h in ['W', 'L', 'DIFF'])
                SizedBox(
                  width: h == 'DIFF' ? 52 : 32,
                  child: Text(h, textAlign: TextAlign.right, style: head()),
                ),
            ],
          ),
          for (var i = 0; i < _rows.length; i++) ...[
            const Divider(height: 18, color: Color(0xFF27272A)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _rows[i].$1,
                    style: hsDisplay(
                      20,
                      color: i == 0 ? HSColors.gold : HSColors.text,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    _rows[i].$2,
                    textAlign: TextAlign.right,
                    style: hsDisplay(20),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    _rows[i].$3,
                    textAlign: TextAlign.right,
                    style: hsDisplay(20, color: HSColors.mute),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    _rows[i].$4,
                    textAlign: TextAlign.right,
                    style: hsDisplay(
                      20,
                      color: _rows[i].$4.startsWith('-')
                          ? const Color(0xFFF87171)
                          : const Color(0xFF4ADE80),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard();

  @override
  Widget build(BuildContext context) {
    Widget stat(String v, String k) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(v, style: hsDisplay(34)),
          const SizedBox(height: 4),
          Text(
            k,
            style: hsBody(
              11,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.2),
          ),
        ],
      ),
    );
    return _Panel(
      title: 'PLAYER CARD',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: HSColors.heat,
                ),
                child: Text('23', style: hsDisplay(28, color: HSColors.ink)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('JORDAN REYES', style: hsDisplay(24)),
                  const SizedBox(height: 4),
                  Text('Northside', style: hsBody(13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              stat('24.6', 'PTS'),
              stat('6.1', 'REB'),
              stat('4.8', 'AST'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HSColors.gold.withValues(alpha: .7)),
            ),
            child: Text(
              'SEASON SCORING LEADER',
              style: hsBody(
                11,
                color: HSColors.gold,
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _Close extends StatelessWidget {
  const _Close();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 24,
    runSpacing: 16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      const _OpenButton(),
      const _DemoLink(),
      Text('hoopsync.ca', style: hsBody(14)),
    ],
  );
}

class _Counters extends StatelessWidget {
  final bool wide, loading;
  final List<(String, int?)> figures;
  const _Counters({
    required this.wide,
    required this.loading,
    required this.figures,
  });

  @override
  Widget build(BuildContext context) {
    final cols = wide ? figures.length : 2;
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (i, f) in figures.indexed)
              SizedBox(
                width: !wide && i == figures.length - 1 && figures.length.isOdd
                    ? box.maxWidth
                    : w,
                child: _Counter(label: f.$1, value: f.$2, loading: loading),
              ),
          ],
        );
      },
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int? value;
  final bool loading;
  const _Counter({
    required this.label,
    required this.value,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final style = hsDisplay(64);
    final Widget figure = loading || value == null
        ? Text(loading ? '' : '—', style: style.copyWith(color: HSColors.mute))
        : TweenAnimationBuilder<double>(
            tween: Tween(
              begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0,
              end: 1,
            ),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutExpo,
            builder: (_, t, _) => ShaderMask(
              shaderCallback: (r) => HSColors.heat.createShader(r),
              blendMode: BlendMode.srcIn,
              child: Text(
                '${(value! * t).round()}',
                style: style.copyWith(
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          );
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: HSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HSColors.border.withValues(alpha: .6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            child: Align(alignment: Alignment.centerLeft, child: figure),
          ),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: hsBody(
              12,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.6),
          ),
        ],
      ),
    );
  }
}

class _Places extends StatelessWidget {
  final List<String> places;
  const _Places(this.places);

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final p in places)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: HSColors.hot.withValues(alpha: .6)),
          ),
          child: Text(p, style: hsBody(14, color: HSColors.text)),
        ),
    ],
  );
}
