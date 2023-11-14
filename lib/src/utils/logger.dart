import 'package:flutter/foundation.dart';

/// This is a logger class for displaying logs from the dojah widget
class DojahLogger {
  /// toggle this property to display/hide logs
  static bool showLogs = false;

  /// display logs from the webview
  static void log(dynamic str) {
    if (showLogs == false) {
      return;
    }
    if (kDebugMode) {
      print('DojahLogger[log]: $str');
    }
  }

  /// display error logs from the webview
  static void e(dynamic str) {
    if (showLogs == false) {
      return;
    }
    if (kDebugMode) {
      print('DojahLogger[error]: $str');
    }
  }
}
