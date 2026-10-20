import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/entities/user_stats.dart';
import '../models/user_model.dart';

/// Response class for login that requires OTP verification
class LoginOtpRequiredResponse {
  final String email;
  final int expiresInMinutes;

  LoginOtpRequiredResponse({
    required this.email,
    required this.expiresInMinutes,
  });
}

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? gender,
    File? photo,
  });

  /// Login - returns LoginOtpRequiredResponse (OTP will be sent to email)
  Future<LoginOtpRequiredResponse> login({
    required String email,
    required String password,
  });

  /// Verify OTP after login to complete authentication
  Future<AuthResultModel> verifyLoginOtp({
    required String email,
    required String code,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? gender,
    File? photo,
    bool removePhoto = false,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<void> sendOtp({required String email});

  Future<void> verifyOtp({required String email, required String code});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });

  Future<UserStats> getUserStats();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthResultModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? gender,
    File? photo,
  }) async {
    // Build form data for multipart (handles file uploads)
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (photo != null)
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'profile_photo.jpg',
        ),
    });

    final response = await _apiClient.postMultipart(
      ApiEndpoints.register,
      data: formData,
    );

    final responseData = response.data as Map<String, dynamic>;
    return AuthResultModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<LoginOtpRequiredResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    return LoginOtpRequiredResponse(
      email: data['email'] as String,
      expiresInMinutes: data['expires_in_minutes'] as int,
    );
  }

  @override
  Future<AuthResultModel> verifyLoginOtp({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.loginVerifyOtp,
      data: {
        'email': email,
        'code': code,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    return AuthResultModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.user);
    final responseData = response.data as Map<String, dynamic>;
    return UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? gender,
    File? photo,
    bool removePhoto = false,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (removePhoto) 'remove_photo': true,
      if (photo != null)
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'profile_photo.jpg',
        ),
    });

    final response = await _apiClient.putMultipart(
      ApiEndpoints.updateProfile,
      data: formData,
    );

    final responseData = response.data as Map<String, dynamic>;
    return UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _apiClient.post(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );
  }

  @override
  Future<void> sendOtp({required String email}) async {
    await _apiClient.post(
      ApiEndpoints.otpSend,
      data: {'email': email},
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    await _apiClient.post(
      ApiEndpoints.otpVerify,
      data: {
        'email': email,
        'code': code,
      },
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  @override
  Future<UserStats> getUserStats() async {
    final response = await _apiClient.get(ApiEndpoints.userStats);
    final responseData = response.data as Map<String, dynamic>;
    return UserStats.fromJson(responseData['data'] as Map<String, dynamic>);
  }
}
