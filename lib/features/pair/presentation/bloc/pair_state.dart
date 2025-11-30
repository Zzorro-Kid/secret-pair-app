import 'package:equatable/equatable.dart';
import 'package:secretpairapp/features/pair/domain/entities/pair_user.dart';

abstract class PairState extends Equatable {
  const PairState();

  @override
  List<Object?> get props => [];
}

class PairInitial extends PairState {}

class PairLoading extends PairState {}

class PairCreated extends PairState {
  final Pair pair;

  const PairCreated(this.pair);

  @override
  List<Object?> get props => [pair];
}

class PairJoined extends PairState {
  final Pair pair;

  const PairJoined(this.pair);

  @override
  List<Object?> get props => [pair];
}

class PairError extends PairState {
  final String message;

  const PairError(this.message);

  @override
  List<Object?> get props => [message];
}
