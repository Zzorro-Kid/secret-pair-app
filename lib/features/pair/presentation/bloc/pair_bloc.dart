import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secretpairapp/features/pair/domain/usecases/create_pair_usecase.dart';
import 'package:secretpairapp/features/pair/domain/usecases/join_pair_usecase.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_event.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_state.dart';

class PairBloc extends Bloc<PairEvent, PairState> {
  final CreatePairUseCase createPairUseCase;
  final JoinPairUseCase joinPairUseCase;

  PairBloc({
    required this.createPairUseCase,
    required this.joinPairUseCase,
  }) : super(PairInitial()) {
    on<CreatePairEvent>(_onCreatePair);
    on<JoinPairEvent>(_onJoinPair);
    on<ResetPairEvent>(_onResetPair);
  }

  Future<void> _onCreatePair(
    CreatePairEvent event,
    Emitter<PairState> emit,
  ) async {
    emit(PairLoading());

    final result = await createPairUseCase(
      userId: event.userId,
      displayName: event.displayName,
      photoUrl: event.photoUrl,
    );

    result.fold(
      (failure) => emit(PairError(failure.message)),
      (pair) => emit(PairCreated(pair)),
    );
  }

  Future<void> _onJoinPair(
    JoinPairEvent event,
    Emitter<PairState> emit,
  ) async {
    emit(PairLoading());

    final result = await joinPairUseCase(
      inviteCode: event.inviteCode,
      userId: event.userId,
      displayName: event.displayName,
      photoUrl: event.photoUrl,
    );

    result.fold(
      (failure) => emit(PairError(failure.message)),
      (pair) => emit(PairJoined(pair)),
    );
  }

  void _onResetPair(
    ResetPairEvent event,
    Emitter<PairState> emit,
  ) {
    emit(PairInitial());
  }
}
