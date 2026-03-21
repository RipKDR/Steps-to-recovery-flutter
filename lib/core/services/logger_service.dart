import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logger service for the app
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void debug(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message) {
    _logger.w(message);
  }

  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(String message) {
    _logger.f(message);
  }
}

/// Usage:
/// ```dart
/// final logger = LoggerService();
/// logger.debug('Debug message');
/// logger.info('Info message');
/// logger.error('Error occurred', error: e, stackTrace: stackTrace);
/// ```
