import 'package:flutter/foundation.dart';

/// Professional logging system for NutriCare+
class AppLogger {
  static const String _prefix = '[NutriCare]';

  /// Log debug messages (dev only)
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_prefix [DEBUG] $message');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [INFO] $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [dynamic error]) {
    debugPrint('$_prefix [WARNING] $message');
    if (error != null) debugPrint('  Error: $error');
  }

  /// Log error messages
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('$_prefix [ERROR] $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  Stack: $stackTrace');
  }

  /// Log critical errors
  static void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('$_prefix [CRITICAL] $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  Stack: $stackTrace');
  }
}
