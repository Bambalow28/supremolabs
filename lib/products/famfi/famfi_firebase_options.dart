// Firebase project juwa-wealth-app — the same project juwa_wealth (the
// phone app) syncs through. Web app "FamFi Console"
// (1:107814236201:web:ab5dcf19260cdc5f7aac38), created via
// `firebase apps:create web`. Initialized as the named app 'famfi' in
// main.dart; the console points juwa_wealth's syncDb and its own auth at it.
import 'package:firebase_core/firebase_core.dart';

const famFiFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAFowGU8G9sHDuA9-zgDdEMfT3inDUfIi4',
  appId: '1:107814236201:web:ab5dcf19260cdc5f7aac38',
  messagingSenderId: '107814236201',
  projectId: 'juwa-wealth-app',
  authDomain: 'juwa-wealth-app.firebaseapp.com',
  storageBucket: 'juwa-wealth-app.firebasestorage.app',
);
