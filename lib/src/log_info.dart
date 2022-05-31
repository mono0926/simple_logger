import 'package:logging/logging.dart' show Level;

class LogInfo {
  LogInfo({
    required this.level,
    required this.time,
    this.callerStackTraceLine,
    required this.message,
  });

  final Level level;
  final DateTime time;

  /// Caller info.
  /// Available only when logger's includeCallerInfo is true.
  final String? callerStackTraceLine;
  final String message;
}
