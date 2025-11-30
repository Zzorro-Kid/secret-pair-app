import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Утилиты для шифрования данных (для дополнительной безопасности)
class EncryptionUtils {
  // ============================================================
  // AES Encryption
  // ============================================================

  /// Шифрование текста с помощью AES
  static String encryptAES(String plainText, String keyString) {
    try {
      // Создаем ключ из строки (32 байта для AES-256)
      final key = encrypt.Key.fromUtf8(_normalizeKey(keyString, 32));

      // Создаем IV (Initialization Vector)
      final iv = encrypt.IV.fromLength(16);

      // Создаем encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Шифруем
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Возвращаем base64 строку с IV в начале
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption error: $e');
    }
  }

  /// Расшифровка текста с помощью AES
  static String decryptAES(String encryptedText, String keyString) {
    try {
      // Разделяем IV и зашифрованный текст
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted format');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      // Создаем ключ
      final key = encrypt.Key.fromUtf8(_normalizeKey(keyString, 32));

      // Создаем encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Расшифровываем
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return decrypted;
    } catch (e) {
      throw Exception('Decryption error: $e');
    }
  }

  // ============================================================
  // Hash Functions
  // ============================================================

  /// SHA-256 хеш
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// MD5 хеш (менее безопасный, используйте SHA-256)
  static String md5Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// SHA-1 хеш
  static String sha1Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // ============================================================
  // Base64 Encoding
  // ============================================================

  /// Кодирование в Base64
  static String base64Encode(String input) {
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  /// Декодирование из Base64
  static String base64Decode(String input) {
    final bytes = base64.decode(input);
    return utf8.decode(bytes);
  }

  /// Кодирование байтов в Base64
  static String base64EncodeBytes(Uint8List bytes) {
    return base64.encode(bytes);
  }

  /// Декодирование Base64 в байты
  static Uint8List base64DecodeToBytes(String input) {
    return base64.decode(input);
  }

  // ============================================================
  // Password Hashing
  // ============================================================

  /// Хеширование пароля с солью
  static String hashPassword(String password, {String? salt}) {
    final actualSalt = salt ?? _generateSalt();
    final combined = '$password$actualSalt';
    return '${sha256Hash(combined)}:$actualSalt';
  }

  /// Проверка пароля
  static bool verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      final hash = parts[0];
      final salt = parts[1];

      final combined = '$password$salt';
      final computedHash = sha256Hash(combined);

      return computedHash == hash;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // Key Derivation
  // ============================================================

  /// Генерация ключа из пароля (PBKDF2-подобный)
  static String deriveKeyFromPassword(
    String password, {
    int iterations = 10000,
  }) {
    String key = password;

    for (int i = 0; i < iterations; i++) {
      key = sha256Hash(key);
    }

    return key;
  }

  // ============================================================
  // Helper Functions
  // ============================================================

  /// Нормализация ключа до нужной длины
  static String _normalizeKey(String key, int length) {
    if (key.length >= length) {
      return key.substring(0, length);
    } else {
      // Дополняем ключ до нужной длины
      return key.padRight(length, '0');
    }
  }

  /// Генерация случайной соли
  static String _generateSalt({int length = 16}) {
    final random = List<int>.generate(
      length,
      (i) => DateTime.now().millisecondsSinceEpoch % 256,
    );
    return base64.encode(random);
  }

  // ============================================================
  // File Encryption
  // ============================================================

  /// Шифрование файла (байтов)
  static Uint8List encryptBytes(Uint8List data, String keyString) {
    try {
      final key = encrypt.Key.fromUtf8(_normalizeKey(keyString, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Конвертируем байты в base64
      final dataBase64 = base64.encode(data);

      // Шифруем
      final encrypted = encrypter.encrypt(dataBase64, iv: iv);

      // Объединяем IV и зашифрованные данные
      final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);

      return combined;
    } catch (e) {
      throw Exception('File encryption error: $e');
    }
  }

  /// Расшифровка файла (байтов)
  static Uint8List decryptBytes(Uint8List encryptedData, String keyString) {
    try {
      // Извлекаем IV (первые 16 байт)
      final iv = encrypt.IV(encryptedData.sublist(0, 16));

      // Извлекаем зашифрованные данные
      final encryptedBytes = encryptedData.sublist(16);
      final encrypted = encrypt.Encrypted(encryptedBytes);

      final key = encrypt.Key.fromUtf8(_normalizeKey(keyString, 32));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Расшифровываем
      final decryptedBase64 = encrypter.decrypt(encrypted, iv: iv);

      // Конвертируем из base64 обратно в байты
      return base64.decode(decryptedBase64);
    } catch (e) {
      throw Exception('File decryption error: $e');
    }
  }

  // ============================================================
  // Message Encryption (для чата)
  // ============================================================

  /// Шифрование сообщения для чата
  static Map<String, String> encryptMessage(String message, String pairKey) {
    final encrypted = encryptAES(message, pairKey);
    final timestamp = DateTime.now().toIso8601String();

    return {
      'encryptedContent': encrypted,
      'timestamp': timestamp,
      'hash': sha256Hash('$message$timestamp'),
    };
  }

  /// Расшифровка сообщения из чата
  static String decryptMessage(
    Map<String, dynamic> encryptedData,
    String pairKey,
  ) {
    try {
      final encryptedContent = encryptedData['encryptedContent'] as String;
      return decryptAES(encryptedContent, pairKey);
    } catch (e) {
      throw Exception('Message decryption error: $e');
    }
  }

  /// Проверка целостности сообщения
  static bool verifyMessageIntegrity(
    String message,
    String timestamp,
    String hash,
  ) {
    final computedHash = sha256Hash('$message$timestamp');
    return computedHash == hash;
  }
}
