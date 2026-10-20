import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status on app startup
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Register a new user
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? phone;
  final String? gender;
  final File? photo;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.phone,
    this.gender,
    this.photo,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        passwordConfirmation,
        phone,
        gender,
        photo,
      ];
}

/// Login with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Logout the current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Reset auth state (clear errors)
class AuthStateReset extends AuthEvent {
  const AuthStateReset();
}

class AuthUserStatsFetchRequested extends AuthEvent {
  const AuthUserStatsFetchRequested();
}

/// Update user profile
class AuthUpdateProfileRequested extends AuthEvent {
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final File? photo;
  final bool removePhoto;

  const AuthUpdateProfileRequested({
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.photo,
    this.removePhoto = false,
  });

  @override
  List<Object?> get props => [name, email, phone, gender, photo, removePhoto];
}

/// Change password
class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, newPasswordConfirmation];
}

/// Send OTP to email
class AuthSendOtpRequested extends AuthEvent {
  final String email;

  const AuthSendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Verify OTP (for email verification after registration)
class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerifyOtpRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

/// Verify login OTP (2FA after login)
class AuthVerifyLoginOtpRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerifyLoginOtpRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

/// Request password reset
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Reset password with OTP
class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String password;
  final String passwordConfirmation;

  const AuthResetPasswordRequested({
    required this.email,
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [email, code, password, passwordConfirmation];
}
