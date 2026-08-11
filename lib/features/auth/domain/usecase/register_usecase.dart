import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase({required this.repository});

  Future<Either<Failure, AppUser>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
  }
}
