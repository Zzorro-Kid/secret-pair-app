import 'dart:math';
import 'package:secretpairapp/core/constants/app_constants.dart';

/// Генератор инвайт-кодов для создания пары
class InviteCodeGenerator {
  static final Random _random = Random.secure();

  /// Генерация случайного инвайт-кода
  /// 
  /// Формат: XXXXXX (6 символов по умолчанию)
  /// Символы: A-Z, 0-9 (без похожих: O/0, I/1, S/5, Z/2)
  static String generate({int length = AppConstants.inviteCodeLength}) {
    const charset = AppConstants.inviteCodeCharset;
    final code = List.generate(
      length,
      (index) => charset[_random.nextInt(charset.length)],
    ).join();

    return code;
  }

  /// Генерация кода с разделителем для читаемости
  /// 
  /// Пример: ABC-DEF
  static String generateWithSeparator({
    int length = AppConstants.inviteCodeLength,
    String separator = '-',
    int chunkSize = 3,
  }) {
    final code = generate(length: length);
    
    // Разбиваем на части
    final chunks = <String>[];
    for (int i = 0; i < code.length; i += chunkSize) {
      final end = (i + chunkSize < code.length) ? i + chunkSize : code.length;
      chunks.add(code.substring(i, end));
    }
    
    return chunks.join(separator);
  }

  /// Проверка валидности инвайт-кода
  static bool isValid(String code) {
    if (code.isEmpty) return false;
    
    // Убираем возможные разделители
    final cleanCode = code.replaceAll(RegExp(r'[-\s]'), '');
    
    // Проверяем длину
    if (cleanCode.length != AppConstants.inviteCodeLength) {
      return false;
    }
    
    // Проверяем, что все символы валидны
    const charset = AppConstants.inviteCodeCharset;
    return cleanCode.split('').every((char) => charset.contains(char));
  }

  /// Нормализация кода (удаление пробелов, приведение к верхнему регистру)
  static String normalize(String code) {
    return code
        .replaceAll(RegExp(r'[-\s]'), '')
        .toUpperCase()
        .trim();
  }

  /// Форматирование кода для отображения (с разделителем)
  static String format(String code, {String separator = '-', int chunkSize = 3}) {
    final cleanCode = normalize(code);
    
    final chunks = <String>[];
    for (int i = 0; i < cleanCode.length; i += chunkSize) {
      final end = (i + chunkSize < cleanCode.length) ? i + chunkSize : cleanCode.length;
      chunks.add(cleanCode.substring(i, end));
    }
    
    return chunks.join(separator);
  }

  /// Генерация кода без похожих символов (для лучшей читаемости)
  /// 
  /// Исключены: O/0, I/1/L, S/5, Z/2, B/8
  static String generateReadable({int length = AppConstants.inviteCodeLength}) {
    const readableCharset = 'ACDEFGHJKMNPQRTUVWXY3479';
    final code = List.generate(
      length,
      (index) => readableCharset[_random.nextInt(readableCharset.length)],
    ).join();

    return code;
  }

  /// Генерация произносимого кода (чередование гласных и согласных)
  /// 
  /// Пример: VATARU
  static String generatePronounceable({int length = 6}) {
    const vowels = 'AEIOU';
    const consonants = 'BCDFGHJKLMNPQRSTVWXYZ';
    
    final code = StringBuffer();
    for (int i = 0; i < length; i++) {
      if (i.isEven) {
        // Согласная
        code.write(consonants[_random.nextInt(consonants.length)]);
      } else {
        // Гласная
        code.write(vowels[_random.nextInt(vowels.length)]);
      }
    }
    
    return code.toString();
  }

  /// Генерация кода с checksum (последний символ - контрольная сумма)
  static String generateWithChecksum({int length = AppConstants.inviteCodeLength}) {
    if (length < 2) {
      throw ArgumentError('Length must be at least 2 for checksum');
    }
    
    // Генерируем код без последнего символа
    final baseCode = generate(length: length - 1);
    
    // Вычисляем checksum
    final checksum = _calculateChecksum(baseCode);
    
    return baseCode + checksum;
  }

  /// Проверка кода с checksum
  static bool validateChecksum(String code) {
    if (code.length < 2) return false;
    
    final baseCode = code.substring(0, code.length - 1);
    final providedChecksum = code[code.length - 1];
    final calculatedChecksum = _calculateChecksum(baseCode);
    
    return providedChecksum == calculatedChecksum;
  }

  /// Вычисление контрольной суммы
  static String _calculateChecksum(String code) {
    const charset = AppConstants.inviteCodeCharset;
    int sum = 0;
    
    for (int i = 0; i < code.length; i++) {
      final charIndex = charset.indexOf(code[i]);
      sum += charIndex * (i + 1); // Умножаем на позицию для лучшего распределения
    }
    
    final checksumIndex = sum % charset.length;
    return charset[checksumIndex];
  }
}
