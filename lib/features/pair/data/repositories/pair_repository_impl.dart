import 'package:dartz/dartz.dart';
import 'package:secretpairapp/core/error/exceptions.dart';
import 'package:secretpairapp/core/error/failures.dart';
import 'package:secretpairapp/features/pair/data/sources/firestore_pair_source.dart';
import 'package:secretpairapp/features/pair/domain/entities/pair_user.dart';
import 'package:secretpairapp/features/pair/domain/repositories/pair_repository.dart';

class PairRepositoryImpl implements PairRepository {
  final FirestorePairSource _firestorePairSource;

  PairRepositoryImpl({
    required FirestorePairSource firestorePairSource,
  }) : _firestorePairSource = firestorePairSource;

  @override
  Future<Either<Failure, Pair>> createPair({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final pair = await _firestorePairSource.createPair(
        userId: userId,
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return Right(pair.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pair>> joinPair({
    required String inviteCode,
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final pair = await _firestorePairSource.joinPair(
        inviteCode: inviteCode,
        userId: userId,
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return Right(pair.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pair?>> getPairById(String pairId) async {
    try {
      final pair = await _firestorePairSource.getPairById(pairId);
      return Right(pair?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pair?>> getUserPair(String userId) async {
    try {
      final pair = await _firestorePairSource.getUserPair(userId);
      return Right(pair?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Pair>> watchPair(String pairId) {
    try {
      return _firestorePairSource.watchPair(pairId).map(
            (pair) => Right<Failure, Pair>(pair.toEntity()),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> leavePair(String pairId, String userId) async {
    try {
      await _firestorePairSource.leavePair(pairId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePair(String pairId) async {
    try {
      await _firestorePairSource.deletePair(pairId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
