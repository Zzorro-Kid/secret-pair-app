import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthSignInAnonymouslyEvent extends AuthEvent {}

class AuthSignOutEvent extends AuthEvent {}
