import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secretpairapp/core/constants/firebase_collections.dart';
import 'package:secretpairapp/core/error/exceptions.dart';
import 'package:secretpairapp/features/pair/data/models/pair_user_model.dart';
import 'package:uuid/uuid.dart';

/// Data source для работы с парами в Firestore
class FirestorePairSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  FirestorePairSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Создать новую пару
  Future<PairModel> createPair({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // Генерируем уникальный 6-значный invite code
      final inviteCode = _generateInviteCode();

      // Создаем пользователя-создателя
      final creator = PairUserModel(
        userId: userId,
        displayName: displayName,
        photoUrl: photoUrl,
        joinedAt: DateTime.now(),
      );

      // Создаем пару
      final pairId = _uuid.v4();
      final pair = PairModel(
        pairId: pairId,
        inviteCode: inviteCode,
        creator: creator,
        partner: null,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Сохраняем в Firestore
      await _firestore
          .collection(FirebaseCollections.pairs)
          .doc(pairId)
          .set(pair.toJson());

      // Создаем индекс по invite code для быстрого поиска
      await _firestore
          .collection(FirebaseCollections.inviteCodes)
          .doc(inviteCode)
          .set({
        'pairId': pairId,
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });

      return pair;
    } catch (e) {
      throw ServerException('Failed to create pair: ${e.toString()}');
    }
  }

  /// Присоединиться к паре по invite code
  Future<PairModel> joinPair({
    required String inviteCode,
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // Ищем пару по invite code
      final inviteDoc = await _firestore
          .collection(FirebaseCollections.inviteCodes)
          .doc(inviteCode)
          .get();

      if (!inviteDoc.exists) {
        throw const ServerException('Invalid invite code');
      }

      final inviteData = inviteDoc.data()!;
      final pairId = inviteData['pairId'] as String;
      final isUsed = inviteData['used'] as bool? ?? false;

      if (isUsed) {
        throw const ServerException('Invite code already used');
      }

      // Получаем пару
      final pairDoc = await _firestore
          .collection(FirebaseCollections.pairs)
          .doc(pairId)
          .get();

      if (!pairDoc.exists) {
        throw const ServerException('Pair not found');
      }

      final pairData = pairDoc.data()!;

      // Проверяем, что пара еще не заполнена
      if (pairData['partner'] != null) {
        throw const ServerException('Pair already has a partner');
      }

      // Создаем пользователя-партнера
      final partner = PairUserModel(
        userId: userId,
        displayName: displayName,
        photoUrl: photoUrl,
        joinedAt: DateTime.now(),
      );

      // Обновляем пару
      await _firestore
          .collection(FirebaseCollections.pairs)
          .doc(pairId)
          .update({
        'partner': partner.toJson(),
        'isActive': true,
      });

      // Помечаем invite code как использованный
      await _firestore
          .collection(FirebaseCollections.inviteCodes)
          .doc(inviteCode)
          .update({'used': true});

      // Возвращаем обновленную пару
      final updatedPairDoc = await _firestore
          .collection(FirebaseCollections.pairs)
          .doc(pairId)
          .get();

      return PairModel.fromJson(updatedPairDoc.data()!, pairId);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to join pair: ${e.toString()}');
    }
  }

  /// Получить пару по ID
  Future<PairModel?> getPairById(String pairId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.pairs)
          .doc(pairId)
          .get();

      if (!doc.exists) return null;

      return PairModel.fromJson(doc.data()!, pairId);
    } catch (e) {
      throw ServerException('Failed to get pair: ${e.toString()}');
    }
  }

  /// Получить пару пользователя
  Future<PairModel?> getUserPair(String userId) async {
    try {
      // Ищем пару, где пользователь является создателем
      final creatorQuery = await _firestore
          .collection(FirebaseCollections.pairs)
          .where('creator.userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (creatorQuery.docs.isNotEmpty) {
        final doc = creatorQuery.docs.first;
        return PairModel.fromJson(doc.data(), doc.id);
      }

      // Ищем пару, где пользователь является партнером
      final partnerQuery = await _firestore
          .collection(FirebaseCollections.pairs)
          .where('partner.userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (partnerQuery.docs.isNotEmpty) {
        final doc = partnerQuery.docs.first;
        return PairModel.fromJson(doc.data(), doc.id);
      }

      return null;
    } catch (e) {
      throw ServerException('Failed to get user pair: ${e.toString()}');
    }
  }

  /// Отслеживать изменения пары
  Stream<PairModel> watchPair(String pairId) {
    return _firestore
        .collection(FirebaseCollections.pairs)
        .doc(pairId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw const ServerException('Pair not found');
      }
      return PairModel.fromJson(doc.data()!, pairId);
    });
  }

  /// Покинуть пару
  Future<void> leavePair(String pairId, String userId) async {
    try {
      final pairDoc = await _firestore
          .collection(FirebaseCollections.pairs)
          .doc(pairId)
          .get();

      if (!pairDoc.exists) {
        throw const ServerException('Pair not found');
      }

      final pairData = pairDoc.data()!;
      final creatorId = (pairData['creator'] as Map<String, dynamic>)['userId'];

      // Если уходит создатель, деактивируем пару
      if (creatorId == userId) {
        await _firestore
            .collection(FirebaseCollections.pairs)
            .doc(pairId)
            .update({'isActive': false});
      } else {
        // Если уходит партнер, удаляем его из пары
        await _firestore
            .collection(FirebaseCollections.pairs)
            .doc(pairId)
            .update({'partner': null});
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to leave pair: ${e.toString()}');
    }
  }

  /// Удалить пару (полностью)
  Future<void> deletePair(String pairId) async {
    try {
      final pairDoc = await _firestore
          .collection(FirebaseCollections.pairs)
          .doc(pairId)
          .get();

      if (pairDoc.exists) {
        final inviteCode =
            (pairDoc.data() as Map<String, dynamic>)['inviteCode'] as String;

        // Удаляем invite code
        await _firestore
            .collection(FirebaseCollections.inviteCodes)
            .doc(inviteCode)
            .delete();

        // Удаляем пару
        await _firestore
            .collection(FirebaseCollections.pairs)
            .doc(pairId)
            .delete();
      }
    } catch (e) {
      throw ServerException('Failed to delete pair: ${e.toString()}');
    }
  }

  /// Генерация 6-значного invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';

    for (var i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }

    return code;
  }
}
