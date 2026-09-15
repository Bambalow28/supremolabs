// WorkIt's own Firebase app (`workit-supremolabs`), registered in main()
// alongside PlanSync's and Stanverse's — the desk reads the exact
// referralPayouts rows the iOS app shows a referrer for themselves.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// The one account WorkIt's own `firestore.rules` treats as admin — the
/// referralPayouts read/update rules check this exact address, so signing
/// in as anyone else lands on a permission error rather than an empty
/// ledger.
const kWorkItAdminEmail = 'joshalanis28@gmail.com';

FirebaseAuth get workItAuth =>
    FirebaseAuth.instanceFor(app: Firebase.app('workit'));
FirebaseFirestore get workItDb =>
    FirebaseFirestore.instanceFor(app: Firebase.app('workit'));

/// Signs in with Google against WorkIt's project and reports whether that
/// account is the admin. There is no client-readable "am I admin" flag —
/// the rules key off the verified sign-in email, so this compares against
/// the same address they do.
Future<bool> signInWorkItAdmin() async {
  final credential = await workItAuth.signInWithPopup(GoogleAuthProvider());
  return credential.user?.email == kWorkItAdminEmail;
}
