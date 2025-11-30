/// Валидаторы для форм ввода
class Validators {
  // ============================================================
  // Email Validation
  // ============================================================

  /// Валидация email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email не может быть пустым';
    }

    // Базовая регулярка для email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email';
    }

    return null;
  }

  // ============================================================
  // Password Validation
  // ============================================================

  /// Валидация пароля (минимум 6 символов)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не может быть пустым';
    }

    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }

    return null;
  }

  /// Валидация сильного пароля
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не может быть пустым';
    }

    if (value.length < 8) {
      return 'Пароль должен содержать минимум 8 символов';
    }

    // Проверка на наличие цифр
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Пароль должен содержать хотя бы одну цифру';
    }

    // Проверка на наличие букв
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Пароль должен содержать хотя бы одну букву';
    }

    return null;
  }

  /// Подтверждение пароля
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }

    if (value != password) {
      return 'Пароли не совпадают';
    }

    return null;
  }

  // ============================================================
  // Invite Code Validation
  // ============================================================

  /// Валидация инвайт-кода
  static String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите инвайт-код';
    }

    // Убираем пробелы и дефисы
    final cleanCode = value.replaceAll(RegExp(r'[-\s]'), '');

    if (cleanCode.length != 6) {
      return 'Код должен содержать 6 символов';
    }

    // Проверяем на валидные символы (A-Z, 0-9)
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(cleanCode)) {
      return 'Код может содержать только буквы и цифры';
    }

    return null;
  }

  // ============================================================
  // Username Validation
  // ============================================================

  /// Валидация имени пользователя
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Имя не может быть пустым';
    }

    if (value.length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }

    if (value.length > 30) {
      return 'Имя должно содержать максимум 30 символов';
    }

    // Проверка на валидные символы (буквы, цифры, пробелы, дефисы, подчеркивания)
    if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ0-9\s_-]+$').hasMatch(value)) {
      return 'Имя может содержать только буквы, цифры, пробелы и дефисы';
    }

    return null;
  }

  // ============================================================
  // Message Validation
  // ============================================================

  /// Валидация текста сообщения
  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Сообщение не может быть пустым';
    }

    if (value.length > 1000) {
      return 'Сообщение не может превышать 1000 символов';
    }

    return null;
  }

  // ============================================================
  // Required Field Validation
  // ============================================================

  /// Валидация обязательного поля
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName не может быть пустым'
          : 'Это поле обязательно для заполнения';
    }

    return null;
  }

  // ============================================================
  // Length Validation
  // ============================================================

  /// Валидация минимальной длины
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Используйте validateRequired для проверки пустого значения
    }

    if (value.length < minLength) {
      return fieldName != null
          ? '$fieldName должно содержать минимум $minLength символов'
          : 'Минимум $minLength символов';
    }

    return null;
  }

  /// Валидация максимальной длины
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return fieldName != null
          ? '$fieldName не может превышать $maxLength символов'
          : 'Максимум $maxLength символов';
    }

    return null;
  }

  /// Валидация точной длины
  static String? validateExactLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length != length) {
      return fieldName != null
          ? '$fieldName должно содержать ровно $length символов'
          : 'Должно быть $length символов';
    }

    return null;
  }

  // ============================================================
  // Phone Validation
  // ============================================================

  /// Валидация номера телефона
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Номер телефона не может быть пустым';
    }

    // Убираем все символы кроме цифр и +
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Проверка на минимальную длину
    if (cleanPhone.length < 10) {
      return 'Введите корректный номер телефона';
    }

    // Базовая проверка формата
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleanPhone)) {
      return 'Введите корректный номер телефона';
    }

    return null;
  }

  // ============================================================
  // URL Validation
  // ============================================================

  /// Валидация URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL не может быть пустым';
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Введите корректный URL';
    }

    return null;
  }

  // ============================================================
  // Number Validation
  // ============================================================

  /// Валидация числа
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (int.tryParse(value) == null && double.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName должно быть числом'
          : 'Введите корректное число';
    }

    return null;
  }

  /// Валидация целого числа
  static String? validateInteger(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (int.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName должно быть целым числом'
          : 'Введите целое число';
    }

    return null;
  }

  /// Валидация диапазона чисел
  static String? validateRange(String? value, int min, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Введите корректное число';
    }

    if (number < min || number > max) {
      return fieldName != null
          ? '$fieldName должно быть от $min до $max'
          : 'Значение должно быть от $min до $max';
    }

    return null;
  }

  // ============================================================
  // Combined Validators
  // ============================================================

  /// Комбинированный валидатор (применяет несколько валидаторов)
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
