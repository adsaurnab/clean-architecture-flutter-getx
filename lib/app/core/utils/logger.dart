import 'package:logger/logger.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// App-wide logger that writes to console (debug) and Crashlytics (errors).
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // // Non-fatal error – report to Crashlytics
    // FirebaseCrashlytics.instance.recordError(
    //   error ?? message,
    //   stackTrace,
    //   reason: message,
    //   fatal: false,
    // );
  }

  static void fatal(String message, Object error, StackTrace stackTrace) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  }
}
