import 'package:dartz/dartz.dart';
import 'package:secretpairapp/core/error/failures.dart';
import 'package:secretpairapp/features/pair/domain/entities/pair_user.dart';
import 'package:secretpairapp/features/pair/domain/repositories/pair_repository.dart';

class CreatePairUseCase {
  final PairRepository _repository;

  CreatePairUseCase(this._repository);

  Future<Either<Failure, Pair>> call({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    return await _repository.createPair(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
