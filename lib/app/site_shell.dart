// The studio chrome every route sits inside.
//
// Per DESIGN.md the chrome carries the current page's own color: the product's
// accent on a product route, the studio's core signal everywhere else. The
// vertical trunk rail that used to run down every page went out with the
// transit world — the hub's web is the map now, and a scroll-progress line
// beside it was chrome asserting a metaphor the page no longer holds.
//
// The footer is just the mark and build number; the web lives in the header.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/products.dart';
import '../theme/sl_theme.dart';
import 'motion.dart';

const slMaxContentWidth = 1120.0;

const _build = String.fromEnvironment('BUILD', defaultValue: '0');
final slVersion = '1.0.$_build';

/// Scrolls [key]'s widget into view — used by product pages to resolve a
/// nested route (e.g. `/travelsync/features`) to a station further down
/// their single scrolling page.
void scrollToSection(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  });
}

/// Centered, max-width column — the single measure every section aligns to.
class SLPage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double maxWidth;
  const SLPage({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = slMaxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}

/// A single hairline with generous space around it — the page's structural
/// divider, tinted [color].
class SLRule extends StatelessWidget {
  final Color color;
  final double maxWidth;
  const SLRule({
    super.key,
    this.color = SLColors.hairline,
    this.maxWidth = slMaxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SLPage(
      maxWidth: maxWidth,
      child: Divider(color: color, height: 1, thickness: 1),
    );
  }
}

/// The current route's color — a product's own accent on its route, the
/// studio's own signal everywhere else (hub, about).
Color currentLineColor(BuildContext context) {
  final route = ModalRoute.of(context)?.settings.name;
  return lineInk(productForPath(route)?.accent ?? SLColors.accent);
}

class SiteShell extends StatefulWidget {
  /// Body sections, between nav and footer.
  final List<Widget> children;

  /// Ground behind the body. Defaults to the studio ground; product pages
  /// pass their own.
  final Color? ground;

  /// Right-side nav slot on non-home routes, in place of the ABOUT link
  /// (which only shows on the root page). Null leaves that slot empty.
  final Widget? trailing;

  /// Measure of the nav, rule and footer. A wide desk page passes its own
  /// width so the chrome's edges line up with its content's.
  final double maxWidth;

  const SiteShell({
    super.key,
    required this.children,
    this.ground,
    this.trailing,
    this.maxWidth = slMaxContentWidth,
  });

  @override
  State<SiteShell> createState() => _SiteShellState();
}

class _SiteShellState extends State<SiteShell> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyGround = widget.ground ?? SLColors.ground;
    final line = currentLineColor(context);
    return Scaffold(
      backgroundColor: bodyGround,
      // Nav scrolls away with the rest of the page — not a fixed bar — and
      // stays transparent so the route's own ground shows through.
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _Nav(trailing: widget.trailing, maxWidth: widget.maxWidth),
            ),
            SLRule(color: line, maxWidth: widget.maxWidth),
            ...widget.children,
            _LinerNotes(maxWidth: widget.maxWidth),
            Container(
              color: bodyGround,
              width: double.infinity,
              child: _Footer(line: line, maxWidth: widget.maxWidth),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final Widget? trailing;
  final double maxWidth;
  const _Nav({this.trailing, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    final atHome = route == '/';
    final product = productForPath(route);
    final accent = lineInk(product?.accent ?? SLColors.accent);

    return SLPage(
      maxWidth: maxWidth,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Hover(
                // Replaces the stack rather than pushing another home onto
                // it — the wordmark is "go home", not "go deeper".
                onTap: atHome ? null : () => context.go('/'),
                builder: (context, hovered) => Text(
                  'SUPREMO LABS',
                  style: SLType.eyebrow(hovered ? accent : SLColors.ink),
                ),
              ),
              if (product != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '/',
                    style: SLType.eyebrow(accent.withValues(alpha: 0.5)),
                  ),
                ),
                Text(product.name.toUpperCase(), style: SLType.eyebrow(accent)),
              ],
            ],
          ),
          // ABOUT only lives on the root page — product routes get their own
          // trailing slot (e.g. TravelSync's search) in its place.
          if (atHome)
            Hover(
              onTap: () => context.push('/about'),
              builder: (context, hovered) => Text(
                'ABOUT',
                style: SLType.eyebrow(
                  hovered ? SLColors.ink : SLColors.inkMuted,
                ),
              ),
            )
          else
            ?trailing,
        ],
      ),
    );
  }
}

/// The web, restated. Every reachable product as a node in its own color,
/// with the one you're standing on lit — so the end of a page is a junction,
/// not a dead end.
class _Footer extends StatelessWidget {
  final Color line;
  final double maxWidth;
  const _Footer({required this.line, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return SLPage(
      maxWidth: maxWidth,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: line, height: 1, thickness: 1),
          const SizedBox(height: 24),
          // The header already says where you are; the footer is just the
          // mark and which build this is (CI run number; 0 locally).
          Center(
            child: Text(
              '© SUPREMO LABS · $slVersion',
              style: SLType.eyebrow(SLColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// The problem a product answers and the founder's line about it, set as
/// liner notes above the footer on every product page. Skipped on back-office
/// desks, the FamFi console and legal pages — they are not the product's pitch.
class _LinerNotes extends StatelessWidget {
  final double maxWidth;
  const _LinerNotes({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    final product = productForPath(route);
    final story = product?.story;
    if (story == null ||
        route == null ||
        route.endsWith('/desk') ||
        route.endsWith('/personal') ||
        route.endsWith('/privacy') ||
        route.endsWith('/terms')) {
      return const SizedBox.shrink();
    }
    final line = lineInk(product!.accent ?? SLColors.accent);
    return SLPage(
      maxWidth: maxWidth,
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 8),
      child: LayoutBuilder(
        builder: (context, cons) {
          final wide = cons.maxWidth >= 760;
          Widget block(String label, Widget body, int i) => FadeSlideIn(
            index: i,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PulseDot(color: line, size: 6),
                    const SizedBox(width: 10),
                    Text(label.toUpperCase(), style: SLType.eyebrow(line)),
                  ],
                ),
                const SizedBox(height: 16),
                body,
              ],
            ),
          );
          final problem = block(
            'The problem',
            Text(story.problem, style: SLType.body(wide ? 20 : 18)),
            0,
          );
          final mine = block(
            story.mineLabel,
            Text(
              story.mine,
              style: SLType.display(wide ? 40 : 32).copyWith(height: 1.05),
            ),
            1,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: SLColors.hairline, height: 1),
              const SizedBox(height: 40),
              Text('LINER NOTES', style: SLType.label(SLColors.inkMuted)),
              const SizedBox(height: 28),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: problem),
                    const SizedBox(width: 64),
                    Expanded(flex: 6, child: mine),
                  ],
                )
              else ...[
                problem,
                const SizedBox(height: 36),
                mine,
              ],
              const SizedBox(height: 56),
            ],
          );
        },
      ),
    );
  }
}
