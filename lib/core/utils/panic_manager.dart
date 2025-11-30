import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Менеджер для Panic Button - удаление всех данных одним касанием
class PanicManager {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  PanicManager({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
  })  : _firestore = firestore,
        _storage = storage,
        _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage;

  // ============================================================
  // Главная функция - полное удаление данных
  // ============================================================

  /// Полное удаление всех данных пользователя
  /// 
  /// Удаляет:
  /// - Сообщения из Firestore
  /// - Медиафайлы из Storage
  /// - Данные пары
  /// - Локальные данные (SharedPreferences, SecureStorage)
  /// - Пользовательский аккаунт (опционально)
  Future<PanicResult> wipeAllData({
    required String userId,
    String? pairId,
    bool deleteAccount = false,
  }) async {
    debugPrint('🚨 PANIC MODE: Starting data wipe for user: $userId');

    final stopwatch = Stopwatch()..start();
    final result = PanicResult();

    try {
      // 1. Удаление сообщений
      result.messagesDeleted = await _deleteMessages(pairId);
      debugPrint('✅ Messages deleted: ${result.messagesDeleted}');

      // 2. Удаление галереи
      result.galleryItemsDeleted = await _deleteGalleryItems(pairId);
      debugPrint('✅ Gallery items deleted: ${result.galleryItemsDeleted}');

      // 3. Удаление уведомлений
      result.notificationsDeleted = await _deleteNotifications(pairId);
      debugPrint('✅ Notifications deleted: ${result.notificationsDeleted}');

      // 4. Покинуть пару
      if (pairId != null) {
        await _leavePair(userId, pairId);
        result.pairLeft = true;
        debugPrint('✅ Left pair: $pairId');
      }

      // 5. Очистка локальных данных
      await _clearLocalData();
      result.localDataCleared = true;
      debugPrint('✅ Local data cleared');

      // 6. Удаление аккаунта (если требуется)
      if (deleteAccount) {
        await _deleteUserAccount(userId);
        result.accountDeleted = true;
        debugPrint('✅ Account deleted');
      }

      stopwatch.stop();
      result.success = true;
      result.executionTime = stopwatch.elapsedMilliseconds;

      debugPrint('🎉 PANIC MODE: Complete! Time: ${result.executionTime}ms');

      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ PANIC MODE: Error during wipe: $e');
      debugPrint('Stack trace: $stackTrace');

      result.success = false;
      result.error = e.toString();

      return result;
    }
  }

  // ============================================================
  // Удаление сообщений
  // ============================================================

  Future<int> _deleteMessages(String? pairId) async {
    if (pairId == null) return 0;

    try {
      final messagesSnapshot = await _firestore
          .collection('pairs')
          .doc(pairId)
          .collection('messages')
          .get();

      int count = 0;
      
      // Удаляем сообщения батчами (по 500 за раз)
      final batches = <WriteBatch>[];
      WriteBatch currentBatch = _firestore.batch();
      int operationsInBatch = 0;

      for (final doc in messagesSnapshot.docs) {
        currentBatch.delete(doc.reference);
        operationsInBatch++;
        count++;

        // Firebase Batch может содержать максимум 500 операций
        if (operationsInBatch >= 500) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationsInBatch = 0;
        }
      }

      // Добавляем последний батч, если есть операции
      if (operationsInBatch > 0) {
        batches.add(currentBatch);
      }

      // Выполняем все батчи
      for (final batch in batches) {
        await batch.commit();
      }

      return count;
    } catch (e) {
      debugPrint('❌ Error deleting messages: $e');
      return 0;
    }
  }

  // ============================================================
  // Удаление галереи
  // ============================================================

  Future<int> _deleteGalleryItems(String? pairId) async {
    if (pairId == null) return 0;

    try {
      // Получаем список файлов из Firestore
      final gallerySnapshot = await _firestore
          .collection('pairs')
          .doc(pairId)
          .collection('gallery')
          .get();

      int count = 0;

      for (final doc in gallerySnapshot.docs) {
        final data = doc.data();
        final storagePath = data['storagePath'] as String?;

        // Удаляем файл из Storage
        if (storagePath != null) {
          try {
            await _storage.ref(storagePath).delete();
            debugPrint('🗑️ Deleted from storage: $storagePath');
          } catch (e) {
            debugPrint('⚠️ Could not delete from storage: $storagePath - $e');
          }
        }

        // Удаляем документ из Firestore
        await doc.reference.delete();
        count++;
      }

      return count;
    } catch (e) {
      debugPrint('❌ Error deleting gallery items: $e');
      return 0;
    }
  }

  // ============================================================
  // Удаление уведомлений
  // ============================================================

  Future<int> _deleteNotifications(String? pairId) async {
    if (pairId == null) return 0;

    try {
      final notificationsSnapshot = await _firestore
          .collection('pairs')
          .doc(pairId)
          .collection('notifications')
          .get();

      int count = 0;

      for (final doc in notificationsSnapshot.docs) {
        await doc.reference.delete();
        count++;
      }

      return count;
    } catch (e) {
      debugPrint('❌ Error deleting notifications: $e');
      return 0;
    }
  }

  // ============================================================
  // Выход из пары
  // ============================================================

  Future<void> _leavePair(String userId, String pairId) async {
    try {
      // Обновляем документ пары
      final pairDoc = await _firestore.collection('pairs').doc(pairId).get();

      if (pairDoc.exists) {
        final data = pairDoc.data()!;
        final user1Id = data['user1Id'] as String?;
        final user2Id = data['user2Id'] as String?;

        // Если это единственный пользователь или оба покидают - удаляем пару
        if (user1Id == userId && user2Id == null) {
          await _firestore.collection('pairs').doc(pairId).delete();
          debugPrint('🗑️ Pair deleted completely');
        } else if (user1Id == userId) {
          // Пользователь 1 покидает
          await _firestore.collection('pairs').doc(pairId).update({
            'user1Id': FieldValue.delete(),
            'leftAt': FieldValue.serverTimestamp(),
          });
        } else if (user2Id == userId) {
          // Пользователь 2 покидает
          await _firestore.collection('pairs').doc(pairId).update({
            'user2Id': FieldValue.delete(),
            'leftAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Удаляем инвайт-коды
      final inviteCodesSnapshot = await _firestore
          .collection('invite_codes')
          .where('pairId', isEqualTo: pairId)
          .get();

      for (final doc in inviteCodesSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('❌ Error leaving pair: $e');
    }
  }

  // ============================================================
  // Очистка локальных данных
  // ============================================================

  Future<void> _clearLocalData() async {
    try {
      // Очистка SharedPreferences
      await _sharedPreferences.clear();
      debugPrint('✅ SharedPreferences cleared');

      // Очистка SecureStorage
      await _secureStorage.deleteAll();
      debugPrint('✅ SecureStorage cleared');
    } catch (e) {
      debugPrint('❌ Error clearing local data: $e');
      rethrow;
    }
  }

  // ============================================================
  // Удаление аккаунта
  // ============================================================

  Future<void> _deleteUserAccount(String userId) async {
    try {
      // Удаление документа пользователя
      await _firestore.collection('users').doc(userId).delete();

      // Удаление аккаунта Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }
    } catch (e) {
      debugPrint('❌ Error deleting user account: $e');
      rethrow;
    }
  }

  // ============================================================
  // Частичная очистка (для отладки или настраиваемого удаления)
  // ============================================================

  /// Удалить только сообщения
  Future<bool> deleteMessagesOnly(String pairId) async {
    try {
      await _deleteMessages(pairId);
      return true;
    } catch (e) {
      debugPrint('❌ Error in deleteMessagesOnly: $e');
      return false;
    }
  }

  /// Удалить только галерею
  Future<bool> deleteGalleryOnly(String pairId) async {
    try {
      await _deleteGalleryItems(pairId);
      return true;
    } catch (e) {
      debugPrint('❌ Error in deleteGalleryOnly: $e');
      return false;
    }
  }

  /// Очистить только локальные данные
  Future<bool> clearLocalDataOnly() async {
    try {
      await _clearLocalData();
      return true;
    } catch (e) {
      debugPrint('❌ Error in clearLocalDataOnly: $e');
      return false;
    }
  }
}

// ============================================================
// Модель результата выполнения Panic Mode
// ============================================================

class PanicResult {
  bool success = false;
  String? error;
  int executionTime = 0;

  int messagesDeleted = 0;
  int galleryItemsDeleted = 0;
  int notificationsDeleted = 0;
  bool pairLeft = false;
  bool localDataCleared = false;
  bool accountDeleted = false;

  @override
  String toString() {
    return '''
PanicResult(
  success: $success,
  error: $error,
  executionTime: ${executionTime}ms,
  messagesDeleted: $messagesDeleted,
  galleryItemsDeleted: $galleryItemsDeleted,
  notificationsDeleted: $notificationsDeleted,
  pairLeft: $pairLeft,
  localDataCleared: $localDataCleared,
  accountDeleted: $accountDeleted,
)''';
  }
}
