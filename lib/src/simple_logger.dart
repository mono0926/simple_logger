import 'dart:developer' as developer;

import 'package:logging/logging.dart' show Level;
import 'package:stack_trace/stack_trace.dart' show Trace, Frame;

import 'log_info.dart';

typedef Formatter = String Function(LogInfo info);

typedef OnLogged = void Function(String log, LogInfo info);

/// Select log mode.
///
/// Default is [log], which use `dart:developer`'s `log` function.
/// The `print` use [print] function.
enum LoggerMode {
  /// Use `dart:developer`'s function.
  log,

  /// Use [print] function.
  print
}

/// Get singleton logger by `SimpleLogger()`
///
/// ```dart
/// final logger = SimpleLogger();
/// ```
class SimpleLogger {
  factory SimpleLogger() => _singleton;
  SimpleLogger._();

  static final _singleton = SimpleLogger._();
  var _level = Level.INFO;
  var _stackTraceLevel = Level.SEVERE;
  var _includeCallerInfo = false;
  Level get level => _level;
  Level get stackTraceLevel => _stackTraceLevel;
  LoggerMode mode = LoggerMode.print;

  /// Includes caller info only when includeCallerInfo is true.
  /// See also `void setLevel(Level level, {bool includeCallerInfo})`
  bool get includeCallerInfo => _includeCallerInfo;

  bool isLoggable(Level value) => value >= level;

  /// If includeCallerInfo is true, caller info will be included for
  /// any message of this level or above automatically.
  /// Because this is expensive, this is false by default.
  /// So, setting stackTraceEnabled to true for only debug build is recommended.
  ///
  /// ### Example
  ///
  /// ```
  /// logger.setLevel(
  ///   Level.INFO,
  ///   includeCallerInfo: true,
  /// );
  /// ```
  void setLevel(
    Level level, {
    Level stackTraceLevel = Level.SEVERE,
    bool includeCallerInfo = false,
  }) {
    _level = level;
    _stackTraceLevel = stackTraceLevel;
    _includeCallerInfo = includeCallerInfo;
  }

  /// Customize level prefix by changing this.
  ///
  /// ### Prefix can be omitted.
  ///
  /// ```
  /// logger.levelPrefixes = {};
  /// ```
  Map<Level, String> levelPrefixes = {
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
  ///
  /// ### Example
  ///
  /// ```
  /// logger.formatter = (_log, info) => 'Customized output: (${info.message})';
  /// ```
  Formatter? formatter;

  String _format(LogInfo info) {
    return '${_levelInfo(info.level)}'
        '${_timeInfo(info.time)}'
        '[${info.callerFrame ?? 'caller info not available'}] '
        '${info.message}';
  }

  String _levelInfo(Level level) {
    switch (mode) {
      case LoggerMode.log:
        return '';
      case LoggerMode.print:
        return '${levelPrefixes[level] ?? ''}$level ';
    }
  }

  String _timeInfo(DateTime time) {
    switch (mode) {
      case LoggerMode.log:
        return '';
      case LoggerMode.print:
        return '$time ';
    }
  }

  /// Any login inserted after log printed.
  ///
  /// ### Example
  ///
  /// ```
  /// logger.onLogged = (info) => print('Insert your logic with $info');
  /// ```
  // ignore: prefer_function_declarations_over_variables
  OnLogged onLogged = (_log, _info) {};

  void finest(Object message) => _log(Level.FINEST, message);
  void finer(Object message) => _log(Level.FINER, message);
  void fine(Object message) => _log(Level.FINE, message);
  void config(Object message) => _log(Level.CONFIG, message);
  void info(Object message) => _log(Level.INFO, message);
  void warning(Object message) => _log(Level.WARNING, message);
  void severe(Object message) => _log(Level.SEVERE, message);
  void shout(Object message) => _log(Level.SHOUT, message);
  // ignore: avoid_positional_boolean_parameters
  void assertOrShout(bool condition, Object message) {
    if (!condition) {
      _log(Level.SHOUT, message);
    }
    assert(condition, message);
  }

  void log(Level level, Object message) => _log(level, message);

  void _log(Level level, Object message) {
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
    switch (mode) {
      case LoggerMode.log:
        developer.log(
          log,
          level: level.value,
          name: 'simple_logger',
          time: info.time,
          stackTrace: includeCallerInfo && level >= stackTraceLevel
              ? StackTrace.current
              : null,
        );
        break;
      case LoggerMode.print:
        print(log);
    }

    onLogged(log, info);
  }

  Frame? _getCallerFrame() {
    if (!includeCallerInfo) {
      return null;
    }

    const level = 3;
    // Expensive
    final frames = Trace.current(level).frames;
    return frames.isEmpty ? null : frames.first;
  }
}
