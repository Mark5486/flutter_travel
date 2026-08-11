import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase({required this.repository});

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
