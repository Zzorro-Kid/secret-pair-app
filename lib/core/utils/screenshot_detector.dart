import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Детектор скриншотов с уведомлениями для обоих пользователей пары
class ScreenshotDetector {
  final FirebaseFirestore _firestore;
  final SharedPreferences _sharedPreferences;

  static const String _lastScreenshotTimeKey = 'last_screenshot_time';
  static const MethodChannel _screenshotChannel = MethodChannel(
    'screenshot_detector',
  );

  String? _currentPairId;
  String? _currentUserId;

  ScreenshotDetector({
    required FirebaseFirestore firestore,
    required SharedPreferences sharedPreferences,
  }) : _firestore = firestore,
       _sharedPreferences = sharedPreferences;

  /// Инициализация детектора скриншотов
  Future<void> initialize() async {
    try {
      // Включаем защиту от скриншотов (опционально, можно отключить)
      await _enableScreenProtection();

      // Слушаем события скриншотов
      _listenToScreenshots();
    } catch (e) {
      debugPrint('❌ Screenshot detector initialization error: $e');
    }
  }

  /// Установка текущей пары и пользователя
  void setPairInfo(String pairId, String userId) {
    _currentPairId = pairId;
    _currentUserId = userId;
  }

  /// Очистка информации о паре
  void clearPairInfo() {
    _currentPairId = null;
    _currentUserId = null;
  }

  /// Включение защиты экрана (опционально)
  Future<void> _enableScreenProtection() async {
    try {
      // Защита от скриншотов (можно отключить, если нужны уведомления, а не блокировка)
      // await ScreenProtector.protectDataLeakageOn();

      // Альтернатива: только отслеживаем, но не блокируем
      await ScreenProtector.protectDataLeakageWithColor(Colors.transparent);
    } catch (e) {
      debugPrint('⚠️ Screen protection not available: $e');
    }
  }

  /// Слушаем события скриншотов
  void _listenToScreenshots() {
    try {
      // Используем addListener вместо screenshotStream
      ScreenProtector.addListener(
        () {
          // Колбэк при скриншоте
          _onScreenshotDetected();
        },
        (isCaptured) {
          // Колбэк при записи экрана (опционально)
          debugPrint('📹 Screen recording: $isCaptured');
        },
      );
    } catch (e) {
      debugPrint('❌ Screenshot listener setup error: $e');
      // Fallback на Native Channel (для Android/iOS)
      _setupNativeListener();
    }
  }

  /// Native метод для Android/iOS
  void _setupNativeListener() {
    _screenshotChannel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenshot') {
        _onScreenshotDetected();
      }
    });
  }

  /// Обработка обнаружения скриншота
  Future<void> _onScreenshotDetected() async {
    debugPrint('📸 Screenshot detected!');

    if (_currentPairId == null || _currentUserId == null) {
      debugPrint('⚠️ No pair info, skipping notification');
      return;
    }

    // Проверяем, не был ли скриншот уже зафиксирован недавно (защита от дублей)
    final lastScreenshotTime =
        _sharedPreferences.getInt(_lastScreenshotTimeKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - lastScreenshotTime < 2000) {
      // Игнорируем, если прошло менее 2 секунд
      return;
    }

    // Сохраняем время скриншота
    await _sharedPreferences.setInt(_lastScreenshotTimeKey, currentTime);

    // Отправляем уведомление в Firestore
    await _notifyPairAboutScreenshot();
  }

  /// Отправка уведомления в Firestore для обоих пользователей
  Future<void> _notifyPairAboutScreenshot() async {
    try {
      final notification = {
        'type': 'screenshot',
        'takenBy': _currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      // Добавляем уведомление в коллекцию пары
      await _firestore
          .collection('pairs')
          .doc(_currentPairId)
          .collection('notifications')
          .add(notification);

      debugPrint('✅ Screenshot notification sent to pair: $_currentPairId');
    } catch (e) {
      debugPrint('❌ Error sending screenshot notification: $e');
    }
  }

  /// Получение уведомлений о скриншотах для текущей пары
  Stream<List<ScreenshotNotification>> getScreenshotNotifications(
    String pairId,
  ) {
    return _firestore
        .collection('pairs')
        .doc(pairId)
        .collection('notifications')
        .where('type', isEqualTo: 'screenshot')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ScreenshotNotification(
              id: doc.id,
              takenBy: data['takenBy'] as String,
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              read: data['read'] as bool? ?? false,
            );
          }).toList();
        });
  }

  /// Пометить уведомление как прочитанное
  Future<void> markNotificationAsRead(
    String pairId,
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection('pairs')
          .doc(pairId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Очистка всех уведомлений
  Future<void> clearAllNotifications(String pairId) async {
    try {
      final notifications = await _firestore
          .collection('pairs')
          .doc(pairId)
          .collection('notifications')
          .where('type', isEqualTo: 'screenshot')
          .get();

      for (final doc in notifications.docs) {
        await doc.reference.delete();
      }

      debugPrint('✅ All screenshot notifications cleared');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  /// Остановка детектора
  void dispose() {
    // Удаляем слушатель
    ScreenProtector.removeListener();
  }
}

/// Модель уведомления о скриншоте
class ScreenshotNotification {
  final String id;
  final String takenBy;
  final DateTime timestamp;
  final bool read;

  ScreenshotNotification({
    required this.id,
    required this.takenBy,
    required this.timestamp,
    required this.read,
  });

  @override
  String toString() {
    return 'ScreenshotNotification(id: $id, takenBy: $takenBy, timestamp: $timestamp, read: $read)';
  }
}
