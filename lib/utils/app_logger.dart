import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.info, // Set level ke info untuk mengurangi log debug
  );

  // Private constructor untuk mencegah instantiasi
  AppLogger._();

  static void debug(String message) {
    _logger.d('[DEBUG] $message');
  }

  static void info(String message) {
    _logger.i('[INFO] $message');
  }

  static void warning(String message) {
    _logger.w('[WARNING] $message');
  }

  static void error(String message, [dynamic error]) {
    if (error != null) {
      _logger.e('[ERROR] $message: $error');
    } else {
      _logger.e('[ERROR] $message');
    }
  }

  static void auth(String message) {
    _logger.i('[AUTH] $message');
  }

  static void navigation(String message) {
    _logger.i('[NAV] $message');
  }

  static void user(String message) {
    _logger.i('[USER] $message');
  }
}
