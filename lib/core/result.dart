/// Professional error handling for NutriCare+
abstract class Result<T> {
  const Result();

  /// Handle success and failure
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(AppException error) onFailure,
  ) {
    if (this is Success<T>) {
      final success = this as Success<T>;
      return onSuccess(success.value);
    }
    if (this is Failure<T>) {
      final failure = this as Failure<T>;
      return onFailure(failure.exception);
    }
    throw StateError('Unknown Result type: $runtimeType');
  }

  /// Get value or null
  T? getOrNull() => fold((v) => v, (_) => null);

  /// Get error or null
  AppException? errorOrNull() => fold((_) => null, (e) => e);

  /// Is this a success?
  bool get isSuccess => this is Success<T>;

  /// Is this a failure?
  bool get isFailure => this is Failure<T>;
}

/// Success result
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Failure result
class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

/// Base exception for app
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Authentication errors
class AuthException extends AppException {
  AuthException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Network/API errors
class NetworkException extends AppException {
  final int? statusCode;

  NetworkException({
    required String message,
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Data/Validation errors
class DataException extends AppException {
  DataException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Firebase-specific errors
class FirebaseException extends AppException {
  FirebaseException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Generic app errors
class AppErrorException extends AppException {
  AppErrorException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalError: originalError,
    stackTrace: stackTrace,
  );
}
