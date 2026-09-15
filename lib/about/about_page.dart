// THESIS: the core of the web, named — a single founder, not a team page.
// OWN-WORLD: the hub's world (graphite ground, the studio's amber signal,
// Space Grotesk/IBM Plex Sans), with each principle carrying the same node
// marker the web and the lineup use rather than a bullet.
// STORY: a visitor understands one person builds and stands behind every
// product in the lineup. FIRST VIEWPORT: the headline stating that plainly,
// then the principles as stops. No photo, no team grid — kept deliberately
// generic per brief. FORM: extends the hub's established world; no new
// direction roll.
import 'package:flutter/material.dart';

import '../app/motion.dart';
import '../app/site_shell.dart';
import '../theme/sl_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteShell(children: [_AboutHero(), SLRule(), _Principles()]);
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final headlineSize = width < 640 ? 36.0 : 56.0;
    return SLPage(
      padding: EdgeInsets.fromLTRB(24, width < 640 ? 48 : 96, 24, 64),
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Keeps the section at full measure; without it the Column
            // shrink-wraps and the enclosing Center pushes it inward.
            const SizedBox(width: double.infinity),
            Text(
              'One person.\nOne studio.',
              style: SLType.display(headlineSize),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                'Supremo Labs is built by a single founder who would rather '
                'ship one considered product than ten unfinished ones. Every '
                'app in the lineup passes through the same hands and the same '
                'standard before it goes out.',
                style: SLType.body(17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Principles extends StatelessWidget {
  const _Principles();

  static const _items = [
    (
      'Coherence over breadth',
      'One studio\'s taste across every product, not nine unrelated experiments.',
    ),
    (
      'Built end to end',
      'Design, code, and ship — one person accountable for every product in the web.',
    ),
    (
      'Quality over speed',
      'A product ships when it is ready, not when a deadline says so.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SLPage(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: double.infinity),
          for (var i = 0; i < _items.length; i++)
            FadeSlideIn(
              index: i,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: i == _items.length - 1 ? 0 : 34,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The studio's own node, at text scale — the same marker
                    // the hub's web and lineup use, so a principle reads as
                    // part of the same system rather than a list item.
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(top: 8, right: 18),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: SLColors.accent,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_items[i].$1, style: SLType.display(20)),
                          const SizedBox(height: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Text(_items[i].$2, style: SLType.body(15)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
