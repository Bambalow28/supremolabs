import 'package:firebase_core/firebase_core.dart';

/// Web config of HoopSync's own Firebase project (`hoopsync-app`), read only
/// for the public counters on /hoopsync. Public identifiers, not secrets:
/// access is controlled by that project's firestore.rules.
const hoopSyncFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyBpAXAckJUnPdiYOjeXg8TyFrYO7gdPImY',
  appId: '1:290349099295:web:32ef09cf29c0894649682a',
  messagingSenderId: '290349099295',
  storageBucket: 'hoopsync-app.firebasestorage.app',
  projectId: 'hoopsync-app',
  authDomain: 'hoopsync-app.firebaseapp.com',
);
