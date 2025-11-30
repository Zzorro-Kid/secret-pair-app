import 'package:equatable/equatable.dart';

/// Base Failure class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

/// Server/Firebase related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Local storage related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
