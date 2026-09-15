import 'package:firebase_core/firebase_core.dart';

/// Web config for WorkIt's own Firebase project (`workit-supremolabs`),
/// used only by /workit/desk — this site's own data lives in the separate
/// `supremolabs` project, so the desk talks to WorkIt's Firestore through
/// its own named [FirebaseApp], same as PlanSync's and Stanverse's desks.
///
/// The Web app behind this config ("WorkIt Desk (supremolabs)") exists
/// purely so this page can read that project; WorkIt itself ships iOS only.
const workItFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAoaAKsgDzP3sGogb4VYmrFsWJrh5lcqa4',
  appId: '1:924315830338:web:a0a57222948236ccf205db',
  messagingSenderId: '924315830338',
  projectId: 'workit-supremolabs',
  authDomain: 'workit-supremolabs.firebaseapp.com',
  storageBucket: 'workit-supremolabs.firebasestorage.app',
);
