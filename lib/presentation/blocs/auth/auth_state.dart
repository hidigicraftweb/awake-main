import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_stats.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - unknown auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - processing auth request
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is logged in
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state - user is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state - auth operation failed
class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? validationErrors;

  const AuthError({
    required this.message,
    this.validationErrors,
  });

  /// Get field-specific validation error
  String? getFieldError(String field) {
    return validationErrors?[field]?.first;
  }

  @override
  List<Object?> get props => [message, validationErrors];
}

/// Password changed successfully
class AuthPasswordChanged extends AuthState {
  final User user;

  const AuthPasswordChanged({required this.user});

  @override
  List<Object?> get props => [user];
}

/// OTP sent successfully
class AuthOtpSent extends AuthState {
  final String email;

  const AuthOtpSent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Login OTP required - credentials valid, need OTP verification
class AuthLoginOtpRequired extends AuthState {
  final String email;
  final int expiresInMinutes;

  const AuthLoginOtpRequired({
    required this.email,
    required this.expiresInMinutes,
  });

  @override
  List<Object?> get props => [email, expiresInMinutes];
}

/// OTP verified successfully
class AuthOtpVerified extends AuthState {
  final String email;

  const AuthOtpVerified({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Password reset requested (OTP sent for reset)
class AuthPasswordResetRequested extends AuthState {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Password reset successful
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

/// Profile updated successfully
class AuthProfileUpdated extends AuthState {
  final User user;

  const AuthProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// User stats loaded
class AuthUserStatsLoaded extends AuthState {
  final UserStats stats;

  const AuthUserStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}
