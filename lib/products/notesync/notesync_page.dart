// THESIS: /notesync ports the app's own screens rather than inventing a
// marketing metaphor for them — rounded note tiles, folder cards, and the
// gradient "Notes" wordmark are the same components and tokens the real app
// ships (see notesync/lib/theme/app_theme.dart and UI/home/widgets/), so a
// visitor who later opens the app recognizes it immediately.
// OWN-WORLD: NoteSync's own true black (#000000), surface #1C1C1E, elevated
// #2C2C2E, one iOS-blue accent #0A84FF — mirrored 1:1 from AppColors.dark,
// not approximated. No custom font family; the system face (SF Pro on iOS)
// carries the UI, matching the app's own theme.
// STORY: the visitor recognizes the app's real UI (not an abstraction of
// it), understands what NoteSync actually looks like day to day, and ticks
// the line that asks for a build.
// FORM: home-screen anatomy — hero with the app's own header, a flattened
// note list, a folder list, each row a rounded card exactly like the app
// draws it.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/motion.dart';
import '../../app/site_shell.dart';
import 'ns_colors.dart';

/// NoteSync has no public App Store listing yet, so the page says so and
/// asks for the beta rather than pointing at a listing that does not exist.
final _betaMailto = Uri(
  scheme: 'mailto',
  path: 'joshalanis28@gmail.com',
  queryParameters: const {'subject': 'NoteSync TestFlight access'},
);

// Mirrors the app's own default folder color choices (notes_home_screen.dart
// `_defaultFolderColorChoices`) — the user's own pick per folder, not five
// shades of one accent.
const _folders = <(String, int, Color)>[
  ('Home', 24, Color(0xFF4CAF55)),
  ('Recipes', 61, Color(0xFFE0A030)),
  ('Book', 12, Color(0xFF4B76FA)),
  ('Music', 38, Color(0xFF8B5CF6)),
  ('Work', 107, Color(0xFFE0637A)),
];

Color _folderColor(String name) => _folders.firstWhere((f) => f.$1 == name).$3;

class NoteSyncPage extends StatelessWidget {
  /// `/notesync/folders` and `/notesync/device` scroll to that part of the
  /// page — real sub-routes, not separate pages.
  final String? initialSection;
  final _foldersKey = GlobalKey();
  final _deviceKey = GlobalKey();

  NoteSyncPage({super.key, this.initialSection});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    switch (initialSection) {
      case 'folders':
        scrollToSection(_foldersKey);
      case 'device':
        scrollToSection(_deviceKey);
    }

    return SiteShell(
      ground: NSColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 0 : 20,
                isWide ? 32 : 20,
                isWide ? 0 : 20,
                80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(child: _Hero(isWide: isWide)),
                  const SizedBox(height: 48),
                  // Paired side by side on wide screens — related sections
                  // fill the width instead of stacking under one narrow
                  // column with a wide empty gutter either side.
                  FadeSlideIn(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _NoteList(isWide: isWide)),
                              const SizedBox(width: 40),
                              Expanded(child: _Week(isWide: isWide)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _NoteList(isWide: isWide),
                              const SizedBox(height: 40),
                              _Week(isWide: isWide),
                            ],
                          ),
                  ),
                  const SizedBox(height: 40),
                  FadeSlideIn(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: KeyedSubtree(
                                  key: _foldersKey,
                                  child: _Folders(isWide: isWide),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: KeyedSubtree(
                                  key: _deviceKey,
                                  child: _OnYourDevice(isWide: isWide),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KeyedSubtree(
                                key: _foldersKey,
                                child: _Folders(isWide: isWide),
                              ),
                              const SizedBox(height: 40),
                              KeyedSubtree(
                                key: _deviceKey,
                                child: _OnYourDevice(isWide: isWide),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 48),
                  FadeSlideIn(child: _Close(isWide: isWide)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The app's own header row — icon mark, plain wordmark — ported from
/// notes_home_screen.dart's app bar, which dropped its gradient title for a
/// plain `headlineSmall` one now that the app reads as iOS-native.
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: NSColors.elevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: NSColors.border),
          ),
          child: const Icon(
            Icons.sticky_note_2_rounded,
            color: NSColors.accent,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text('Notes', style: nsText(26, weight: FontWeight.w700)),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isWide;
  const _Hero({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AppHeader(),
        const SizedBox(height: 28),
        Text(
          'A note is not\na document.',
          style: nsText(isWide ? 44 : 32, weight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'It is a line you write in six seconds and find again in two. '
            'NoteSync keeps every one of them on your phone, in plain tiles, '
            'with nothing between you and the thing you wrote.',
            style: nsText(15, color: NSColors.inkMuted, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        const _RequestButton(),
      ],
    );
  }
}

/// The app's own primary-button treatment: accent fill, background-colored
/// label — `onPrimary: colors.background` in app_theme.dart, not a guess.
class _RequestButton extends StatefulWidget {
  const _RequestButton();

  @override
  State<_RequestButton> createState() => _RequestButtonState();
}

class _RequestButtonState extends State<_RequestButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        label: 'Ask for a NoteSync TestFlight build by email',
        child: GestureDetector(
          onTap: () => launchUrl(_betaMailto),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xFF409CFF) : NSColors.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mail_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  'Ask for a TestFlight build',
                  style: nsText(15, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small colored tag naming a folder — ported from the app's FolderTag: the
/// folder's own hue as a light top-to-bottom wash, lerped toward white so it
/// stays legible on dark.
class _FolderTag extends StatelessWidget {
  final String name;
  const _FolderTag({required this.name});

  @override
  Widget build(BuildContext context) {
    final color = _folderColor(name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name,
        style: nsText(11, color: Color.lerp(color, Colors.white, 0.3)!),
      ),
    );
  }
}

/// A rounded note row — ported from the app's NoteTile: surface fill,
/// hairline border, 16px radius, sticky-note leading icon, title + muted
/// caption, folder tag on the right.
class _NoteRow extends StatelessWidget {
  final String title;
  final String folder;
  final String day;
  const _NoteRow({
    required this.title,
    required this.folder,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: NSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NSColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.sticky_note_2_outlined,
            size: 26,
            color: NSColors.inkMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: nsText(16, weight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _FolderTag(name: folder),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Last edited: $day',
                  style: nsText(12, color: NSColors.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteList extends StatelessWidget {
  final bool isWide;
  const _NoteList({required this.isWide});

  // Illustrative notes — flagged as a sample at the foot of the page.
  static const _notes = <(String, String, String)>[
    ('Call the landlord about the radiator', 'Home', 'Tue'),
    ('Kimchi fried rice — day-old rice, more gochujang', 'Recipes', 'Mon'),
    ('She said the second chapter is the one to cut', 'Book', 'Sun'),
    ('Ask about the deposit before signing anything', 'Home', 'Sun'),
    ('Bass line for the bridge is one bar too long', 'Music', 'Sat'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          eyebrow: 'all notes',
          title: 'Everything you wrote, on one screen.',
          isWide: isWide,
        ),
        const SizedBox(height: 16),
        for (final (text, folder, day) in _notes)
          _NoteRow(title: text, folder: folder, day: day),
        const SizedBox(height: 4),
        Text(
          'The home screen is the notes themselves — no folders to open '
          'first, no list of lists.',
          style: nsText(14, color: NSColors.inkMuted, height: 1.5),
        ),
      ],
    );
  }
}

/// This week's due dates — a row of day cards, due ones tinted with the
/// accent, mirroring the same rounded-card/border language as the note and
/// folder rows above instead of a separate visual system.
class _Week extends StatelessWidget {
  final bool isWide;
  const _Week({required this.isWide});

  static const _days = <(String, String, String?)>[
    ('M', '15', null),
    ('T', '16', 'Radiator'),
    ('W', '17', null),
    ('T', '18', 'Deposit'),
    ('F', '19', null),
    ('S', '20', 'Rehearsal'),
    ('S', '21', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          eyebrow: 'september',
          title: 'What is due, on the day it is due.',
          isWide: isWide,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final (letter, date, due) in _days)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: due == null
                        ? NSColors.surface
                        : NSColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: due == null
                          ? NSColors.border
                          : NSColors.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(letter, style: nsText(11, color: NSColors.inkMuted)),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: nsText(
                          16,
                          weight: FontWeight.w700,
                          color: due == null ? NSColors.ink : NSColors.accent,
                        ),
                      ),
                      if (due != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          due,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: nsText(9, color: NSColors.accent),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Give a note a date and it turns into a reminder. The calendar is '
          'the same notes, read by day instead of by folder.',
          style: nsText(14, color: NSColors.inkMuted, height: 1.5),
        ),
      ],
    );
  }
}

/// A collapsed folder header — ported from the app's FolderTile: folder icon
/// in the folder's own color, a soft top-to-bottom wash of that color, name,
/// note count, chevron.
class _FolderRow extends StatelessWidget {
  final String name;
  final int count;
  final Color color;
  const _FolderRow({
    required this.name,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NSColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.folder, size: 26, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: nsText(16, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  count == 1 ? '1 note' : '$count notes',
                  style: nsText(12, color: NSColors.inkMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more, color: NSColors.inkMuted),
        ],
      ),
    );
  }
}

class _Folders extends StatelessWidget {
  final bool isWide;
  const _Folders({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          eyebrow: 'folders',
          title: 'Filed only when filing helps.',
          isWide: isWide,
        ),
        const SizedBox(height: 16),
        for (final (name, count, color) in _folders)
          _FolderRow(name: name, count: count, color: color),
      ],
    );
  }
}

class _OnYourDevice extends StatelessWidget {
  final bool isWide;
  const _OnYourDevice({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: NSColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NSColors.border),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: NSColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your notes never leave the phone.',
                    style: nsText(isWide ? 24 : 20, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      'There is no NoteSync account and no NoteSync server. Notes '
                      'are stored on the device and nowhere else — which also '
                      'means a phone you wipe takes them with it. Back the '
                      'device up.',
                      style: nsText(14, color: NSColors.inkMuted, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Close extends StatelessWidget {
  final bool isWide;
  const _Close({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NoteSync is in TestFlight.',
          style: nsText(isWide ? 30 : 24, weight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'No App Store listing yet — the iOS beta is running now. Ask for '
            'a build and we will add you to the tester list.',
            style: nsText(14, color: NSColors.inkMuted, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        const _RequestButton(),
        const SizedBox(height: 20),
        Text(
          'Notes, folders and dates shown above are a sample.',
          style: nsText(11, color: NSColors.inkMuted, letterSpacing: 0.3),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final bool isWide;
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: nsText(11, color: NSColors.accent, letterSpacing: 1.6),
        ),
        const SizedBox(height: 6),
        Text(title, style: nsText(isWide ? 24 : 20, weight: FontWeight.w700)),
      ],
    );
  }
}
