import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecase/get_current_user_usecase.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../domain/usecase/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await loginUseCase(email: email, password: password);

    result.fold(
      (failure) => _emitFailure(failure.message),
      (user) => _emitAuthenticated(user),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );

    result.fold(
      (failure) => _emitFailure(failure.message),
      (user) => _emitAuthenticated(user),
    );
  }

  Future<void> getCurrentUser() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await getCurrentUserUseCase();

    result.fold((failure) => _emitFailure(failure.message), (user) {
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      } else {
        _emitAuthenticated(user);
      }
    });
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await logoutUseCase();

    result.fold(
      (failure) => _emitFailure(failure.message),
      (_) => emit(const AuthState(status: AuthStatus.unauthenticated)),
    );
  }

  void resetState() {
    emit(state.copyWith(status: AuthStatus.initial, message: null));
  }

  void _emitAuthenticated(AppUser user) {
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  void _emitFailure(String message) {
    emit(state.copyWith(status: AuthStatus.failure, message: message));
  }
}