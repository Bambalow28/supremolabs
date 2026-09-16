// /travelsync — the product's own world inside the studio shell. Palette,
// type (Crimson Text / Anonymous Pro) and the card/passport showcases are
// ported from travelsync_website so this reads as TravelSync, not as a
// Supremo summary of it. Nav and footer now ride TravelSync's own accent
// per DESIGN.md's transit-map chrome.
//
// Ported: hero + card fan, features, passport stamps, theme showcase, store
// CTA. Not ported: live place search, trip/user/place pages, admin console —
// those need Supabase and stay in travelsync_website.
//
// Stations: `/travelsync/features` and `/travelsync/download` are the same
// page, scrolled to that section — real, bookmarkable sub-routes rather than
// separate pages, since the page is one continuous scroll.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/motion.dart';
import '../../app/site_shell.dart';
import 'search/in_page_search.dart';
import 'ts_colors.dart';
import 'widgets/app_store_button.dart';
import 'widgets/hero_card_fan.dart';
import 'widgets/map_background.dart';
import 'widgets/marketing.dart';

class TravelSyncPage extends StatelessWidget {
  final String? initialSection;
  final _featuresKey = GlobalKey();
  final _downloadKey = GlobalKey();

  TravelSyncPage({super.key, this.initialSection});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;
    switch (initialSection) {
      case 'features':
        scrollToSection(_featuresKey);
      case 'download':
        scrollToSection(_downloadKey);
    }
    return SiteShell(
      ground: bgDark,
      children: [
        Stack(
          children: [
            // On travelsync_website the gradient is a full-screen backdrop,
            // so it resolves to bgDark within one viewport. Here the body is
            // a long scroll, so it gets the same one-viewport run rather
            // than being stretched over the whole page.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [gradTop, gradMid, gradBot],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            CustomPaint(
              painter: MapBackgroundPainter(),
              child: Column(
                children: [
                  FadeSlideIn(child: _Hero(isWide: isWide)),
                  KeyedSubtree(
                    key: _featuresKey,
                    child: FadeSlideIn(child: FeaturesSection(isWide: isWide)),
                  ),
                  FadeSlideIn(child: PassportSection(isWide: isWide)),
                  FadeSlideIn(child: ThemeShowcase(isWide: isWide)),
                  KeyedSubtree(
                    key: _downloadKey,
                    child: FadeSlideIn(child: DownloadCta(isWide: isWide)),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Ported from travelsync_website's `_Hero`, minus the search field — search
/// needs Supabase and lives on the product's own site.
class _Hero extends StatelessWidget {
  final bool isWide;
  const _Hero({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWide ? 48 : 24,
        isWide ? 20 : 12,
        isWide ? 48 : 24,
        isWide ? 44 : 32,
      ),
      child: Column(
        children: [
          HeroCardFan(isWide: isWide),
          SizedBox(height: isWide ? 44 : 28),
          const _Pill(
            icon: Icons.public_rounded,
            label: 'YOUR TRIPS, BEAUTIFULLY KEPT',
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              'Every journey,\nworth revisiting.',
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                fontSize: isWide ? 64 : 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'TravelSync turns the places you go into living photo journals — '
              'a clean, shareable page for every trip you take.',
              textAlign: TextAlign.center,
              style: GoogleFonts.anonymousPro(
                fontSize: isWide ? 16 : 14,
                color: Colors.white70,
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Center(child: InPageSearch()),
          const SizedBox(height: 32),
          const AppStoreButton(large: true),
        ],
      ),
    );
  }
}

/// Ported from travelsync_website's `_Pill`.
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryBlue),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.anonymousPro(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
