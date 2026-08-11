import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';

import '../../features/auth/domain/usecase/get_current_user_usecase.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/logout_usecase.dart';
import '../../features/auth/domain/usecase/register_usecase.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance;

void setupAuthLocator() {
  //==========================================================
  // Data Source
  //==========================================================

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseService: getIt()),
    );
  }

  //==========================================================
  // Repository
  //==========================================================

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt()),
    );
  }

  //==========================================================
  // UseCases
  //==========================================================

  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton(() => LoginUseCase(repository: getIt()));
  }

  if (!getIt.isRegistered<RegisterUseCase>()) {
    getIt.registerLazySingleton(() => RegisterUseCase(repository: getIt()));
  }

  if (!getIt.isRegistered<LogoutUseCase>()) {
    getIt.registerLazySingleton(() => LogoutUseCase(repository: getIt()));
  }

  if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
    getIt.registerLazySingleton(
      () => GetCurrentUserUseCase(repository: getIt()),
    );
  }

  //==========================================================
  // Cubit
  //==========================================================

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory(
      () => AuthCubit(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        logoutUseCase: getIt(),
        getCurrentUserUseCase: getIt(),
      ),
    );
  }
}
