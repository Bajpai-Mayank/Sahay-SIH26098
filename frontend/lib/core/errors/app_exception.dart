/// Base typed exception hierarchy for SAHAY-AI.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Network communication error.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

/// Server returned an unauthorized (401) or forbidden (403) code.
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

/// Validation failure on input form or parameters.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

/// Server-side error (5xx).
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}

/// Offline cache or local persistent storage error.
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}
