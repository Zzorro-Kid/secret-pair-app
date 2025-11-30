import 'package:flutter/material.dart';

/// Текстовые стили для приложения SecretPair
class AppTextStyles {
  // ============================================================
  // Headings
  // ============================================================
  
  /// Heading 1 - Главные заголовки (экраны)
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Heading 2 - Второстепенные заголовки
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
  );
  
  /// Heading 3 - Подзаголовки
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  /// Heading 4 - Мелкие заголовки
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // ============================================================
  // Body Text
  // ============================================================
  
  /// Body Large - Основной текст (большой)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  /// Body Medium - Основной текст (средний)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  /// Body Small - Основной текст (мелкий)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  // ============================================================
  // Labels & Buttons
  // ============================================================
  
  /// Label Large - Кнопки и крупные метки
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  /// Label Medium - Средние метки
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
  );
  
  /// Label Small - Мелкие метки
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
  );
  
  // ============================================================
  // Special Styles
  // ============================================================
  
  /// Caption - Подписи, метаданные
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  /// Overline - Надстрочный текст
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // ============================================================
  // Message-Specific Styles
  // ============================================================
  
  /// Стиль для текста сообщения
  static const TextStyle messageText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  /// Стиль для времени сообщения
  static const TextStyle messageTime = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.2,
  );
  
  /// Стиль для имени отправителя
  static const TextStyle messageSender = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // ============================================================
  // Input Styles
  // ============================================================
  
  /// Стиль для текста в полях ввода
  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  /// Стиль для placeholder в полях ввода
  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  /// Стиль для label в полях ввода
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  // ============================================================
  // Invite Code Style
  // ============================================================
  
  /// Стиль для инвайт-кода (крупный, моноширинный)
  static const TextStyle inviteCode = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 8,
    fontFamily: 'monospace',
    height: 1.2,
  );
  
  // ============================================================
  // Timer Styles
  // ============================================================
  
  /// Стиль для таймера удаления сообщений
  static const TextStyle timer = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'monospace',
    letterSpacing: 1,
  );
  
  // ============================================================
  // Error & Warning Styles
  // ============================================================
  
  /// Стиль для текста ошибок
  static const TextStyle error = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  /// Стиль для текста предупреждений
  static const TextStyle warning = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  // ============================================================
  // Helper Methods
  // ============================================================
  
  /// Применить цвет к стилю
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Применить жирность к стилю
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Применить размер к стилю
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// Применить все параметры
  static TextStyle customize({
    required TextStyle baseStyle,
    Color? color,
    FontWeight? weight,
    double? size,
    double? height,
    double? letterSpacing,
  }) {
    return baseStyle.copyWith(
      color: color,
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}

/// Расширение для упрощенного использования стилей
extension TextStyleExtension on TextStyle {
  /// Применить цвет
  TextStyle withColor(Color color) => copyWith(color: color);
  
  /// Применить жирность
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  
  /// Применить размер
  TextStyle withSize(double size) => copyWith(fontSize: size);
  
  /// Применить высоту строки
  TextStyle withHeight(double height) => copyWith(height: height);
  
  /// Применить межбуквенный интервал
  TextStyle withLetterSpacing(double spacing) => copyWith(letterSpacing: spacing);
  
  /// Применить курсив
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  
  /// Применить подчеркивание
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  
  /// Применить зачеркивание
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);
}
