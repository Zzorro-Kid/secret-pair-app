import 'package:equatable/equatable.dart';
import 'package:secretpairapp/features/pair/domain/entities/pair_user.dart';

abstract class PairEvent extends Equatable {
  const PairEvent();

  @override
  List<Object?> get props => [];
}

class CreatePairEvent extends PairEvent {
  final String userId;
  final String? displayName;
  final String? photoUrl;

  const CreatePairEvent({
    required this.userId,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, displayName, photoUrl];
}

class JoinPairEvent extends PairEvent {
  final String inviteCode;
  final String userId;
  final String? displayName;
  final String? photoUrl;

  const JoinPairEvent({
    required this.inviteCode,
    required this.userId,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [inviteCode, userId, displayName, photoUrl];
}

class PairCreatedEvent extends PairEvent {
  final Pair pair;

  const PairCreatedEvent(this.pair);

  @override
  List<Object?> get props => [pair];
}

class PairJoinedEvent extends PairEvent {
  final Pair pair;

  const PairJoinedEvent(this.pair);

  @override
  List<Object?> get props => [pair];
}

class ResetPairEvent extends PairEvent {}
