import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../app/backends.dart';

/// Where HoopSync is played. Hand-kept: leagues carry no location field.
const hoopSyncLocations = <String>[];

class HoopSyncStats {
  final int leagues, teams, players;
  const HoopSyncStats(this.leagues, this.teams, this.players);
}

/// The seeded demo league (`slugs/hoopsync-test` -> `orgs/testleague`) is not a
/// real league, so it stays out of every count.
const _demoSlug = 'hoopsync-test';

/// Live counts from HoopSync's own Firestore (`hoopsync-app`): one `slugs` doc
/// per real league, and each league's teams and players. Null if any read
/// fails, so the page shows a dash rather than a wrong number.
Future<HoopSyncStats?> loadHoopSyncStats() async {
  try {
    await backendsReady;
    final db = FirebaseFirestore.instanceFor(app: Firebase.app('hoopsync'));
    final slugs = (await db.collection('slugs').get()).docs
        .where((d) => d.id != _demoSlug)
        .toList();
    Future<int> n(String org, String c) async =>
        (await db.collection('orgs/$org/$c').count().get()).count ?? 0;
    final per = await Future.wait([
      for (final s in slugs)
        Future.wait([
          n(s['orgId'] as String, 'teams'),
          n(s['orgId'] as String, 'players'),
        ]),
    ]);
    return HoopSyncStats(
      slugs.length,
      per.fold(0, (t, r) => t + r[0]),
      per.fold(0, (t, r) => t + r[1]),
    );
  } catch (_) {
    return null;
  }
}
