import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  User? _currentUser;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthVerifyLoginOtpRequested>(_onAuthVerifyLoginOtpRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthStateReset>(_onAuthStateReset);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthChangePasswordRequested>(_onAuthChangePasswordRequested);
    on<AuthSendOtpRequested>(_onAuthSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onAuthVerifyOtpRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthUserStatsFetchRequested>(_onAuthUserStatsFetchRequested);
  }

  User? get currentUser => _currentUser;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isLoggedIn = await _authRepository.isLoggedIn();
    if (!isLoggedIn) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        _currentUser = null;
        emit(const AuthUnauthenticated());
      },
      (user) {
        _currentUser = user;
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      phone: event.phone,
      gender: event.gender,
      photo: event.photo,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (authResult) {
        _currentUser = authResult.user;
        emit(AuthAuthenticated(user: authResult.user));
      },
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (loginOtpRequired) {
        emit(AuthLoginOtpRequired(
          email: loginOtpRequired.email,
          expiresInMinutes: loginOtpRequired.expiresInMinutes,
        ));
      },
    );
  }

  Future<void> _onAuthVerifyLoginOtpRequested(
    AuthVerifyLoginOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.verifyLoginOtp(
      email: event.email,
      code: event.code,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (authResult) {
        _currentUser = authResult.user;
        emit(AuthAuthenticated(user: authResult.user));
      },
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    _currentUser = null;
    emit(const AuthUnauthenticated());
  }

  void _onAuthStateReset(
    AuthStateReset event,
    Emitter<AuthState> emit,
  ) {
    if (_currentUser != null) {
      emit(AuthAuthenticated(user: _currentUser!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.updateProfile(
      name: event.name,
      email: event.email,
      phone: event.phone,
      gender: event.gender,
      photo: event.photo,
      removePhoto: event.removePhoto,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (user) {
        _currentUser = user;
        emit(AuthProfileUpdated(user: user));
      },
    );
  }

  Future<void> _onAuthChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      newPasswordConfirmation: event.newPasswordConfirmation,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (_) {
        if (_currentUser != null) {
          emit(AuthPasswordChanged(user: _currentUser!));
        }
      },
    );
  }

  Future<void> _onAuthSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.sendOtp(email: event.email);

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (_) => emit(AuthOtpSent(email: event.email)),
    );
  }

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.verifyOtp(
      email: event.email,
      code: event.code,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (_) => emit(AuthOtpVerified(email: event.email)),
    );
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.forgotPassword(email: event.email);

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (_) => emit(AuthPasswordResetRequested(email: event.email)),
    );
  }

  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.resetPassword(
      email: event.email,
      code: event.code,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  Future<void> _onAuthUserStatsFetchRequested(
    AuthUserStatsFetchRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.getUserStats();

    result.fold(
      (failure) {
        // Silently fail - just don't update stats
      },
      (stats) => emit(AuthUserStatsLoaded(stats: stats)),
    );
  }

  AuthError _mapFailureToAuthError(Failure failure) {
    if (failure is ValidationFailure) {
      return AuthError(
        message: failure.message,
        validationErrors: failure.errors,
      );
    }
    return AuthError(message: failure.message);
  }
}
