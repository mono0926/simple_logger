import 'package:logging/logging.dart' show Level;
import 'package:stack_trace/stack_trace.dart' show Frame;

class LogInfo({
  required final Level level,
  required final DateTime time,

  /// Caller info.
  /// Available only when logger's includeCallerInfo is true.
  final Frame? callerFrame,
  required final String message,
  final Object? error,
  final StackTrace? stackTrace,
});
