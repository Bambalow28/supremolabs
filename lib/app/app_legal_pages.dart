// App Store privacy-policy and support URLs for apps that have no site of
// their own: /<app>/privacy and /<app>/support (plus /stanverse/terms).
// Plain legal text on the studio ground; same pattern as the WorkIt and
// HundredFold legal pages. Describe only what each app really does.
import 'package:flutter/material.dart';

import '../theme/sl_theme.dart';
import 'site_shell.dart';

const _updated = 'November 13, 2026';
const _email = 'joshalanis28@gmail.com';

typedef _Doc = List<(String, String)>;

class _App {
  const _App(this.name, this.privacy, this.support, [this.terms]);
  final String name;
  final _Doc privacy, support;
  final _Doc? terms;
}

/// Builders for every `/<slug>/privacy|support|terms` route in this file.
final Map<String, WidgetBuilder> appLegalPages = {
  for (final e in _apps.entries) ...{
    '/${e.key}/privacy': (_) =>
        _LegalDoc('${e.value.name} Privacy Policy', e.value.privacy),
    '/${e.key}/support': (_) =>
        _LegalDoc('${e.value.name} Support', e.value.support),
    if (e.value.terms != null)
      '/${e.key}/terms': (_) =>
          _LegalDoc('${e.value.name} Terms of Use', e.value.terms!),
  },
};

class _LegalDoc extends StatelessWidget {
  const _LegalDoc(this.title, this.sections);
  final String title;
  final _Doc sections;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;
    return SiteShell(
      ground: SLColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
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
                  Text(
                    title.toUpperCase(),
                    style: SLType.display(wide ? 48 : 36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated $_updated · Supremo Labs',
                    style: SLType.body(13),
                  ),
                  const SizedBox(height: 36),
                  for (final (h, b) in sections) ...[
                    Text(
                      h,
                      style: SLType.body(
                        18,
                        color: SLColors.ink,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      b,
                      style: SLType.body(15).copyWith(height: 1.65),
                    ),
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

const _contact = (
  'Contact',
  'Email $_email. Please say which iPhone and iOS version you have and what happened.',
);
const _children = (
  'Children',
  'Not directed at children under 13. We do not knowingly collect data from children under 13; if you believe a child has made an account, contact us at $_email and we will delete it.',
);
const _changes = (
  'Changes',
  'If this policy changes, the date above changes. Questions: $_email.',
);
const _noSell =
    'We do not sell your data, show ads, or track you across apps or sites.';

final _apps = <String, _App>{
  'diamo': const _App(
    'DiaMo',
    [
      (
        'Who we are',
        'DiaMo is a baby diary made by Supremo Labs. Questions or requests: $_email.',
      ),
      (
        'What we collect',
        'To make an account: your email address (or Apple\'s private relay address if you use Sign in with Apple), a name, and an account ID. Plus what you add: diary entries, milestones, wishes, photos, and any posts or comments you share with the Village.',
      ),
      (
        'How it is used',
        'Only to run your diary and sync it across your devices. Entries start private. Only the ones you choose to Share with the Village are visible to other users, and you can unshare them at any time. $_noSell',
      ),
      (
        'Who stores it',
        'Your data is stored with Google Firebase (Authentication, Cloud Firestore and Cloud Storage) on our behalf, under Google\'s own terms and security.',
      ),
      (
        'Reporting and blocking',
        'Every Village post has a menu with Report post and Block user. We review reports within 24 hours.',
      ),
      (
        'Camera and photos',
        'Used only when you choose to attach a picture to an entry.',
      ),
      (
        'Deleting your data',
        'In the app, open You, then Delete account. This permanently deletes your account and the data tied to it. You can also email $_email.',
      ),
      _children,
      _changes,
    ],
    [
      _contact,
      (
        'How do I delete my account?',
        'Open You, then Delete account. Everything tied to the account is deleted.',
      ),
      (
        'How do I make an entry private again?',
        'Open the entry and switch off Share with the Village.',
      ),
      (
        'Someone is posting something harmful',
        'Open the post\'s menu and choose Report post or Block user. We act on reports within 24 hours.',
      ),
    ],
  ),
  'notesync': const _App(
    'NoteSync',
    [
      (
        'Who we are',
        'NoteSync is made by Supremo Labs. Questions or requests: $_email.',
      ),
      (
        'What we collect',
        'Nothing. NoteSync has no accounts, analytics, advertising or tracking, and sends nothing to us or to third parties. $_noSell',
      ),
      (
        'Your content',
        'Notes, folders, habits, reminders, photos and voice memos are stored on your device only. If you turn on Sync to iCloud in Settings, that content is copied to your own iCloud account using Apple\'s iCloud; we cannot access it. If iCloud sync is off, deleting the app permanently removes your data.',
      ),
      (
        'Permissions',
        'Photos and Camera (add images to notes), Microphone (voice memos), Calendars (import events you choose) and Notifications (your reminders). Data from these stays on your device, except via iCloud sync if you enable it.',
      ),
      _children,
      _changes,
    ],
    [
      _contact,
      (
        'Where are my notes stored?',
        'On your device. Turn on Sync to iCloud in Settings to also keep them in your own iCloud. Without iCloud sync, deleting the app deletes your notes, so turn it on before reinstalling or changing phones.',
      ),
      (
        'Why does NoteSync ask for the microphone, camera or calendar?',
        'Only for voice memos, adding photos to notes, and importing events you pick. You can deny any of them and keep using the rest.',
      ),
    ],
  ),
  'papersync': const _App(
    'PaperSync',
    [
      (
        'Who we are',
        'PaperSync is a document scanner made by Supremo Labs. Questions or requests: $_email.',
      ),
      (
        'What we collect',
        'Nothing. PaperSync has no accounts, analytics or ads, and sends nothing to us or to third parties. $_noSell',
      ),
      (
        'Your documents',
        'Scans are stored only on your device and, if you enable backup, in your own iCloud Drive using Apple\'s iCloud; we cannot access them. Deleting the app without backup removes your scans.',
      ),
      (
        'Camera',
        'Used only to scan pages. The photos are processed on your device.',
      ),
      _children,
      _changes,
    ],
    [
      _contact,
      (
        'Where are my scans?',
        'On your device, and in your iCloud Drive if iCloud backup is on. Without backup, deleting the app deletes your scans.',
      ),
      (
        'Scanning looks wrong',
        'Lay the page flat on a contrasting surface in good light and hold steady until the edges lock.',
      ),
    ],
  ),
  'plansync': const _App(
    'PlanSync',
    [
      (
        'Who we are',
        'PlanSync is a trip planner made by Supremo Labs. Questions or requests: $_email.',
      ),
      (
        'On your device',
        'Your trips, itineraries, expenses and documents stay on your device (and in your own iCloud if you use it). Your location is read on the device only, to suggest the nearest city, and is never sent to us.',
      ),
      (
        'Accounts',
        'An account is needed only for advisor features. We store your email address, name, user ID, your advisor profile and places, and any plan requests you make (such as destination and budget), using Google Firebase (Authentication and Cloud Firestore).',
      ),
      (
        'Services that receive text you search',
        'To work, some features send the minimum needed to third parties: OpenAI (destination, dates and budget for AI itineraries), Unsplash (destination for photo search), Mapbox (address search text) and AeroDataBox (flight number). They are not sent your name or email. $_noSell',
      ),
      (
        'Deleting your account',
        'In the app: Settings, Account, Delete account. This deletes your profile, advisor listing and places, and your login. You can also email $_email.',
      ),
      _children,
      _changes,
    ],
    [
      _contact,
      (
        'How do I delete my account?',
        'Settings, Account, Delete account (shown when signed in).',
      ),
      (
        'Where are my trips?',
        'On your device, and in your iCloud if you use it. Signing out does not delete them.',
      ),
      (
        'Location',
        'PlanSync asks for location only to suggest the nearest city. Denying it just means you pick a city yourself.',
      ),
    ],
  ),
  'stagehand': const _App(
    'StageHand',
    [
      (
        'Who we are',
        'StageHand is a chord-chart and band-cue app made by Supremo Labs. Questions or requests: $_email.',
      ),
      (
        'No sign-up',
        'StageHand has no accounts. It signs you in anonymously in the background so bands can sync, which gives you a random user ID with no name, email or password.',
      ),
      (
        'What we store',
        'Your charts and setlists live on your device. If you create or join a band, the chart text, cue data and the display name you choose are stored with Google Firebase (Cloud Firestore) so your bandmates can see them. $_noSell',
      ),
      (
        'Permissions',
        'None. StageHand does not use the camera, microphone, photos or location. Voice cues use on-device speech; backing tracks are files you pick from Files.',
      ),
      (
        'Deleting your data',
        'Email $_email with your band code and we will delete the band\'s cloud data. Deleting the app removes your local charts.',
      ),
      _children,
      _changes,
    ],
    [
      _contact,
      (
        'How do I join a band?',
        'Open the Band tab and enter the code from the band\'s creator, or create a band to get a code.',
      ),
      (
        'My chart did not read correctly',
        'On the review screen, unreadable chords are flagged. Fix them with the chord builder before saving.',
      ),
      (
        'Can I use it offline?',
        'Yes. Your personal library works fully offline. Bands need a connection to sync.',
      ),
    ],
  ),
  'stanverse': const _App(
    'StanVerse',
    [
      (
        'Who we are',
        'StanVerse is an unofficial fan app made by Supremo Labs. It is not affiliated with, endorsed by or sponsored by any artist, group or company. Questions or requests: $_email.',
      ),
      (
        'What we collect',
        'Your email address, username and password (handled by Firebase Authentication), and what you create: posts, replies, marketplace listings, photos and order requests, plus accounts you block and reports you file.',
      ),
      (
        'How it is used',
        'To run your account and show your content to other fans. Posts, listings and usernames are visible to other users. $_noSell',
      ),
      (
        'Who stores it',
        'Google Firebase (Authentication, Cloud Firestore and Cloud Storage), under Google\'s own terms and security.',
      ),
      ('Camera and photos', 'Used only when you choose to attach a photo.'),
      (
        'Deleting your data',
        'In the app: Profile, Delete account, which removes your account and profile. Email $_email to also remove posts and listings you made.',
      ),
      _children,
      _changes,
    ],
    [
      _contact,
      ('How do I delete my account?', 'Profile, then Delete account.'),
      (
        'Report or block',
        'Use the menu on any post or listing to report it or block the user. Reported content is reviewed within 24 hours and abusive users are removed.',
      ),
      (
        'Is this official?',
        'No. StanVerse is an independent fan app and is not affiliated with any artist.',
      ),
    ],
    [
      (
        'Fan app',
        'StanVerse is unofficial. Artist names and images belong to their owners and are used only to describe fan interests.',
      ),
      (
        'Your content',
        'You are responsible for what you post. Do not post anything hateful, harassing, sexual, illegal, or that infringes someone else\'s rights. There is no tolerance for objectionable content or abusive users: we may remove content and close accounts that break these rules, and you can report or block anyone from the app.',
      ),
      (
        'Marketplace',
        'Listings are between users. Supremo Labs is not a party to sales and does not guarantee items or sellers. Do not sell counterfeit or unauthorized goods.',
      ),
      (
        'No warranty',
        'The app is provided as it is, to the extent the law allows.',
      ),
      ('Contact', '$_email.'),
    ],
  ),
  'vestiary': const _App(
    'Vestiary',
    [
      (
        'Who we are',
        'Vestiary is a digital wardrobe made by Supremo Labs. Questions or requests: $_email.',
      ),
      (
        'What we collect',
        'Your email address (or Apple\'s private relay address), an account ID, your name if you share it through Sign in with Apple, and the garment photos, outfits and closet data you add.',
      ),
      (
        'How it is used',
        'Only to run your closet and sync it across your devices. It is stored with Google Firebase (Authentication, Firestore and Storage) under your account; other users cannot see it. $_noSell',
      ),
      (
        'AI features',
        'If you turn them on, the photos you choose (garments, try-on photos, outfit-check mirror photos) are sent through our server to an AI provider (OpenAI) to name and crop clothes, generate a try-on, or give outfit feedback. They are not used to train models or for advertising. Outfit-check photos are not saved. Turn these off any time in You, AI features.',
      ),
      (
        'Camera and photos',
        'Used only to add pictures of your clothes and for try-on and outfit check.',
      ),
      (
        'Deleting your data',
        'In the app: You, Delete account permanently removes your account, closet, photos and outfits. You can also email $_email.',
      ),
      _children,
      _changes,
    ],
    [
      _contact,
      ('How do I delete my account?', 'You, then Delete account.'),
      (
        'Are my photos sent anywhere?',
        'Only if AI features are on, and only the photos you pick. Turn them off in You, AI features.',
      ),
      (
        'A cutout looks wrong',
        'Retake the photo on a plain background in even light, or re-crop it from the item.',
      ),
    ],
  ),
};
