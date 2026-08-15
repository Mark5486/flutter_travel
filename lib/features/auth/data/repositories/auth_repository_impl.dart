import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl with FirebaseErrorHandler implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  }) {
    return executeSafely(() async {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      await localDataSource.saveUser(UserModel.fromEntity(user));

      return user;
    });
  }

  @override
  Future<Either<Failure, AppUser>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) {
    return executeSafely(() async {
      final user = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      await localDataSource.saveUser(UserModel.fromEntity(user));

      return user;
    });
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() {
    return executeSafely(() async {
      final cachedUser = localDataSource.getUser();

      if (cachedUser != null) {
        return cachedUser.toEntity();
      }

      final user = await remoteDataSource.getCurrentUser();

      if (user != null) {
        await localDataSource.saveUser(UserModel.fromEntity(user));
      }

      return user;
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return executeSafely(() async {
      await remoteDataSource.logout();
      await localDataSource.clearUser();

      return unit;
    });
  }
}
