import 'package:dartz/dartz.dart';
import 'package:secretpairapp/core/error/failures.dart';
import 'package:secretpairapp/features/pair/domain/entities/pair_user.dart';

abstract class PairRepository {
  /// Создать новую пару
  Future<Either<Failure, Pair>> createPair({
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  /// Присоединиться к паре по invite code
  Future<Either<Failure, Pair>> joinPair({
    required String inviteCode,
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  /// Получить пару по ID
  Future<Either<Failure, Pair?>> getPairById(String pairId);

  /// Получить пару пользователя
  Future<Either<Failure, Pair?>> getUserPair(String userId);

  /// Отслеживать изменения пары в реальном времени
  Stream<Either<Failure, Pair>> watchPair(String pairId);

  /// Покинуть пару
  Future<Either<Failure, void>> leavePair(String pairId, String userId);

  /// Удалить пару полностью
  Future<Either<Failure, void>> deletePair(String pairId);
}
