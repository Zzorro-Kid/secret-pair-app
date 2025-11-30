/// Base Exception class
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Server/Firebase related exceptions
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Local storage related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}
