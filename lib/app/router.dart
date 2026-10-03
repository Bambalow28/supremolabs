import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../about/about_page.dart';
import 'backends.dart';
import '../data/products.dart';
import '../home/home_page.dart';
import '../products/diamo/diamo_page.dart';
import '../products/famfi/famfi_console_page.dart';
import '../products/famfi/famfi_page.dart';
import '../products/notesync/notesync_page.dart';
import '../products/plansync/desk/desk_page.dart';
import '../products/plansync/plansync_page.dart';
import '../products/stanverse/desk/stanverse_desk_page.dart';
import '../products/stanverse/stanverse_page.dart';
import '../products/travelsync/travelsync_page.dart';
import '../products/workit/desk/workit_desk_page.dart';
import '../products/workit/workit_legal_page.dart';
import '../products/workit/workit_page.dart';
import '../theme/sl_theme.dart';

/// One entry per path under supremolabs.com. Unknown paths fall back home.
/// Sub-routes under a product (e.g. `/travelsync/features`) are real
/// stations on that product's own single scrolling page, not separate pages
/// — see the `initialSection` comment on each product page.
final pages = <String, WidgetBuilder>{
  '/': (_) => const HomePage(),
  '/about': (_) => const AboutPage(),
  '/travelsync': (_) => TravelSyncPage(),
  '/travelsync/features': (_) => TravelSyncPage(initialSection: 'features'),
  '/travelsync/download': (_) => TravelSyncPage(initialSection: 'download'),
  '/plansync': (_) => const PlanSyncPage(),
  '/plansync/itinerary': (_) => const PlanSyncPage(initialSection: 'itinerary'),
  '/plansync/places': (_) => const PlanSyncPage(initialSection: 'places'),
  // Private back office — deliberately not linked from any public page.
  '/plansync/desk': (_) => const BackendGate(child: PlanSyncDeskPage()),
  '/notesync': (_) => NoteSyncPage(),
  '/notesync/folders': (_) => NoteSyncPage(initialSection: 'folders'),
  '/notesync/device': (_) => NoteSyncPage(initialSection: 'device'),
  '/workit': (_) => WorkItPage(),
  '/workit/features': (_) => WorkItPage(initialSection: 'features'),
  '/workit/screens': (_) => WorkItPage(initialSection: 'screens'),
  // Old name for the screens rail — kept so an existing link never 404s.
  '/workit/progress': (_) => WorkItPage(initialSection: 'progress'),
  '/workit/privacy': (_) => const WorkItPrivacyPage(),
  '/workit/terms': (_) => const WorkItTermsPage(),
  // Private back office — deliberately not linked from any public page.
  '/workit/desk': (_) => const BackendGate(child: WorkItDeskPage()),
  '/diamo': (_) => DiaMoPage(),
  '/diamo/diary': (_) => DiaMoPage(initialSection: 'diary'),
  '/diamo/discover': (_) => DiaMoPage(initialSection: 'discover'),
  '/stanverse': (_) => StanversePage(),
  '/stanverse/community': (_) => StanversePage(initialSection: 'community'),
  '/stanverse/marketplace': (_) => StanversePage(initialSection: 'marketplace'),
  // Private back office — deliberately not linked from any public page.
  '/stanverse/desk': (_) => const BackendGate(child: StanverseDeskPage()),
  '/famfi': (_) => const FamFiPage(),
  // The desktop console — every control the phone app has. Linked from
  // /famfi's nav and hero.
  '/famfi/personal': (_) => const BackendGate(child: FamFiConsolePage()),
};

/// Root navigator key, so a route not in [pages] can redirect to home
/// without needing a BuildContext of its own.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// `go_router`-backed so every `context.push` adds a real browser history
/// entry (the plain `Navigator.pushNamed` this replaced only rewrote the
/// current one — the back button had nothing to go back to).
final appRouter = GoRouter(
  // WealthSync became FamFi; old links land on the new page.
  redirect: (context, state) =>
      state.uri.path.startsWith('/wealthsync') ? '/famfi' : null,
  navigatorKey: rootNavigatorKey,
  // An unknown path renders the home page in place, same as the old
  // fallback — no redirect, so a mistyped/borrowed link doesn't bounce.
  errorBuilder: (context, state) => const HomePage(),
  routes: [
    for (final entry in pages.entries)
      GoRoute(
        path: entry.key,
        pageBuilder: (context, state) => LineSweepPage(
          path: entry.key,
          builder: entry.value,
          // The destination's own line color rides across the screen, so
          // arriving somewhere reads as travelling down that line rather
          // than a page swap.
          line: productForPath(entry.key)?.accent ?? SLColors.accent,
        ),
      ),
  ],
);

/// Replaces the default page cut with a wipe in the destination's line color:
/// the band sweeps in over the page you are leaving, then off the far side to
/// reveal the one you asked for.
class LineSweepPage extends CustomTransitionPage<void> {
  LineSweepPage({
    required String path,
    required WidgetBuilder builder,
    required Color line,
  }) : super(
         key: ValueKey(path),
         name: path,
         child: Builder(builder: builder),
         transitionDuration: const Duration(milliseconds: 620),
         reverseTransitionDuration: const Duration(milliseconds: 520),
         transitionsBuilder: (context, animation, _, child) {
           // A viewer who asked the OS to stop animation gets the page. Same
           // for the very first page in the stack (a hard reload or a fresh
           // deep link, with no previous page to sweep over) — animating
           // that in release/dart2js hits a framework null-check crash, since
           // there's nothing behind the band to reveal.
           if ((MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
               (ModalRoute.of(context)?.isFirst ?? true)) {
             return child;
           }
           return Stack(
             children: [
               // The arriving page appears behind the band, once the band
               // has covered the screen.
               FadeTransition(
                 opacity: CurvedAnimation(
                   parent: animation,
                   curve: const Interval(0.5, 0.72),
                 ),
                 child: child,
               ),
               IgnorePointer(
                 child: AnimatedBuilder(
                   animation: animation,
                   builder: (context, _) => CustomPaint(
                     size: Size.infinite,
                     painter: _SweepPainter(color: line, t: animation.value),
                   ),
                 ),
               ),
             ],
           );
         },
       );
}

class _SweepPainter extends CustomPainter {
  final Color color;
  final double t;
  _SweepPainter({required this.color, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final e = Curves.easeInOutCubic.transform(t);
    // First half the band covers from the left; second half its trailing
    // edge leaves the same way, uncovering the new page.
    final left = e < 0.5 ? 0.0 : size.width * (e - 0.5) * 2;
    final right = e < 0.5 ? size.width * e * 2 : size.width;
    canvas.drawRect(
      Rect.fromLTRB(left, 0, right, size.height),
      Paint()..color = color,
    );
    // A brighter leading rule, so the band reads as a line travelling rather
    // than a rectangle growing.
    final edge = e < 0.5 ? right : left;
    canvas.drawRect(
      Rect.fromLTRB(edge - 2, 0, edge + 2, size.height),
      Paint()..color = SLColors.ink.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.t != t || old.color != color;
}
