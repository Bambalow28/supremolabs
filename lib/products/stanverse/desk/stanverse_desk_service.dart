import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Stanverse's own Firebase app (`stanverse-fanapp`), separate from
/// supremolabs' own — the desk reads and writes the exact data the iOS
/// app reads, so what's entered here is what ships.
FirebaseFirestore get stanverseDb =>
    FirebaseFirestore.instanceFor(app: Firebase.app('stanverse'));
FirebaseStorage get stanverseStorage =>
    FirebaseStorage.instanceFor(app: Firebase.app('stanverse'));

/// Same key derivation as stanverse's own lib/services/artist_ref.dart —
/// keep these in sync, they resolve to the same Firestore docs.
String slugify(String name) => name
    .toLowerCase()
    .trim()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
