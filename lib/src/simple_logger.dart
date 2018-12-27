import 'package:logging/logging.dart' show Level;
import 'package:stack_trace/stack_trace.dart' show Trace, Frame;

import 'log_info.dart';

typedef Formatter = String Function(LogInfo info);

typedef OnLogged = void Function(String log, LogInfo info);

/// Get singleton logger by `SimpleLogger()`
class SimpleLogger {
  static final _singleton = SimpleLogger._();
  var _level = Level.INFO;
  var _includeCallerInfo = false;
  Level get level => _level;

  /// Includes caller info only when includeCallerInfo is true.
  /// See also `void setLevel(Level level, {bool includeCallerInfo})`
  bool get includeCallerInfo => _includeCallerInfo;

  factory SimpleLogger() => _singleton;

  SimpleLogger._();

  bool isLoggable(Level value) => value >= level;

  /// If includeCallerInfo is true, caller info will be included for
  /// any message of this level or above automatically.
  /// Because this is expensive, this is false by default.
  /// So, setting stacktraceEnabled to true for only debug build is recommended.
  void setLevel(Level level, {bool includeCallerInfo = false}) {
    _level = level;
    _includeCallerInfo = includeCallerInfo;
  }

  /// Customize level suffix by changing this.
  /// You can omit suffix by `logger.levelSuffixes = {};`
  var levelSuffixes = {
    Level.FINEST: '👾 ',
    Level.FINER: '👀 ',
    Level.FINE: '🎾 ',
    Level.CONFIG: '🐶 ',
    Level.INFO: '👻 ',
    Level.WARNING: '⚠️ ',
    Level.SEVERE: '‼️ ',
    Level.SHOUT: '😡 ',
  };

  /// Customize log output by setting this.
  Formatter formatter;

  String _format(LogInfo info) {
    final level = '${levelSuffixes[info.level] ?? ''}${info.level}';
    return '$level  '
        '${info.time} '
        '[${info.callerFrame ?? 'caller info not available'}] '
        '${info.message}';
  }

  /// Any login inserted after log printed.
  // ignore: prefer_function_declarations_over_variables
  OnLogged onLogged = (_log, _info) {};

  void finest(message) => _log(Level.FINEST, message);
  void finer(message) => _log(Level.FINER, message);
  void fine(message) => _log(Level.FINE, message);
  void config(message) => _log(Level.CONFIG, message);
  void info(message) => _log(Level.INFO, message);
  void warning(message) => _log(Level.WARNING, message);
  void severe(message) => _log(Level.SEVERE, message);
  void shout(message) => _log(Level.SHOUT, message);
  void log(Level level, message) => _log(level, message);

  void _log(Level level, message) {
    if (!isLoggable(level)) {
      return;
    }

    String msg;
    if (message is Function) {
      msg = message().toString();
    } else if (message is String) {
      msg = message;
    } else {
      msg = message.toString();
    }

    final info = LogInfo(
      level: level,
      time: DateTime.now(),
      callerFrame: _getCallerFrame(),
      message: msg,
    );

    final f = formatter ?? _format;
    final log = f(info);
    print(log);

    onLogged(log, info);
  }

  Frame _getCallerFrame() {
    if (!includeCallerInfo) {
      return null;
    }

    const level = 3;
    // Expensive
    final frames = Trace.current(level).frames;
    return frames.isEmpty ? null : frames.first;
  }
}
