import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secretpairapp/features/pair/domain/entities/pair_user.dart';

/// Model для пользователя пары
class PairUserModel extends PairUser {
  const PairUserModel({
    required super.userId,
    super.displayName,
    super.photoUrl,
    required super.joinedAt,
  });

  /// Создание модели из JSON
  factory PairUserModel.fromJson(Map<String, dynamic> json) {
    return PairUserModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
    );
  }

  /// Создание модели из Entity
  factory PairUserModel.fromEntity(PairUser entity) {
    return PairUserModel(
      userId: entity.userId,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      joinedAt: entity.joinedAt,
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  /// Преобразование в Entity
  PairUser toEntity() {
    return PairUser(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      joinedAt: joinedAt,
    );
  }
}

/// Model для пары
class PairModel extends Pair {
  const PairModel({
    required super.pairId,
    required super.inviteCode,
    required super.creator,
    super.partner,
    required super.createdAt,
    required super.isActive,
  });

  /// Создание модели из JSON
  factory PairModel.fromJson(Map<String, dynamic> json, String pairId) {
    return PairModel(
      pairId: pairId,
      inviteCode: json['inviteCode'] as String,
      creator: PairUserModel.fromJson(json['creator'] as Map<String, dynamic>),
      partner: json['partner'] != null
          ? PairUserModel.fromJson(json['partner'] as Map<String, dynamic>)
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Создание модели из Entity
  factory PairModel.fromEntity(Pair entity) {
    return PairModel(
      pairId: entity.pairId,
      inviteCode: entity.inviteCode,
      creator: entity.creator,
      partner: entity.partner,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'inviteCode': inviteCode,
      'creator': PairUserModel.fromEntity(creator).toJson(),
      'partner': partner != null
          ? PairUserModel.fromEntity(partner!).toJson()
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  /// Преобразование в Entity
  Pair toEntity() {
    return Pair(
      pairId: pairId,
      inviteCode: inviteCode,
      creator: creator,
      partner: partner,
      createdAt: createdAt,
      isActive: isActive,
    );
  }
}
