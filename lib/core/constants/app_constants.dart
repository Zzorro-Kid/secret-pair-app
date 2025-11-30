/// Основные константы приложения SecretPair
class AppConstants {
  // ============================================================
  // App Info
  // ============================================================
  static const String appName = 'SecretPair';
  static const String appVersion = '1.0.0';
  
  // ============================================================
  // Message Auto-Delete Settings
  // ============================================================
  static const int defaultMessageLifetimeMinutes = 60; // 1 час по умолчанию
  static const int minMessageLifetimeMinutes = 5; // Минимум 5 минут
  static const int maxMessageLifetimeMinutes = 1440; // Максимум 24 часа
  
  // Предустановленные варианты времени удаления (в минутах)
  static const List<int> messageLifetimeOptions = [
    5,    // 5 минут
    15,   // 15 минут
    30,   // 30 минут
    60,   // 1 час
    180,  // 3 часа
    360,  // 6 часов
    720,  // 12 часов
    1440, // 24 часа
  ];
  
  // ============================================================
  // Gallery Settings
  // ============================================================
  static const int maxGalleryItemSizeMB = 50; // Максимальный размер файла
  static const int galleryItemViewDurationSeconds = 10; // Время для просмотра медиа
  static const bool autoDeleteAfterView = true; // Автоудаление после просмотра
  
  // Поддерживаемые форматы
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi', 'mkv'];
  
  // ============================================================
  // Invite Code Settings
  // ============================================================
  static const int inviteCodeLength = 6; // Длина инвайт-кода
  static const String inviteCodeCharset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; // Символы для кода
  static const int inviteCodeExpirationHours = 24; // Код действует 24 часа
  
  // ============================================================
  // Screenshot Settings
  // ============================================================
  static const bool enableScreenshotNotifications = true;
  static const int screenshotDebounceMs = 2000; // Защита от дублей (2 секунды)
  static const bool enableScreenProtection = false; // false = только уведомления, true = блокировка
  
  // ============================================================
  // Panic Mode Settings
  // ============================================================
  static const int panicButtonHoldDurationMs = 3000; // Держать 3 секунды
  static const bool requireConfirmation = true; // Требовать подтверждение
  static const bool wipeLocalData = true; // Удалять локальные данные
  static const bool wipeRemoteData = true; // Удалять данные из Firebase
  
  // ============================================================
  // Storage Keys (SharedPreferences & SecureStorage)
  // ============================================================
  static const String keyUserId = 'user_id';
  static const String keyPairId = 'pair_id';
  static const String keyIsAuthenticated = 'is_authenticated';
  static const String keyLastScreenshotTime = 'last_screenshot_time';
  static const String keyMessageLifetime = 'message_lifetime_minutes';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  // Secure Storage Keys (для чувствительных данных)
  static const String secureKeyAuthToken = 'auth_token';
  static const String secureKeyEncryptionKey = 'encryption_key';
  
  // ============================================================
  // Network & API Settings
  // ============================================================
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // ============================================================
  // UI Constants
  // ============================================================
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double avatarSize = 48.0;
  
  // Animation durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  
  // ============================================================
  // Validation Rules
  // ============================================================
  static const int minPasswordLength = 6;
  static const int maxMessageLength = 1000;
  static const int maxUsernameLength = 30;
  
  // ============================================================
  // Error Messages
  // ============================================================
  static const String errorGeneric = 'Произошла ошибка. Попробуйте снова.';
  static const String errorNetwork = 'Проблемы с интернетом. Проверьте подключение.';
  static const String errorAuth = 'Ошибка аутентификации. Войдите снова.';
  static const String errorInvalidCode = 'Неверный инвайт-код.';
  static const String errorCodeExpired = 'Срок действия кода истек.';
  static const String errorPairNotFound = 'Пара не найдена.';
  static const String errorAlreadyInPair = 'Вы уже состоите в паре.';
  
  // ============================================================
  // Success Messages
  // ============================================================
  static const String successPairCreated = 'Пара создана! Поделитесь кодом.';
  static const String successPairJoined = 'Вы присоединились к паре!';
  static const String successMessageSent = 'Сообщение отправлено';
  static const String successMediaUploaded = 'Медиа загружено';
  static const String successDataWiped = 'Все данные удалены';
  
  // ============================================================
  // Confirmation Messages
  // ============================================================
  static const String confirmPanicMode = 'Вы уверены? Все данные будут удалены безвозвратно.';
  static const String confirmDeleteMessage = 'Удалить сообщение?';
  static const String confirmLeavePair = 'Покинуть пару? Доступ к данным будет утерян.';
}

/// Enum для различных режимов удаления сообщений
enum MessageDeletionMode {
  afterTime,    // Удаление через N минут/часов
  afterReading, // Удаление после прочтения
  manual,       // Только ручное удаление
}

/// Enum для типов медиа в галерее
enum MediaType {
  image,
  video,
  document,
}

/// Enum для статуса сообщения
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  deleted,
  failed,
}

/// Enum для режима темы
enum AppThemeMode {
  light,
  dark,
  system,
}
