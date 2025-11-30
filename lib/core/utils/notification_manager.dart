import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Менеджер локальных уведомлений
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ============================================================
  // Инициализация
  // ============================================================

  /// Инициализация менеджера уведомлений
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      debugPrint('✅ Notification Manager initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📬 Notification tapped: ${response.payload}');
    // TODO: Implement navigation based on payload
  }

  // ============================================================
  // Запрос разрешений
  // ============================================================

  /// Запросить разрешение на уведомления (iOS)
  Future<bool> requestPermissions() async {
    try {
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return granted ?? true; // Android не требует явного разрешения
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  // ============================================================
  // Показ уведомлений
  // ============================================================

  /// Показать простое уведомление
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'secretpair_default',
        'Основные уведомления',
        channelDescription: 'Основной канал уведомлений SecretPair',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  // ============================================================
  // Специальные уведомления
  // ============================================================

  /// Уведомление о новом сообщении
  Future<void> showNewMessageNotification({
    required String senderName,
    required String message,
    String? pairId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '💬 Новое сообщение от $senderName',
      body: message,
      payload: 'message:$pairId',
    );
  }

  /// Уведомление о скриншоте
  Future<void> showScreenshotNotification({
    required String partnerName,
    String? pairId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'secretpair_screenshots',
      'Уведомления о скриншотах',
      channelDescription: 'Уведомления, когда партнер делает скриншот',
      importance: Importance.max,
      priority: Priority.max,
      color: Color(0xFFFF9800),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '📸 Скриншот обнаружен!',
      '$partnerName сделал(а) скриншот',
      details,
      payload: 'screenshot:$pairId',
    );
  }

  /// Уведомление об удалении сообщения
  Future<void> showMessageDeletionNotification({
    required int remainingMinutes,
  }) async {
    await showNotification(
      id: 999, // Фиксированный ID для обновления
      title: '⏰ Сообщение скоро удалится',
      body: 'Осталось $remainingMinutes мин',
      payload: 'deletion_warning',
    );
  }

  /// Уведомление о новом медиа в галерее
  Future<void> showNewMediaNotification({
    required String partnerName,
    required String mediaType,
    String? pairId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '🖼️ Новое медиа от $partnerName',
      body: '$partnerName отправил(а) $mediaType',
      payload: 'media:$pairId',
    );
  }

  /// Уведомление о присоединении партнера
  Future<void> showPartnerJoinedNotification({
    required String partnerName,
    String? pairId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'secretpair_pairing',
      'Уведомления о паре',
      channelDescription: 'Уведомления о создании и присоединении к паре',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFE91E63),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '💕 Пара создана!',
      '$partnerName присоединился(-ась) к вам',
      details,
      payload: 'pair_joined:$pairId',
    );
  }

  // ============================================================
  // Управление уведомлениями
  // ============================================================

  /// Отменить уведомление по ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Получить список активных уведомлений
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      return await androidImpl.getActiveNotifications();
    }
    
    return [];
  }

  // ============================================================
  // Каналы уведомлений (Android)
  // ============================================================

  /// Создать дополнительные каналы уведомлений
  Future<void> createNotificationChannels() async {
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl == null) return;

    // Канал для сообщений
    const messageChannel = AndroidNotificationChannel(
      'secretpair_messages',
      'Сообщения',
      description: 'Уведомления о новых сообщениях',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Канал для скриншотов
    const screenshotChannel = AndroidNotificationChannel(
      'secretpair_screenshots',
      'Скриншоты',
      description: 'Уведомления о скриншотах',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFFF9800),
    );

    // Канал для паники
    const panicChannel = AndroidNotificationChannel(
      'secretpair_panic',
      'Panic Mode',
      description: 'Критические уведомления',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFD32F2F),
    );

    await androidImpl.createNotificationChannel(messageChannel);
    await androidImpl.createNotificationChannel(screenshotChannel);
    await androidImpl.createNotificationChannel(panicChannel);

    debugPrint('✅ Notification channels created');
  }

  // ============================================================
  // Планированные уведомления
  // ============================================================

  /// Запланировать уведомление
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'secretpair_scheduled',
        'Запланированные уведомления',
        channelDescription: 'Уведомления по расписанию',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  /// Запланировать уведомление об удалении сообщения
  Future<void> scheduleMessageDeletionNotification({
    required int messageId,
    required DateTime deletionTime,
  }) async {
    // Уведомление за 5 минут до удаления
    final notificationTime = deletionTime.subtract(const Duration(minutes: 5));
    
    if (notificationTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: messageId,
        title: '⏰ Сообщение скоро удалится',
        body: 'Сообщение будет удалено через 5 минут',
        scheduledTime: notificationTime,
        payload: 'message_deletion:$messageId',
      );
    }
  }
}
