import 'package:firebase_core/firebase_core.dart';

/// Web config for PlanSync's own Firebase project (`plansync-ps2026`), used
/// only by the desk — this app's data lives in a separate `supremolabs`
/// project, so the desk talks to PlanSync's Firestore through its own
/// [FirebaseApp] rather than the default one.
const planSyncFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyC62QRM_ExUDvjkC837j6h2Twp4weRjo5M',
  appId: '1:575153542992:web:34d5d6c0654db70bce7e55',
  messagingSenderId: '575153542992',
  projectId: 'plansync-ps2026',
  authDomain: 'plansync-ps2026.firebaseapp.com',
  storageBucket: 'plansync-ps2026.firebasestorage.app',
);
