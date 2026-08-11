import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl with FirebaseErrorHandler implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  }) {
    return executeSafely(
      () => remoteDataSource.login(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, AppUser>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) {
    return executeSafely(
      () => remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      ),
    );
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() {
    return executeSafely(() => remoteDataSource.getCurrentUser());
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return executeSafely(() async {
      await remoteDataSource.logout();
      return unit;
    });
  }
}
