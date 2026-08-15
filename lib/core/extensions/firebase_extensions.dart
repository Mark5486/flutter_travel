import 'package:firebase_auth/firebase_auth.dart';

extension FirebaseUserExtension on User {
  String get safeEmail => email ?? '';

  bool get isVerified => emailVerified;
}

extension FirebaseAuthExtension on FirebaseAuth {
  bool get isLoggedIn => currentUser != null;

  String? get currentUserId => currentUser?.uid;
}
