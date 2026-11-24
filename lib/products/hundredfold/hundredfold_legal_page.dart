// The App Store needs a reachable privacy policy and support URL for HundredFold, and the game has no site of its own, so they live here.
// Legibility over identity: one measure, plain text, the game's palette only for the ground.
import 'package:flutter/material.dart';

import '../../app/site_shell.dart';
import 'hf_colors.dart';

const _lastUpdated = 'November 11, 2026';
const _contactEmail = 'joshalanis28@gmail.com';

class HundredFoldPrivacyPage extends StatelessWidget {
  const HundredFoldPrivacyPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _LegalDoc(title: 'HundredFold Privacy Policy', sections: _privacy);
}

class HundredFoldTermsPage extends StatelessWidget {
  const HundredFoldTermsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _LegalDoc(title: 'HundredFold Terms of Service', sections: _terms);
}

class HundredFoldSupportPage extends StatelessWidget {
  const HundredFoldSupportPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _LegalDoc(title: 'HundredFold Support', sections: _support);
}

class _LegalDoc extends StatelessWidget {
  const _LegalDoc({required this.title, required this.sections});
  final String title;
  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    return SiteShell(
      ground: HFColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 0 : 20,
                isWide ? 40 : 24,
                isWide ? 0 : 20,
                80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: hfDisplay(isWide ? 48 : 36)),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated $_lastUpdated · Supremo Labs',
                    style: hfBody(13),
                  ),
                  const SizedBox(height: 36),
                  for (final (h, b) in sections) ...[
                    Text(
                      h,
                      style: hfBody(
                        18,
                        color: HFColors.ink,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(b, style: hfBody(15, height: 1.65)),
                    const SizedBox(height: 28),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _privacy = <(String, String)>[
  (
    '1. Who we are',
    'HundredFold is made by Supremo Labs. This policy covers the HundredFold iOS app (com.supremolabs.hundredfold). Questions or requests: $_contactEmail.',
  ),
  (
    '2. You can play without an account',
    'The whole game works offline with no account. If you play that way, your progress (money, level, debts, gear and settings) is stored only on your device and never reaches our servers. Deleting the app deletes it.',
  ),
  (
    '3. If you make an account',
    'Accounts are optional. We collect your email address and password (handled by Google Firebase Authentication; we never see your password in plain text), and a display name you choose, which must be unique. We also store the avatar you picked, your game save (money, level, rent and debts, gear and progress) so it follows you between devices, and the numbers the leaderboards are built from (total earned, jobs survived, fastest clean shift, deepest level, earnings this week).',
  ),
  (
    '4. What other players see',
    'Your display name, avatar and leaderboard numbers are visible to other signed-in players on the live board. Your email address and game save are never shown to anyone. If someone reports a display name as offensive, we keep who reported it and the name reported, for moderation.',
  ),
  (
    '5. The microphone',
    'While you hide in a locker the game can use the microphone to measure how loud you are. It reads a single loudness number from the microphone, on the device, and nothing is recorded, stored or sent anywhere. The microphone permission is optional: Crowd Mode, switched on in the game, plays without ever using the microphone.',
  ),
  (
    '6. What we do not do',
    'HundredFold has no ads, no tracking, no analytics, and no in-app purchases. We do not sell or share your data for advertising.',
  ),
  (
    '7. Who processes your data',
    'Account and save data is stored with Google Firebase (Authentication and Cloud Firestore) on our behalf, under Google\'s own terms and security.',
  ),
  (
    '8. Deleting your account',
    'In the app, open the board, tap the account line at the bottom, then Delete account. This permanently deletes your login, display name, profile, leaderboard entry and cloud save. Progress stored on your own device stays there until you delete the app. You can also email $_contactEmail and we will delete the account for you.',
  ),
  (
    '9. Children',
    'HundredFold contains scary themes and is not directed at children under 13. We do not knowingly collect data from children under 13; if you believe a child has made an account, contact us and we will delete it.',
  ),
  (
    '10. Changes',
    'If this policy changes, the date above changes and, for material changes, the app will tell you.',
  ),
];

const _terms = <(String, String)>[
  (
    '1. The game',
    'HundredFold is a game. All money, jobs, companies and characters in it are fictional. In-game money has no real-world value and cannot be exchanged for anything.',
  ),
  (
    '2. Accounts',
    'You may play without an account. If you make one, keep your login to yourself and give accurate details. You can delete your account at any time from inside the app.',
  ),
  (
    '3. Display names and conduct',
    'Your display name is public. Do not use names that are offensive, hateful, sexual, that impersonate someone, or that contain someone else\'s personal information. We may change or remove a name, or close an account, that breaks this. Do not cheat the leaderboards or interfere with the service.',
  ),
  (
    '4. No warranty',
    'The game is provided as it is. We try to keep it working and your save safe, but we do not promise it will always be available or error-free, and we are not liable for loss of progress, to the extent the law allows.',
  ),
  ('5. Contact', 'Supremo Labs, $_contactEmail.'),
];

const _support = <(String, String)>[
  (
    'Contact',
    'Email $_contactEmail. Please say which iPhone and iOS version you have and what happened.',
  ),
  (
    'I lost my progress',
    'If you made an account, sign in on the new device from the first screen, or from the board (tap the account line at the bottom). Your save follows your account. If you never made an account, progress lives only on the device it was played on.',
  ),
  (
    'Can I play without the microphone?',
    'Yes. On the contract screen before a shift, or in the pause menu, switch on Crowd Mode. Hiding then uses a Hold-to-hold-your-breath button with a limited breath meter instead of the microphone. It also takes over by itself when a room is too loud for the microphone.',
  ),
  (
    'How do I delete my account?',
    'Open the board, tap the account line at the bottom, then Delete account. Everything tied to the account is deleted.',
  ),
  (
    'Someone\'s name is offensive',
    'On the live board, press and hold a name and choose Report.',
  ),
  (
    'Display name taken',
    'Names are unique, ignoring capital letters. Names are 3 to 16 letters, numbers or underscores.',
  ),
];
