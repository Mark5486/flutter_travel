import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase({required this.repository});

  Future<Either<Failure, AppUser?>> call() {
    return repository.getCurrentUser();
  }
}
