import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// PlanSync's own Firebase app (`plansync-ps2026`), separate from
/// supremolabs' — the desk reads and writes PlanSync's Firestore directly.
FirebaseAuth get planSyncAuth =>
    FirebaseAuth.instanceFor(app: Firebase.app('plansync'));
FirebaseFirestore get planSyncDb =>
    FirebaseFirestore.instanceFor(app: Firebase.app('plansync'));

/// Same admin/self split as the app's own `firestore.rules`: an `admins/{uid}`
/// doc grants the owner view; anyone else lands in the advisor view scoped to
/// their own uid. There's no client-readable way to check `isAdmin()` ahead of
/// time (the rules deny read on `admins/*` outright), so this signs in and
/// then probes with the one query only an admin can run.
Future<bool> signInAndCheckAdmin({
  required String email,
  required String password,
}) async {
  await planSyncAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  try {
    await planSyncDb
        .collection('advisors')
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    return true;
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') return false;
    rethrow;
  }
}
