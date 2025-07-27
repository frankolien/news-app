import 'dart:developer' as developer;

class AppLogger {
  static void log(String message, {String tag = 'APP_LOG'}) {
    developer.log('[$tag] $message');
  }
}