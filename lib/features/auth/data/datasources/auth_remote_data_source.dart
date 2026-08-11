import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/app_user.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  });

  Future<AppUser?> getCurrentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseService firebaseService;

  const AuthRemoteDataSourceImpl({required this.firebaseService});

  CollectionReference<UserModel> get users => firebaseService
      .collection(FirestoreCollections.users)
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      );

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final credential = await firebaseService.register(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      imageUrl: null,
      createdAt: null,
    );

    await users.doc(user.uid).set(user);

    return user;
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseService.signIn(
      email: email,
      password: password,
    );

    final snapshot = await users.doc(credential.user!.uid).get();

    final user = snapshot.data();

    if (user == null) {
      throw Exception('User data not found.');
    }

    return user;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (!firebaseService.isLoggedIn) {
      return null;
    }

    final snapshot = await users.doc(firebaseService.currentUserId!).get();

    return snapshot.data();
  }

  @override
  Future<void> logout() {
    return firebaseService.signOut();
  }
}
