import 'package:equatable/equatable.dart';

/// Entity для пользователя пары
class PairUser extends Equatable {
  final String userId;
  final String? displayName;
  final String? photoUrl;
  final DateTime joinedAt;

  const PairUser({
    required this.userId,
    this.displayName,
    this.photoUrl,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, displayName, photoUrl, joinedAt];

  @override
  String toString() {
    return 'PairUser(userId: $userId, displayName: $displayName, joinedAt: $joinedAt)';
  }
}

/// Entity для пары
class Pair extends Equatable {
  final String pairId;
  final String inviteCode;
  final PairUser creator;
  final PairUser? partner;
  final DateTime createdAt;
  final bool isActive;

  const Pair({
    required this.pairId,
    required this.inviteCode,
    required this.creator,
    this.partner,
    required this.createdAt,
    required this.isActive,
  });

  bool get isComplete => partner != null;

  @override
  List<Object?> get props => [
        pairId,
        inviteCode,
        creator,
        partner,
        createdAt,
        isActive,
      ];

  @override
  String toString() {
    return 'Pair(pairId: $pairId, inviteCode: $inviteCode, isComplete: $isComplete)';
  }
}
