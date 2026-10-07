import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../about/about_page.dart';
import 'backends.dart';
import '../data/products.dart';
import '../home/home_page.dart';
import '../products/diamo/diamo_page.dart';
import '../products/esync/esync_page.dart';
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
  '/esync': (_) => const ESyncPage(),
  '/esync/charges': (_) => const ESyncPage(initialSection: 'charges'),
  '/esync/service': (_) => const ESyncPage(initialSection: 'service'),
  '/esync/boards': (_) => const ESyncPage(initialSection: 'boards'),
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

/// Replaces the default page cut. The arriving page rises into place while a
/// rule in the destination's line color draws across the top; the page you are
/// leaving sinks back and dims, so the move reads as depth, not a swap. Pops
/// run the same motion in reverse.
class LineSweepPage extends CustomTransitionPage<void> {
  LineSweepPage({
    required String path,
    required WidgetBuilder builder,
    required Color line,
  }) : super(
         key: ValueKey(path),
         name: path,
         child: Builder(builder: builder),
         transitionDuration: const Duration(milliseconds: 760),
         reverseTransitionDuration: const Duration(milliseconds: 480),
         transitionsBuilder: (context, animation, secondary, child) {
           // A viewer who asked the OS to stop animation gets the page.
           if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
             return child;
           }
           const expo = Cubic(0.16, 1, 0.3, 1);
           final enter = CurvedAnimation(
             parent: animation,
             curve: expo,
             reverseCurve: Curves.easeInCubic,
           );
           final leave = CurvedAnimation(parent: secondary, curve: expo);
           return AnimatedBuilder(
             animation: leave,
             builder: (context, page) => Opacity(
               opacity: 1 - 0.55 * leave.value,
               child: Transform.scale(
                 scale: 1 - 0.03 * leave.value,
                 child: page,
               ),
             ),
             child: Stack(
               children: [
                 FadeTransition(
                   opacity: CurvedAnimation(
                     parent: animation,
                     curve: const Interval(0, 0.55, curve: Curves.easeOut),
                   ),
                   child: SlideTransition(
                     position: Tween(
                       begin: const Offset(0, 0.045),
                       end: Offset.zero,
                     ).animate(enter),
                     child: child,
                   ),
                 ),
                 IgnorePointer(
                   child: AnimatedBuilder(
                     animation: animation,
                     builder: (context, _) => CustomPaint(
                       size: Size.infinite,
                       painter: _RulePainter(color: line, t: animation.value),
                     ),
                   ),
                 ),
               ],
             ),
           );
         },
       );
}

/// A 3px rule drawing left to right across the top of the viewport, then
/// lifting away once the page has landed.
class _RulePainter extends CustomPainter {
  final Color color;
  final double t;
  _RulePainter({required this.color, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final draw = Curves.easeOutCubic.transform((t / 0.6).clamp(0.0, 1.0));
    final fade = 1 - ((t - 0.6) / 0.4).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * draw, 3),
      Paint()..color = color.withValues(alpha: fade),
    );
  }

  @override
  bool shouldRepaint(_RulePainter old) => old.t != t || old.color != color;
}
