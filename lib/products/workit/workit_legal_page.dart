// WorkIt has no site of its own, and the App Store requires a reachable
// privacy policy/terms URL — so, like the rest of /workit, these live here
// rather than being invented as placeholders or left as dead links (see
// PRODUCT.md's "every product route must resolve to something real").
// Legibility over identity here: system stack, generous measure, no plate
// colors or instrument chrome — a legal document, not a product demo.
import 'package:flutter/material.dart';

import '../../app/site_shell.dart';
import 'wi_colors.dart';

const _lastUpdated = 'September 15, 2026';
const _contactEmail = 'joshalanis28@gmail.com';

class WorkItPrivacyPage extends StatelessWidget {
  const WorkItPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDoc(
      title: 'WorkIt Privacy Policy',
      sections: _privacySections,
    );
  }
}

class WorkItTermsPage extends StatelessWidget {
  const WorkItTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDoc(
      title: 'WorkIt Terms of Service',
      sections: _termsSections,
    );
  }
}

class _LegalDoc extends StatelessWidget {
  final String title;
  final List<(String, String)> sections;
  const _LegalDoc({required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 700;
    return SiteShell(
      ground: WIColors.ground,
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
                  Text(
                    title,
                    style: wiText(isWide ? 34 : 26, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated $_lastUpdated · Supremo Labs',
                    style: wiText(13, color: WIColors.inkFaint),
                  ),
                  const SizedBox(height: 36),
                  for (final (heading, body) in sections) ...[
                    Text(heading, style: wiText(18, weight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: wiText(15, color: WIColors.inkMuted, height: 1.6),
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

const _privacySections = <(String, String)>[
  (
    '1. Who we are',
    'WorkIt is made by Supremo Labs. This policy covers the WorkIt iOS app '
        '(com.supremolabs.workit). Questions or requests: $_contactEmail.',
  ),
  (
    '2. Your account',
    'WorkIt asks you to sign in with Apple or Google. From that provider we '
        'receive a user identifier and, if you allow it, your name and email '
        'address (Sign in with Apple lets you hide your email behind a relay '
        'address). You also choose a display name, which must be unique and '
        'is shown to other people wherever you share something. You can add '
        'an optional profile photo; it is stored on our servers as a small, '
        'cropped image and is visible to members of your gym groups.',
  ),
  (
    '3. What stays on your device',
    'Your routines, exercises, sets, weights, reps, session history, meals, '
        'nutrition targets, Fit Health reading, and settings are stored '
        'locally on your device and are not sent to our servers. Home Screen '
        'widgets read a small snapshot of those numbers (your streak, this '
        'week\'s sessions, Fit Health scores) from storage shared with the '
        'widget on the same device. Discipline Mode\'s schedule stays on your '
        'device too; if you connect Screen Time, the apps you choose are '
        'saved as opaque tokens Apple provides, which do not reveal to us '
        'which apps they are, and blocking is enforced by iOS on your device.',
  ),
  (
    '4. What reaches our servers, and when',
    'Only data tied to a feature you choose to use. Discover: a routine you '
        'publish (its name, exercises, and your display name) is visible to '
        'other users. Gym groups: your membership, and a leaderboard entry '
        'built from counts and training volume, are visible to that group\'s '
        'members; workouts and form checks you choose to share (routine '
        'name, sets, weights, reps, times, and scores) appear in the group '
        'feed; the group\'s owner sees members\' training load and muscle '
        'trends and can keep private notes on members. Form leaderboard: '
        'your numeric form scores and display name, if you opt in. Form '
        'feedback: if you choose to contribute scored sets, we receive the '
        'score, its per-rep values, and whether you agreed with it — never '
        'video, images, or body positions. Custom exercise submissions, '
        'trainer applications, and referral codes contain what you enter. '
        'We also keep an in-app notification feed, a push notification '
        'token for your device, and a daily count of AI meal estimates used.',
  ),
  (
    '5. The camera and Form Checker',
    'Form Checker analyzes your lifting form using your device\'s camera and '
        'on-device pose estimation. That analysis happens entirely on your '
        'phone: the camera feed is never recorded, saved, uploaded, or seen '
        'by anyone at Supremo Labs. Only resulting numeric scores leave your '
        'device, and only through the features described above.',
  ),
  (
    '6. AI meal estimates',
    'When you photograph or describe a meal and ask WorkIt to estimate it, '
        'that photo and/or description is sent through our server to OpenAI '
        'and, if the first estimate is not reliable enough, to Anthropic, '
        'to return calories, macros, and a nutrition grade. We do not store '
        'the photo or description; those providers process it under their '
        'API terms. The estimate that comes back is saved on your device '
        'only after you confirm it.',
  ),
  (
    '7. Apple Health',
    'If you enable Apple Health sync, WorkIt reads heart rate to show '
        'alongside a workout and sleep data to inform Fit Health\'s recovery '
        'signal, and writes a workout entry back to Health for finished '
        'sessions. This exchange happens between your device and Apple '
        'Health; Health data is not sent to our servers and is never used '
        'for advertising.',
  ),
  (
    '8. Subscriptions and referrals',
    'WorkIt Pro is purchased through your Apple ID; Apple processes payment '
        'and we never receive your card details. RevenueCat receives your '
        'purchase and subscription status, linked to your WorkIt user ID, so '
        'Pro works across reinstalls and devices. If someone redeems your '
        'referral code, we record that link, and when their subscription '
        'starts we record the commission it earned so it can be paid out.',
  ),
  (
    '9. How we use what we collect',
    'To run the features above: sign-in, groups, Discover, the leaderboard, '
        'AI meal estimates, subscriptions, referral payouts, and the '
        'notifications you\'ve enabled; to prevent abuse; and to improve Form '
        'Checker using feedback you choose to contribute. We do not use your '
        'data for advertising, do not track you across other apps or '
        'websites, and do not sell your data.',
  ),
  (
    '10. Who we share it with',
    'Service providers that process data on our behalf: Google Firebase '
        '(Authentication, Cloud Firestore, Cloud Functions, Cloud Messaging), '
        'OpenAI and Anthropic (AI meal estimates only), and RevenueCat '
        '(subscription status). Apple and Google provide sign-in, and Apple '
        'provides HealthKit, Screen Time, and payments. Other WorkIt users '
        'see only what you publish or share. We do not share your data with '
        'data brokers or advertisers.',
  ),
  (
    '11. Data retention and deletion',
    'You can delete your account in Settings. That removes routines you '
        'published to Discover, groups you own (and your membership in '
        'others), your form leaderboard entries, your exercise submissions, '
        'your profile photo, and your account, and retires your referral '
        'code. Records of referral commissions already earned are kept as '
        'financial records. Data stored only on your device stays there '
        'until you delete it in the app or uninstall WorkIt. To request '
        'deletion of anything else we hold, email $_contactEmail.',
  ),
  (
    '12. Security',
    'Data in transit to and from our servers is encrypted. Firestore '
        'security rules restrict private data (such as your push token and '
        'usage counts) to your own account; content you publish or share is, '
        'by design, visible to the people you shared it with.',
  ),
  (
    '13. Children\'s privacy',
    'WorkIt is not directed at children under 13, and we do not knowingly '
        'collect data from them. If you believe a child has used WorkIt, '
        'contact $_contactEmail and we will remove their data.',
  ),
  (
    '14. Changes to this policy',
    'If this policy changes, we\'ll update the date above. Continued use of '
        'WorkIt after a change means you accept the revised policy.',
  ),
  ('15. Contact', 'Supremo Labs — $_contactEmail'),
];

const _termsSections = <(String, String)>[
  (
    '1. Acceptance',
    'These Terms of Service are WorkIt\'s end user license agreement. By '
        'downloading or using WorkIt, you agree to them and to WorkIt\'s '
        'Privacy Policy. If you don\'t agree, don\'t use the app.',
  ),
  (
    '2. What WorkIt is',
    'WorkIt is a workout-tracking app for iOS provided by Supremo Labs: '
        'routine and session logging, Quick Workout, a rest timer with Live '
        'Activities, an on-device Form Checker, training-load tracking, AI '
        'meal logging and nutrition grades, a Fit Health score, Discipline '
        'Mode with optional Screen Time app blocking, gym groups, Discover, '
        'Home Screen widgets, and optional Apple Health sync.',
  ),
  (
    '3. Not medical or nutrition advice',
    'WorkIt is a training log and coaching aid, not a medical device and not '
        'a substitute for professional medical or dietary advice. Form '
        'Checker scores, AI meal estimates and grades, Fit Health readings, '
        'and training-load figures are estimates that can be wrong; they are '
        'not diagnoses and do not guarantee results or injury prevention. '
        'Consult a physician before starting any exercise or diet program.',
  ),
  (
    '4. Your account',
    'You sign in with Apple or Google and are responsible for activity under '
        'your account and for your device\'s security. You can delete your '
        'account at any time in Settings.',
  ),
  (
    '5. WorkIt Pro subscriptions',
    'Some features require WorkIt Pro, offered as weekly, monthly, or yearly '
        'auto-renewing subscriptions at the prices shown in the app. Payment '
        'is charged to your Apple ID at confirmation of purchase. A '
        'subscription renews automatically unless it is cancelled at least '
        '24 hours before the end of the current period, and your account is '
        'charged for renewal within 24 hours before that period ends. Where '
        'a free trial is offered, it converts to a paid subscription unless '
        'cancelled at least 24 hours before it ends. You can manage or cancel '
        'subscriptions in your App Store account settings. Refunds are '
        'handled by Apple under its policies.',
  ),
  (
    '6. Your content and the community',
    'You keep ownership of what you create — display names, profile photos, '
        'published routines, and workouts or form checks you share. You give '
        'Supremo Labs permission to store and display that content to the '
        'people you share it with, for as long as it stays shared. Don\'t '
        'post content that is abusive, hateful, sexual, misleading, or that '
        'you don\'t have the right to share, and don\'t impersonate anyone. '
        'We may remove content or restrict features for accounts that break '
        'these rules. Report objectionable content or users to '
        '$_contactEmail.',
  ),
  (
    '7. Referral program',
    'Referral codes are for sharing with people you know. The reward shown '
        'in the app is earned only when a referred person\'s paid '
        'subscription actually starts. Payouts are made manually, and we may '
        'withhold rewards for refunded purchases, self-referrals, or other '
        'abuse. We may change or end the referral program at any time; '
        'rewards already earned before a change will still be honored.',
  ),
  (
    '8. Acceptable use',
    'Use WorkIt only for its intended purpose. Don\'t attempt to access '
        'another user\'s data, interfere with the service, reverse-engineer '
        'the app, manipulate leaderboards or scores, or misuse AI meal '
        'logging.',
  ),
  (
    '9. Third-party services',
    'WorkIt relies on Apple (sign-in, HealthKit, Screen Time, payments), '
        'Google (sign-in and Firebase), OpenAI and Anthropic (AI meal '
        'estimates), and RevenueCat (subscription status). Your use of those '
        'services is also subject to their own terms.',
  ),
  (
    '10. License, and Apple',
    'Supremo Labs grants you a personal, non-transferable license to use '
        'WorkIt on Apple devices you own or control, as permitted by the App '
        'Store\'s usage rules. These terms are between you and Supremo Labs, '
        'not Apple. Apple has no obligation to provide maintenance or support '
        'for WorkIt and is not responsible for addressing claims about it. '
        'Apple and its subsidiaries are third-party beneficiaries of these '
        'terms and may enforce them against you.',
  ),
  (
    '11. Availability and changes',
    'WorkIt is provided "as is." Features may change, and the service may be '
        'interrupted or discontinued. We\'ll make reasonable efforts to '
        'preserve your data across changes but can\'t guarantee it.',
  ),
  (
    '12. Termination',
    'You may stop using WorkIt at any time by deleting your account and the '
        'app. We may suspend or terminate access for use that violates these '
        'terms.',
  ),
  (
    '13. Limitation of liability',
    'To the fullest extent permitted by law, Supremo Labs is not liable for '
        'any injury, loss, or damage arising from your use of WorkIt, '
        'including reliance on Form Checker scores, AI meal estimates, Fit '
        'Health readings, or training-load estimates. You use WorkIt, and '
        'any exercise or nutrition program it informs, at your own risk.',
  ),
  (
    '14. Changes to these terms',
    'If these terms change, we\'ll update the date above. Continued use of '
        'WorkIt after a change means you accept the revised terms.',
  ),
  ('15. Contact', 'Supremo Labs — $_contactEmail'),
];
