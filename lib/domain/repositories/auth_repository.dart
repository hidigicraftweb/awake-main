import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../entities/user_stats.dart';

abstract class AuthRepository {
  /// Register a new user
  Future<Either<Failure, AuthResult>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? gender,
    File? photo,
  });

  /// Login with email and password - returns LoginOtpRequired (OTP sent to email)
  Future<Either<Failure, LoginOtpRequired>> login({
    required String email,
    required String password,
  });

  /// Verify OTP after login to complete authentication
  Future<Either<Failure, AuthResult>> verifyLoginOtp({
    required String email,
    required String code,
  });

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user from API
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is logged in (has token)
  Future<bool> isLoggedIn();

  /// Get cached user from local storage
  Future<User?> getCachedUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? gender,
    File? photo,
    bool removePhoto = false,
  });

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  /// Send OTP to email
  Future<Either<Failure, void>> sendOtp({
    required String email,
  });

  /// Verify OTP
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
  });

  /// Request password reset (forgot password)
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  /// Reset password with OTP
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });

  /// Get user statistics
  Future<Either<Failure, UserStats>> getUserStats();
}
