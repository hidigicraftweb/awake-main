class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Server error occurred',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Network error occurred. Please check your connection.',
  });

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Cache error occurred',
  });

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException({
    this.message = 'Authentication failed',
  });

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;

  const ValidationException({
    this.message = 'Validation failed',
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}
