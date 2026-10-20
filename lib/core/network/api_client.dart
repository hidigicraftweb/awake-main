import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/exceptions.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(_AuthInterceptor(secureStorage: _secureStorage));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> postMultipart(
    String path, {
    required FormData data,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> putMultipart(
    String path, {
    required FormData data,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        // Handle validation errors (422)
        if (statusCode == 422) {
          final errors = data['errors'] as Map<String, dynamic>?;
          final message = data['message'] as String? ?? 'Validation failed';
          return ValidationException(
            message: message,
            errors: errors?.map(
              (key, value) => MapEntry(
                key,
                (value as List).map((e) => e.toString()).toList(),
              ),
            ),
          );
        }

        // Handle auth errors (401)
        if (statusCode == 401) {
          final message =
              data['message'] as String? ?? 'Authentication failed';
          return AuthException(message: message);
        }

        // Handle forbidden (403)
        if (statusCode == 403) {
          final message = data['message'] as String? ?? 'Access denied';
          return AuthException(message: message);
        }

        // Handle not found (404)
        if (statusCode == 404) {
          final message = data['message'] as String? ?? 'Resource not found';
          return ServerException(message: message, statusCode: statusCode);
        }

        // Handle rate limiting (429)
        if (statusCode == 429) {
          return const ServerException(
            message: 'Too many requests. Please wait a moment.',
            statusCode: 429,
          );
        }

        final message = data['message'] as String? ?? 'Server error occurred';
        return ServerException(message: message, statusCode: statusCode);

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.unknown:
      default:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return const NetworkException(
            message: 'No internet connection. Please check your network.',
          );
        }
        return ServerException(
            message: e.message ?? 'An unexpected error occurred');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'auth_token';

  _AuthInterceptor({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add Bearer token to Authorization header if available
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Could add token refresh logic here for 401 errors
    handler.next(err);
  }
}
