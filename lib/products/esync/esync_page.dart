// THESIS: /esync is the app's own faceplate — lit LED ladders on black glass —
// ported from esync/lib/theme.dart and ui.dart, so a visitor who opens the app
// recognizes it. Every figure on the page is sample data and says so.
// OWN-WORLD: glass #05080B, volt #2EE6FF, Saira readouts, 22px modules with a
// bezel, ladders that catch segment by segment in the app's expo-out ease.
// STORY: what a charge costs, what is due next, who to ask — one tour of the
// app's five tabs, driven by the visitor.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_icon.dart';
import '../../app/motion.dart';
import '../../app/site_shell.dart';
import '../../data/products.dart';
import 'es_colors.dart';
import 'led.dart';

/// ESYNC is on TestFlight, not the App Store — so the page asks for a build
/// rather than pointing at a listing that does not exist.
final _betaMailto = Uri(
  scheme: 'mailto',
  path: 'joshalanis28@gmail.com',
  queryParameters: const {'subject': 'ESYNC TestFlight access'},
);

class _Tab {
  final String id, label, blurb;
  final IconData icon;
  const _Tab(this.id, this.label, this.blurb, this.icon);
}

const _tabs = [
  _Tab(
    'charges',
    'Charges',
    'Every session, and what it cost.',
    Icons.bar_chart_rounded,
  ),
  _Tab(
    'service',
    'Service',
    'Wipers, filters, tires: never missed.',
    Icons.build_rounded,
  ),
  _Tab('boards', 'Boards', 'Owner talk, one tap away.', Icons.forum_rounded),
  _Tab(
    'garage',
    'Garage',
    'Your car, and the next one.',
    Icons.directions_car_rounded,
  ),
];

class ESyncPage extends StatefulWidget {
  /// `/esync/charges` etc. open the tour on that tab and scroll to it.
  final String? initialSection;
  const ESyncPage({super.key, this.initialSection});

  @override
  State<ESyncPage> createState() => _ESyncPageState();
}

class _ESyncPageState extends State<ESyncPage> {
  final _tourKey = GlobalKey();
  late int _tab = _tabs
      .indexWhere((t) => t.id == widget.initialSection)
      .clamp(0, 4);

  @override
  void initState() {
    super.initState();
    if (widget.initialSection != null) scrollToSection(_tourKey);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return SiteShell(
      ground: ESColors.glass,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                wide ? 0 : 20,
                wide ? 40 : 24,
                wide ? 0 : 20,
                80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hero(wide: wide),
                  const SizedBox(height: 72),
                  KeyedSubtree(
                    key: _tourKey,
                    child: FadeSlideIn(
                      child: _Tour(
                        wide: wide,
                        tab: _tab,
                        onTab: (i) => setState(() => _tab = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),
                  const FadeSlideIn(child: _Close()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- hero

class _Hero extends StatelessWidget {
  final bool wide;
  const _Hero({required this.wide});

  @override
  Widget build(BuildContext context) {
    final product = productForRoute('/esync')!;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon(product: product, size: 44, shadow: true),
            const SizedBox(width: 14),
            Text('ESYNC', style: esRead(26, weight: 500, glow: true)),
            const SizedBox(width: 12),
            const _PowerChip('TestFlight'),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Know what every\ncharge costs.',
          style: esText(wide ? 52 : 36, weight: FontWeight.w700, height: 1.08),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'One hub for owning an EV: cost per station, a service list that '
            'tells you what is due, and the owners to ask. Built for a Tesla '
            'first.',
            style: esText(16, color: ESColors.ink2, height: 1.5),
          ),
        ),
        const SizedBox(height: 28),
        const _VoltButton(),
        const SizedBox(height: 14),
        Text(
          'Figures on this page are sample data.',
          style: esText(12, color: ESColors.ink2),
        ),
      ],
    );
    final today = const _Module(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: _TodayPanel(compact: true),
      ),
    );
    return FadeSlideIn(
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: copy),
                const SizedBox(width: 56),
                Expanded(flex: 10, child: today),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 36), today],
            ),
    );
  }
}

/// The app's chip: a status that powers on with a flicker, not a fade.
class _PowerChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PowerChip(this.label, {this.color = ESColors.amber});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (_, t, child) {
        // The mockup's `power` keyframes: on, flicker, steady.
        const stops = [0.0, 1.0, 0.2, 1.0, 0.5, 1.0];
        const at = [0.0, 0.15, 0.30, 0.45, 0.60, 1.0];
        var o = 1.0;
        for (var i = 1; i < at.length; i++) {
          if (t <= at[i]) {
            o = stops[i - 1];
            break;
          }
        }
        return Opacity(opacity: t >= 1 ? 1 : o, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: .08),
          border: Border.all(color: color),
        ),
        child: Text(
          label.toUpperCase(),
          style: esText(
            11,
            color: color,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1),
        ),
      ),
    );
  }
}

class _VoltButton extends StatelessWidget {
  const _VoltButton();

  @override
  Widget build(BuildContext context) {
    return Hover(
      onTap: () => launchUrl(_betaMailto),
      builder: (context, hovered) => Semantics(
        button: true,
        label: 'Ask for an ESYNC TestFlight build by email',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: ESColors.volt,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: ESColors.volt.withValues(alpha: hovered ? .55 : .25),
                blurRadius: hovered ? 28 : 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 18,
                color: ESColors.onVolt,
              ),
              const SizedBox(width: 10),
              Text(
                'Ask for a TestFlight build',
                style: esText(
                  15,
                  color: ESColors.onVolt,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app's 22px module: a gradient panel with a bezel, no shadow.
class _Module extends StatelessWidget {
  final Widget child;
  const _Module({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ESColors.panelA, ESColors.panelB],
        ),
        border: Border.all(color: ESColors.bezel, width: .5),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------- tour

class _Tour extends StatelessWidget {
  final bool wide;
  final int tab;
  final ValueChanged<int> onTab;
  const _Tour({required this.wide, required this.tab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final nav = wide
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                _TabButton(tab: _tabs[i], on: i == tab, onTap: () => onTab(i)),
                if (i < _tabs.length - 1) const SizedBox(height: 6),
              ],
            ],
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++) ...[
                  _TabChip(tab: _tabs[i], on: i == tab, onTap: () => onTab(i)),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          );
    final panel = _Module(
      child: Padding(
        padding: EdgeInsets.all(wide ? 28 : 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 340),
          // The panel lights up when you reach it, and again on each tab —
          // the ladder fills are the page's one repeated motion.
          child: WhenVisible(
            builder: (context, visible) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: esEase,
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, .04),
                    end: Offset.zero,
                  ).animate(a),
                  child: child,
                ),
              ),
              layoutBuilder: (cur, prev) => Stack(
                alignment: Alignment.topLeft,
                children: [...prev, ?cur],
              ),
              child: visible
                  ? KeyedSubtree(
                      key: ValueKey(tab),
                      child: _panelFor(_tabs[tab].id),
                    )
                  : const SizedBox(
                      key: ValueKey('idle'),
                      width: double.infinity,
                    ),
            ),
          ),
        ),
      ),
    );
    return wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: nav),
              const SizedBox(width: 32),
              Expanded(child: panel),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [nav, const SizedBox(height: 20), panel],
          );
  }

  Widget _panelFor(String id) => switch (id) {
    'service' => const _ServicePanel(),
    'boards' => const _BoardsPanel(),
    'garage' => const _GaragePanel(),
    _ => const _ChargesPanel(),
  };
}

class _TabButton extends StatelessWidget {
  final _Tab tab;
  final bool on;
  final VoidCallback onTap;
  const _TabButton({required this.tab, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hover(
      onTap: onTap,
      builder: (context, hovered) => Semantics(
        button: true,
        selected: on,
        label: tab.label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: on
                ? ESColors.volt.withValues(alpha: .08)
                : (hovered
                      ? Colors.white.withValues(alpha: .04)
                      : Colors.transparent),
            border: Border.all(
              color: on ? ESColors.volt.withValues(alpha: .5) : ESColors.hair,
            ),
          ),
          child: Row(
            children: [
              Icon(
                tab.icon,
                size: 22,
                color: on ? ESColors.volt : ESColors.ink2,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tab.label, style: esText(17, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(tab.blurb, style: esText(13, color: ESColors.ink2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final _Tab tab;
  final bool on;
  final VoidCallback onTap;
  const _TabChip({required this.tab, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hover(
      onTap: onTap,
      builder: (context, _) => Semantics(
        button: true,
        selected: on,
        label: tab.label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: on
                ? ESColors.volt.withValues(alpha: .1)
                : Colors.transparent,
            border: Border.all(color: on ? ESColors.volt : ESColors.hair),
          ),
          child: Row(
            children: [
              Icon(
                tab.icon,
                size: 16,
                color: on ? ESColors.volt : ESColors.ink2,
              ),
              const SizedBox(width: 8),
              Text(
                tab.label,
                style: esText(
                  14,
                  color: on ? ESColors.ink : ESColors.ink2,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- panels

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: esText(
      11,
      color: ESColors.ink2,
      weight: FontWeight.w600,
    ).copyWith(letterSpacing: 1.4),
  );
}

class _Readout extends StatelessWidget {
  final String label, prefix, suffix;
  final double value;
  final int decimals;
  final double size;
  const _Readout(
    this.label,
    this.value, {
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(label),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: reduce ? value : 0, end: value),
          duration: const Duration(milliseconds: 1000),
          curve: esEase,
          builder: (_, v, _) => Text(
            '$prefix${v.toStringAsFixed(decimals)}$suffix',
            style: esRead(size, glow: size > 30),
          ),
        ),
      ],
    );
  }
}

class _Split extends StatelessWidget {
  final String label, value;
  final double frac;
  final Tone tone;
  const _Split(this.label, this.value, this.frac, this.tone);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: esText(13, color: ESColors.ink2, weight: FontWeight.w600),
          ),
          Text(value, style: esRead(17, weight: 500)),
        ],
      ),
      const SizedBox(height: 8),
      Ladder(frac, n: 30, h: 10, tone: tone),
    ],
  );
}

class _TodayPanel extends StatelessWidget {
  final bool compact;
  const _TodayPanel({this.compact = false});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _Eyebrow('Today · this month'),
          const _PowerChip('Sample', color: ESColors.go),
        ],
      ),
      const SizedBox(height: 16),
      _Readout(
        'Spent on charging',
        184.6,
        prefix: r'$',
        decimals: 2,
        size: compact ? 44 : 52,
      ),
      const SizedBox(height: 22),
      const Ladder(.62, n: 40, h: 30, peak: .86),
      const SizedBox(height: 6),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final l in ['0', r'$100', r'$200', r'$300'])
            Text(
              l,
              style: esText(11, color: ESColors.ink2, weight: FontWeight.w500),
            ),
        ],
      ),
      const SizedBox(height: 26),
      const _Split('Home', r'$114.40', .62, Tone.volt),
      const SizedBox(height: 16),
      const _Split('Supercharger', r'$70.20', .38, Tone.amber),
      const SizedBox(height: 26),
      const Row(
        children: [
          Expanded(
            child: _Readout(
              'Per mile',
              .09,
              prefix: r'$',
              decimals: 2,
              size: 22,
            ),
          ),
          Expanded(child: _Readout('Energy', 612, suffix: ' kWh', size: 22)),
          Expanded(child: _Readout('Sessions', 17, size: 22)),
        ],
      ),
    ],
  );
}

class _ChargesPanel extends StatelessWidget {
  const _ChargesPanel();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Eyebrow('Spend by month · sample'),
      SizedBox(height: 20),
      LedColumns(
        values: [.42, .55, .38, .71, .62, .9],
        labels: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
      ),
      SizedBox(height: 28),
      _Row('Home', 'Garage · 11 kWh', r'$3.80'),
      _Row('Supercharger', 'Downtown · 48 kWh', r'$17.20'),
      _Row('Supercharger', 'Highway 5 · 36 kWh', r'$14.10'),
    ],
  );
}

class _Row extends StatelessWidget {
  final String title, sub, value;
  const _Row(this.title, this.sub, this.value);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: ESColors.hair)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: esText(16, weight: FontWeight.w600)),
              Text(sub, style: esText(13, color: ESColors.ink2)),
            ],
          ),
        ),
        Text(value, style: esRead(20, weight: 500)),
      ],
    ),
  );
}

class _ServicePanel extends StatelessWidget {
  const _ServicePanel();

  static const _items = [
    ('Tire rotation', 'Due in 400 mi', .92, Tone.red, 'Overdue soon'),
    ('Cabin filter', 'Due in 2,100 mi', .64, Tone.amber, 'Due soon'),
    ('Wiper blades', 'Replaced in March', .22, Tone.go, 'OK'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow('Wear items · sample'),
      const SizedBox(height: 20),
      for (final it in _items) ...[
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.$1, style: esText(17, weight: FontWeight.w600)),
                  Text(it.$2, style: esText(13, color: ESColors.ink2)),
                ],
              ),
            ),
            _PowerChip(it.$5, color: it.$4.bright),
          ],
        ),
        const SizedBox(height: 12),
        Ladder(it.$3, n: 34, h: 12, tone: it.$4),
        const SizedBox(height: 26),
      ],
      Text(
        'Marked done on the phone; due by miles, by date, or both.',
        style: esText(13, color: ESColors.ink2),
      ),
    ],
  );
}

class _BoardsPanel extends StatelessWidget {
  const _BoardsPanel();

  static const _boards = [
    (
      'Winter range',
      'What the cold really does to a pack',
      Icons.ac_unit_rounded,
    ),
    (
      'Home charging',
      'Wall connectors, tariffs, installers',
      Icons.home_rounded,
    ),
    ('Road trips', 'Superchargers worth the detour', Icons.alt_route_rounded),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow('Topic boards · sample'),
      const SizedBox(height: 16),
      for (var i = 0; i < _boards.length; i++)
        // Each board slides in behind the last — a list assembling, not
        // appearing whole.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 500 + i * 120),
          curve: esEase,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(24 * (1 - t), 0),
              child: child,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: .05),
              border: Border.all(color: ESColors.hair),
            ),
            child: Row(
              children: [
                Icon(_boards[i].$3, color: ESColors.volt, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _boards[i].$1,
                        style: esText(16, weight: FontWeight.w600),
                      ),
                      Text(
                        _boards[i].$2,
                        style: esText(13, color: ESColors.ink2),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: ESColors.ink2),
              ],
            ),
          ),
        ),
    ],
  );
}

class _GaragePanel extends StatelessWidget {
  const _GaragePanel();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Eyebrow('Garage · sample'),
      SizedBox(height: 16),
      Text(
        'Model 3',
        style: TextStyle(
          color: ESColors.ink,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: 4),
      _Eyebrow('Long Range · 2023'),
      SizedBox(height: 28),
      _Eyebrow('Battery'),
      SizedBox(height: 10),
      Ladder(.78, n: 40, h: 30, tone: Tone.go),
      SizedBox(height: 24),
      Row(
        children: [
          Expanded(child: _Readout('Odometer', 18420, suffix: ' mi')),
          Expanded(child: _Readout('Range', 241, suffix: ' mi')),
        ],
      ),
      SizedBox(height: 22),
      Text(
        'Trips, battery health and auto-logged charging arrive with the Tesla connection.',
        style: TextStyle(color: ESColors.ink2, fontSize: 13, height: 1.4),
      ),
    ],
  );
}

class _Close extends StatelessWidget {
  const _Close();

  @override
  Widget build(BuildContext context) => _Module(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 20,
        spacing: 24,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Money first.',
                  style: esText(28, weight: FontWeight.w700, height: 1.15),
                ),
                const SizedBox(height: 8),
                Text(
                  'ESYNC is in TestFlight while the Tesla connection is built. '
                  'Ask for a build and tell me what you charge.',
                  style: esText(15, color: ESColors.ink2, height: 1.5),
                ),
              ],
            ),
          ),
          const _VoltButton(),
        ],
      ),
    ),
  );
}
