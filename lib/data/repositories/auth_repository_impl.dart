import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AuthResult>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? gender,
    File? photo,
  }) async {
    try {
      final authResult = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        gender: gender,
        photo: photo,
      );

      // Cache token and user data
      await _localDataSource.cacheToken(authResult.token);
      await _localDataSource.cacheUser(authResult.user);

      return Right(authResult.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, LoginOtpRequired>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      return Right(LoginOtpRequired(
        email: result.email,
        expiresInMinutes: result.expiresInMinutes,
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyLoginOtp({
    required String email,
    required String code,
  }) async {
    try {
      final authResult = await _remoteDataSource.verifyLoginOtp(
        email: email,
        code: code,
      );

      // Cache credentials after successful OTP verification
      await _localDataSource.cacheToken(authResult.token);
      await _localDataSource.cacheUser(authResult.user);

      return Right(authResult.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearCache();
      return const Right(null);
    } on NetworkException catch (e) {
      // Clear cache even on network failure
      await _localDataSource.clearCache();
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      await _localDataSource.clearCache();
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      await _localDataSource.clearCache();
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on NetworkException catch (e) {
      // Graceful fallback to cached user
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      await _localDataSource.clearCache();
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.isLoggedIn();
  }

  @override
  Future<User?> getCachedUser() async {
    return await _localDataSource.getCachedUser();
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? gender,
    File? photo,
    bool removePhoto = false,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        photo: photo,
        removePhoto: removePhoto,
      );

      await _localDataSource.cacheUser(user);
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp({required String email}) async {
    try {
      await _remoteDataSource.sendOtp(email: email);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      await _remoteDataSource.verifyOtp(email: email, code: code);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email: email,
        code: code,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, UserStats>> getUserStats() async {
    try {
      final stats = await _remoteDataSource.getUserStats();
      return Right(stats);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }
}
