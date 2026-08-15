import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseService {
  FirebaseAuth get auth;

  FirebaseFirestore get firestore;

  User? get currentUser;

  String? get currentUserId;

  bool get isLoggedIn;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<UserCredential> register({
    required String email,
    required String password,
  });

  Future<void> signOut();

  CollectionReference<Map<String, dynamic>> collection(String path);

  DocumentReference<Map<String, dynamic>> document(String path);
}

class FirebaseServiceImpl implements FirebaseService {
  @override
  final FirebaseAuth auth;

  @override
  final FirebaseFirestore firestore;

  const FirebaseServiceImpl({required this.auth, required this.firestore});

  @override
  User? get currentUser => auth.currentUser;

  @override
  String? get currentUserId => currentUser?.uid;

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() {
    return auth.signOut();
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  @override
  DocumentReference<Map<String, dynamic>> document(String path) {
    return firestore.doc(path);
  }
}
