import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router.dart';
import 'products/famfi/famfi_firebase_options.dart';
import 'products/plansync/desk/plansync_firebase_options.dart';
import 'products/workit/desk/workit_firebase_options.dart';
import 'stanverse_firebase_options.dart';
import 'theme/sl_theme.dart';

void main() async {
  // Clean paths (/travelsync) instead of hash URLs (/#/travelsync).
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // Named app so the /plansync/desk page can talk to PlanSync's own
  // Firebase project without a default app colliding with it later.
  await Firebase.initializeApp(
    name: 'plansync',
    options: planSyncFirebaseOptions,
  );
  // Named app so the /stanverse/desk page can talk to Stanverse's own
  // Firebase project (stanverse-fanapp) — the same one the iOS app reads.
  await Firebase.initializeApp(
    name: 'stanverse',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Named app so the /workit/desk page can read WorkIt's own Firebase
  // project (workit-supremolabs) — the referral payout ledger.
  await Firebase.initializeApp(name: 'workit', options: workItFirebaseOptions);
  // Named app so the /famfi/personal console can read juwa_wealth's own
  // Firebase project (juwa-wealth-app). Not the default app — registering
  // it unnamed broke boot for the whole site (3021b11).
  await Firebase.initializeApp(name: 'famfi', options: famFiFirebaseOptions);
  // Read-only: the /travelsync in-page search reads travelsync's own public
  // tables (travel_cards, profiles) with its own anon key — same project
  // travelsync_website points at in prod.
  await Supabase.initialize(
    url: 'https://dxhkbrhvwricskfcztgm.supabase.co',
    publishableKey: 'sb_publishable_CWZzJAkLcEVlJPuYu6cqBQ_k8bEdPOo',
  );
  runApp(const SupremoLabsApp());
}

// Flutter's default web ScrollBehavior only lets touch/stylus drag a
// scrollable — a mouse click-drag is ignored. Every horizontal rail on the
// site (WorkIt's screens, the home crate) wants mouse drag too.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

class SupremoLabsApp extends StatelessWidget {
  const SupremoLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Supremo Labs',
      debugShowCheckedModeBanner: false,
      theme: slTheme(),
      scrollBehavior: _AppScrollBehavior(),
      routerConfig: appRouter,
    );
  }
}
