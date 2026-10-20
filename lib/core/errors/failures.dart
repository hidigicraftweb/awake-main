import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network error. Please check your connection.',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
  });

  String? getFieldError(String field) {
    return errors?[field]?.first;
  }

  String get firstError {
    if (errors == null || errors!.isEmpty) return message;
    final firstField = errors!.keys.first;
    final fieldErrors = errors![firstField];
    if (fieldErrors == null || fieldErrors.isEmpty) return message;
    return fieldErrors.first;
  }

  @override
  List<Object?> get props => [message, errors];
}
