import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  });

  Future<Either<Failure, AppUser?>> getCurrentUser();

  Future<Either<Failure, Unit>> logout();
}