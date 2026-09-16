// /wealthsync — the product's own world inside the studio shell. Palette,
// Italiana / JetBrains Mono type and the zigzag feature highlights are
// ported from wealthsync_website. Nav and footer now ride WealthSync's own
// accent per DESIGN.md's transit-map chrome.
//
// Ported: gradient ground, hero, feature row, four feature highlights.
// Not ported: the Firestore waitlist form (supremolabs has no Firebase —
// signups stay on wealthsync_website), the SVG logo (its asset is missing
// upstream; the app icon stands in), and the Feature Five/Six/Seven
// placeholder blocks, which point at PNGs that don't exist.
//
// Stations: `/wealthsync/features` and `/wealthsync/tracker` are the same
// page, scrolled to that section.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/motion.dart';
import '../../app/site_shell.dart';
import 'widgets/feature_highlight.dart';
import 'widgets/feature_row.dart';
import 'widgets/gradient_background.dart';
import 'ws_colors.dart';

class WealthSyncPage extends StatelessWidget {
  final String? initialSection;
  final _featuresKey = GlobalKey();
  final _trackerKey = GlobalKey();

  WealthSyncPage({super.key, this.initialSection});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 450;
    switch (initialSection) {
      case 'features':
        scrollToSection(_featuresKey);
      case 'tracker':
        scrollToSection(_trackerKey);
    }
    return SiteShell(
      ground: AppColors.backgroundColor,
      children: [
        GradientBackground(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 24 : 80,
              isMobile ? 40 : 80,
              isMobile ? 24 : 80,
              20,
            ),
            child: Column(
              children: [
                FadeSlideIn(
                  child: Column(
                    children: [
                      // The app icon already carries its own ground and
                      // corner, so it is shown as-is rather than tiled
                      // inside a second one.
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(22),
                        ),
                        child: Image.asset(
                          'assets/wealthsync/logo.png',
                          width: isMobile ? 80 : 108,
                          height: isMobile ? 80 : 108,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'The all-in-one app to track your wealth,\nspending, and financial goals.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.italiana(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 32 : 64,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Track every account, log every expense, and see where your\n'
                        'money actually goes.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: isMobile ? 12 : 14,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                KeyedSubtree(
                  key: _featuresKey,
                  child: const FadeSlideIn(child: FeatureRow()),
                ),
                const SizedBox(height: 40),
                KeyedSubtree(
                  key: _trackerKey,
                  child: const FadeSlideIn(
                    child: FeatureHighlight(
                      imagePath: 'assets/wealthsync/main_page.png',
                      title: 'Account Tracker',
                      bullets: [
                        'Track every account effortlessly',
                        'View your net worth in real-time',
                        'Get notifications for key events',
                      ],
                    ),
                  ),
                ),
                const FadeSlideIn(
                  child: FeatureHighlight(
                    imagePath: 'assets/wealthsync/expense_list.png',
                    title: 'Expense Logging',
                    imageOnRight: true,
                    bullets: [
                      'Smart expense categorization',
                      'Visualize spending trends',
                      'Automated budgeting suggestions',
                    ],
                  ),
                ),
                const FadeSlideIn(
                  child: FeatureHighlight(
                    imagePath: 'assets/wealthsync/tools_list.png',
                    title: 'Powerful Tools',
                    bullets: [
                      'Set up budgets and goals',
                      'Analyze financial health with AI',
                      'Generate reports and insights',
                    ],
                  ),
                ),
                const FadeSlideIn(
                  child: FeatureHighlight(
                    imagePath: 'assets/wealthsync/profile_page.png',
                    title: 'Profile & Analytics',
                    imageOnRight: true,
                    bullets: [
                      'View detailed account summaries',
                      'Track performance over time',
                      'Secure, encrypted personal data',
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
