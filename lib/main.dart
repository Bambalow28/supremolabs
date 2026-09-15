import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/router.dart';
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
  runApp(const SupremoLabsApp());
}

class SupremoLabsApp extends StatelessWidget {
  const SupremoLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supremo Labs',
      debugShowCheckedModeBanner: false,
      theme: slTheme(),
      // No initialRoute — it would override the browser's path and send
      // every deep link (supremolabs.com/plansync) back to the home page.
      onGenerateRoute: generateRoute,
    );
  }
}
