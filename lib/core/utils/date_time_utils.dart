import 'package:intl/intl.dart';

/// Утилиты для работы с датой и временем
class DateTimeUtils {
  // ============================================================
  // Форматирование даты и времени
  // ============================================================
  
  /// Форматировать дату и время для сообщений (HH:mm)
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // Сегодня - показываем только время
    if (difference.inDays == 0 && dateTime.day == now.day) {
      return DateFormat('HH:mm').format(dateTime);
    }
    
    // Вчера
    if (difference.inDays == 1 || (difference.inDays == 0 && dateTime.day != now.day)) {
      return 'Вчера ${DateFormat('HH:mm').format(dateTime)}';
    }
    
    // Последние 7 дней - показываем день недели
    if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm', 'ru').format(dateTime);
    }
    
    // Этот год - без года
    if (dateTime.year == now.year) {
      return DateFormat('d MMMM HH:mm', 'ru').format(dateTime);
    }
    
    // Полная дата
    return DateFormat('d MMMM yyyy HH:mm', 'ru').format(dateTime);
  }
  
  /// Форматировать дату для группировки сообщений
  static String formatMessageGroupDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // Сегодня
    if (difference.inDays == 0 && dateTime.day == now.day) {
      return 'Сегодня';
    }
    
    // Вчера
    if (difference.inDays == 1 || (difference.inDays == 0 && dateTime.day != now.day)) {
      return 'Вчера';
    }
    
    // Последние 7 дней
    if (difference.inDays < 7) {
      return DateFormat('EEEE', 'ru').format(dateTime);
    }
    
    // Этот год
    if (dateTime.year == now.year) {
      return DateFormat('d MMMM', 'ru').format(dateTime);
    }
    
    // Полная дата
    return DateFormat('d MMMM yyyy', 'ru').format(dateTime);
  }
  
  /// Короткое время (только HH:mm)
  static String formatShortTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  /// Полная дата и время
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('d MMMM yyyy, HH:mm', 'ru').format(dateTime);
  }
  
  /// Только дата
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    
    if (dateTime.year == now.year) {
      return DateFormat('d MMMM', 'ru').format(dateTime);
    }
    
    return DateFormat('d MMMM yyyy', 'ru').format(dateTime);
  }
  
  /// Относительное время ("только что", "5 минут назад", "2 часа назад")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // Только что (до 1 минуты)
    if (difference.inSeconds < 60) {
      return 'только что';
    }
    
    // Минуты назад
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${_pluralMinutes(difference.inMinutes)} назад';
    }
    
    // Часы назад (до 24 часов)
    if (difference.inHours < 24) {
      return '${difference.inHours} ${_pluralHours(difference.inHours)} назад';
    }
    
    // Дни назад (до 7 дней)
    if (difference.inDays < 7) {
      return '${difference.inDays} ${_pluralDays(difference.inDays)} назад';
    }
    
    // Иначе показываем дату
    return formatDate(dateTime);
  }
  
  // ============================================================
  // Работа со временем удаления сообщений
  // ============================================================
  
  /// Вычислить время удаления сообщения
  static DateTime calculateDeletionTime(DateTime sentAt, int lifetimeMinutes) {
    return sentAt.add(Duration(minutes: lifetimeMinutes));
  }
  
  /// Проверить, нужно ли удалять сообщение
  static bool shouldDeleteMessage(DateTime sentAt, int lifetimeMinutes) {
    final deletionTime = calculateDeletionTime(sentAt, lifetimeMinutes);
    return DateTime.now().isAfter(deletionTime);
  }
  
  /// Получить оставшееся время до удаления (в минутах)
  static int getRemainingMinutes(DateTime sentAt, int lifetimeMinutes) {
    final deletionTime = calculateDeletionTime(sentAt, lifetimeMinutes);
    final remaining = deletionTime.difference(DateTime.now());
    
    if (remaining.isNegative) return 0;
    
    return remaining.inMinutes;
  }
  
  /// Получить оставшееся время до удаления (в секундах)
  static int getRemainingSeconds(DateTime sentAt, int lifetimeMinutes) {
    final deletionTime = calculateDeletionTime(sentAt, lifetimeMinutes);
    final remaining = deletionTime.difference(DateTime.now());
    
    if (remaining.isNegative) return 0;
    
    return remaining.inSeconds;
  }
  
  /// Форматировать оставшееся время до удаления ("5 мин", "1 час 30 мин")
  static String formatRemainingTime(DateTime sentAt, int lifetimeMinutes) {
    final remainingSeconds = getRemainingSeconds(sentAt, lifetimeMinutes);
    
    if (remainingSeconds <= 0) {
      return 'удаляется...';
    }
    
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;
    
    if (hours > 0) {
      if (minutes > 0) {
        return '$hours ${_pluralHours(hours)} $minutes ${_pluralMinutes(minutes)}';
      }
      return '$hours ${_pluralHours(hours)}';
    }
    
    if (minutes > 0) {
      return '$minutes ${_pluralMinutes(minutes)}';
    }
    
    return '$seconds ${_pluralSeconds(seconds)}';
  }
  
  /// Короткий формат оставшегося времени ("5:30", "1:30:45")
  static String formatRemainingTimeShort(DateTime sentAt, int lifetimeMinutes) {
    final remainingSeconds = getRemainingSeconds(sentAt, lifetimeMinutes);
    
    if (remainingSeconds <= 0) {
      return '0:00';
    }
    
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // ============================================================
  // Работа с инвайт-кодами
  // ============================================================
  
  /// Вычислить время истечения инвайт-кода
  static DateTime calculateCodeExpiration(DateTime createdAt, int expirationHours) {
    return createdAt.add(Duration(hours: expirationHours));
  }
  
  /// Проверить, истек ли инвайт-код
  static bool isCodeExpired(DateTime createdAt, int expirationHours) {
    final expirationTime = calculateCodeExpiration(createdAt, expirationHours);
    return DateTime.now().isAfter(expirationTime);
  }
  
  /// Получить оставшееся время действия кода
  static String formatCodeExpiration(DateTime createdAt, int expirationHours) {
    final expirationTime = calculateCodeExpiration(createdAt, expirationHours);
    final remaining = expirationTime.difference(DateTime.now());
    
    if (remaining.isNegative) {
      return 'Код истек';
    }
    
    final hours = remaining.inHours;
    final minutes = (remaining.inMinutes % 60);
    
    if (hours > 0) {
      return 'Действителен еще $hours ${_pluralHours(hours)} $minutes ${_pluralMinutes(minutes)}';
    }
    
    return 'Действителен еще $minutes ${_pluralMinutes(minutes)}';
  }
  
  // ============================================================
  // Утилиты сравнения дат
  // ============================================================
  
  /// Проверить, что даты относятся к одному дню
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Проверить, что дата сегодня
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
  
  /// Проверить, что дата вчера
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
  
  // ============================================================
  // Вспомогательные функции для склонения слов
  // ============================================================
  
  static String _pluralMinutes(int minutes) {
    if (minutes % 10 == 1 && minutes % 100 != 11) {
      return 'минута';
    } else if ([2, 3, 4].contains(minutes % 10) && ![12, 13, 14].contains(minutes % 100)) {
      return 'минуты';
    } else {
      return 'минут';
    }
  }
  
  static String _pluralHours(int hours) {
    if (hours % 10 == 1 && hours % 100 != 11) {
      return 'час';
    } else if ([2, 3, 4].contains(hours % 10) && ![12, 13, 14].contains(hours % 100)) {
      return 'часа';
    } else {
      return 'часов';
    }
  }
  
  static String _pluralDays(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(days % 10) && ![12, 13, 14].contains(days % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }
  
  static String _pluralSeconds(int seconds) {
    if (seconds % 10 == 1 && seconds % 100 != 11) {
      return 'секунда';
    } else if ([2, 3, 4].contains(seconds % 10) && ![12, 13, 14].contains(seconds % 100)) {
      return 'секунды';
    } else {
      return 'секунд';
    }
  }
}
