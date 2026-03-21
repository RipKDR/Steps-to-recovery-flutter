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
      printTime: true,
    ),
  );

  void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _logger.d(message, tag: tag);
    }
  }

  void info(String message, {String? tag}) {
    _logger.i(message, tag: tag);
  }

  void warning(String message, {String? tag}) {
    _logger.w(message, tag: tag);
  }

  void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void wtf(String message, {String? tag}) {
    _logger.wtf(message, tag: tag);
  }
}

/// Usage:
/// ```dart
/// final logger = LoggerService();
/// logger.debug('Debug message', tag: 'MyClass');
/// logger.info('Info message');
/// logger.error('Error occurred', error: e, stackTrace: stackTrace);
/// ```
