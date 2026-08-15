import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
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

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw const AuthException('فشل إنشاء حساب المستخدم.');
    }

    final user = UserModel(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      imageUrl: null,
      createdAt: DateTime.now(),
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

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw const AuthException('فشل تسجيل الدخول.');
    }

    final snapshot = await users.doc(firebaseUser.uid).get();

    final user = snapshot.data();

    if (user == null) {
      throw const ServerException('بيانات المستخدم غير موجودة.');
    }

    return user;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (!firebaseService.isLoggedIn) {
      return null;
    }

    final uid = firebaseService.currentUserId;

    if (uid == null || uid.isEmpty) {
      return null;
    }

    final snapshot = await users.doc(uid).get();

    return snapshot.data();
  }

  @override
  Future<void> logout() {
    return firebaseService.signOut();
  }
}
