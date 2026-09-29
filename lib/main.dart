import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/backends.dart';
import 'app/router.dart';
import 'theme/sl_theme.dart';

void main() async {
  // Clean paths (/travelsync) instead of hash URLs (/#/travelsync).
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // Backends start in the background; only the pages that need one wait.
  unawaited(startBackends());
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
