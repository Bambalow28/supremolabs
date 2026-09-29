// The site's Firebase apps and Supabase client, started in parallel *after*
// the first frame. They used to be awaited one by one before runApp(), and
// each Firebase Auth app opens its own iframe — so the marketing pages, which
// touch none of them, sat on a blank screen for many seconds.
//
// Only the back-office pages, the FamFi console and TravelSync's live search
// need a backend; they wait on [backendsReady] (see [BackendGate]).
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../products/famfi/famfi_firebase_options.dart';
import '../products/plansync/desk/plansync_firebase_options.dart';
import '../products/workit/desk/workit_firebase_options.dart';
import '../stanverse_firebase_options.dart';
import '../theme/sl_theme.dart';

/// Started by [startBackends]; every consumer awaits the same future.
Future<void>? _started;
Future<void> get backendsReady => _started ?? startBackends();

Future<void> startBackends() => _started ??= _init();

Future<void> _init() async {
  Future<void> app(String name, FirebaseOptions options) async {
    try {
      // Named apps, so each desk page talks to its own project without a
      // default app colliding (registering one unnamed broke boot: 3021b11).
      await Firebase.initializeApp(name: name, options: options);
    } catch (e) {
      debugPrint('backend "$name" failed to start: $e');
    }
  }

  await Future.wait([
    app('plansync', planSyncFirebaseOptions),
    app('stanverse', DefaultFirebaseOptions.currentPlatform),
    app('workit', workItFirebaseOptions),
    app('famfi', famFiFirebaseOptions),
    Supabase.initialize(
      // Read-only: the /travelsync in-page search reads travelsync's own
      // public tables with its own anon key — same project travelsync_website
      // points at in prod.
      url: 'https://dxhkbrhvwricskfcztgm.supabase.co',
      publishableKey: 'sb_publishable_CWZzJAkLcEVlJPuYu6cqBQ_k8bEdPOo',
    ).then((_) {}).catchError((Object e) {
      debugPrint('supabase failed to start: $e');
    }),
  ]);
}

/// Holds [child] back until the backends are up — a quiet ground-colour beat
/// (a second or two at most) rather than a page that reads a missing app.
class BackendGate extends StatelessWidget {
  final Widget child;
  const BackendGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: backendsReady,
    builder: (context, snap) => snap.connectionState == ConnectionState.done
        ? child
        : const ColoredBox(
            color: SLColors.ground,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SLColors.inkMuted,
                ),
              ),
            ),
          ),
  );
}
