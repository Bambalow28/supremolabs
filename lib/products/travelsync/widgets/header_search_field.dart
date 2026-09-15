import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ts_colors.dart';

/// Header search field, styled after travelsync_website's top-right search
/// bar. Decorative only — supremolabs is a static marketing site with no
/// Supabase backend, so there's nothing to search against here; the real,
/// live search stays on travelsync_website.
class HeaderSearchField extends StatelessWidget {
  const HeaderSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: elevatedSurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search places',
              style: GoogleFonts.anonymousPro(
                fontSize: 12,
                color: Colors.white38,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
