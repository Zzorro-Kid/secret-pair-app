import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:secretpairapp/core/constants/app_constants.dart';

/// Утилиты для работы с медиафайлами (изображения, видео)
class MediaUtils {
  // ============================================================
  // File Type Detection
  // ============================================================

  /// Определить тип медиа по расширению
  static MediaType getMediaType(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceAll('.', '');
    
    if (AppConstants.supportedImageFormats.contains(extension)) {
      return MediaType.image;
    } else if (AppConstants.supportedVideoFormats.contains(extension)) {
      return MediaType.video;
    } else {
      return MediaType.document;
    }
  }

  /// Проверить, является ли файл изображением
  static bool isImage(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceAll('.', '');
    return AppConstants.supportedImageFormats.contains(extension);
  }

  /// Проверить, является ли файл видео
  static bool isVideo(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceAll('.', '');
    return AppConstants.supportedVideoFormats.contains(extension);
  }

  // ============================================================
  // File Size Validation
  // ============================================================

  /// Проверить размер файла (в MB)
  static Future<double> getFileSizeMB(String filePath) async {
    final file = File(filePath);
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Проверить, не превышает ли файл максимальный размер
  static Future<bool> isFileSizeValid(String filePath) async {
    final sizeMB = await getFileSizeMB(filePath);
    return sizeMB <= AppConstants.maxGalleryItemSizeMB;
  }

  /// Получить размер файла в читаемом формате
  static Future<String> getFileSizeFormatted(String filePath) async {
    final file = File(filePath);
    final bytes = await file.length();
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // ============================================================
  // Image Processing
  // ============================================================

  /// Сжать изображение
  static Future<Uint8List?> compressImage(
    String filePath, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      // Декодируем изображение
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      
      // Изменяем размер, если указано
      img.Image resized = image;
      if (maxWidth != null || maxHeight != null) {
        resized = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          interpolation: img.Interpolation.linear,
        );
      }
      
      // Сжимаем
      final compressed = img.encodeJpg(resized, quality: quality);
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('❌ Error compressing image: $e');
      return null;
    }
  }

  /// Создать миниатюру изображения
  static Future<Uint8List?> createThumbnail(
    String filePath, {
    int size = 150,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      
      // Создаем квадратную миниатюру
      final thumbnail = img.copyResizeCropSquare(image, size: size);
      
      final encoded = img.encodeJpg(thumbnail, quality: 80);
      return Uint8List.fromList(encoded);
    } catch (e) {
      debugPrint('❌ Error creating thumbnail: $e');
      return null;
    }
  }

  /// Получить размеры изображения
  static Future<Size?> getImageDimensions(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      debugPrint('❌ Error getting image dimensions: $e');
      return null;
    }
  }

  // ============================================================
  // Video Processing
  // ============================================================

  /// Получить длительность видео (заглушка - требует video_player)
  static Future<Duration?> getVideoDuration(String filePath) async {
    // TODO: Implement with video_player package
    debugPrint('⚠️ Video duration not implemented yet');
    return null;
  }

  // ============================================================
  // File Name Utilities
  // ============================================================

  /// Генерация уникального имени файла
  static String generateUniqueFileName(String originalPath) {
    final extension = path.extension(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    
    return 'media_${timestamp}_$random$extension';
  }

  /// Безопасное имя файла (удаляет спецсимволы)
  static String sanitizeFileName(String fileName) {
    // Заменяем опасные символы на подчеркивание
    return fileName.replaceAll(RegExp(r'[^\w\s.-]'), '_');
  }

  // ============================================================
  // MIME Type
  // ============================================================

  /// Получить MIME тип файла
  static String getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      // Images
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      
      // Videos
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.mkv':
        return 'video/x-matroska';
      
      default:
        return 'application/octet-stream';
    }
  }

  // ============================================================
  // File Path Utilities
  // ============================================================

  /// Получить имя файла без расширения
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Получить расширение файла
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceAll('.', '');
  }

  /// Получить имя файла с расширением
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  // ============================================================
  // Storage Path Generation
  // ============================================================

  /// Генерация пути в Firebase Storage
  static String generateStoragePath({
    required String pairId,
    required String mediaType,
    required String fileName,
  }) {
    return 'pairs/$pairId/$mediaType/$fileName';
  }

  /// Генерация пути для галереи
  static String generateGalleryPath({
    required String pairId,
    required String userId,
    required String fileName,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'pairs/$pairId/gallery/$userId/${timestamp}_$fileName';
  }

  /// Генерация пути для аватара
  static String generateAvatarPath({
    required String userId,
    required String fileName,
  }) {
    return 'avatars/$userId/$fileName';
  }

  // ============================================================
  // File Validation
  // ============================================================

  /// Проверить, валиден ли файл для загрузки
  static Future<ValidationResult> validateFileForUpload(String filePath) async {
    // Проверка существования файла
    final file = File(filePath);
    if (!await file.exists()) {
      return ValidationResult(
        isValid: false,
        error: 'Файл не найден',
      );
    }

    // Проверка типа файла
    final mediaType = getMediaType(filePath);
    if (mediaType == MediaType.document) {
      return ValidationResult(
        isValid: false,
        error: 'Неподдерживаемый формат файла',
      );
    }

    // Проверка размера файла
    final isValidSize = await isFileSizeValid(filePath);
    if (!isValidSize) {
      final sizeMB = await getFileSizeMB(filePath);
      return ValidationResult(
        isValid: false,
        error: 'Файл слишком большой (${sizeMB.toStringAsFixed(1)} MB). Максимум: ${AppConstants.maxGalleryItemSizeMB} MB',
      );
    }

    return ValidationResult(isValid: true);
  }
}

/// Результат валидации файла
class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({
    required this.isValid,
    this.error,
  });
}
