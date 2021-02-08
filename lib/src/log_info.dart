import 'package:logging/logging.dart' show Level;
import 'package:stack_trace/stack_trace.dart' show Frame;

class LogInfo {
  LogInfo({
    required this.level,
    required this.time,
    this.callerFrame,
    required this.message,
  });

  final Level level;
  final DateTime time;

  /// Caller info.
  /// Available only when logger's includeCallerInfo is true.
  final Frame? callerFrame;
  final String message;
}
