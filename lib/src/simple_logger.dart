import 'dart:developer' as developer;

import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

typedef Formatter = String Function(LogInfo info);

typedef OnLogged = void Function(LogRecord record);

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
  SimpleLogger._() {
    hierarchicalLoggingEnabled = true;
    _logger.onRecord.listen((record) {
      switch (mode) {
        case LoggerMode.log:
          developer.log(
            record.message,
            time: record.time,
            sequenceNumber: record.sequenceNumber,
            level: record.level.value,
            name: record.loggerName,
            zone: record.zone,
            error: record.error,
            stackTrace: record.stackTrace,
          );
          break;
        case LoggerMode.print:
          // ignore: avoid_print
          print(record.message);
      }
      onLogged?.call(record);
    });
  }

  final _logger = Logger('simple_logger');
  static final _singleton = SimpleLogger._();
  var _stackTraceLevel = Level.SEVERE;
  var _includeCallerInfo = false;
  var _callerInfoFrameLevelOffset = 0;
  Level get level => _logger.level;
  Level get stackTraceLevel => _stackTraceLevel;
  LoggerMode mode = LoggerMode.log;

  /// Includes caller info only when includeCallerInfo is true.
  /// See also `void setLevel(Level level, {bool includeCallerInfo})`
  bool get includeCallerInfo => _includeCallerInfo;

  /// Stack trace level used to determine caller info.
  /// Usually you DON'T have to specify this value, but it's useful
  /// if you wrap this SimpleLogger by your own logger.
  int get callerInfoFrameLevelOffset => _callerInfoFrameLevelOffset;

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
    int callerInfoFrameLevelOffset = 0,
  }) {
    _logger.level = level;
    _stackTraceLevel = stackTraceLevel;
    _includeCallerInfo = includeCallerInfo;
    _callerInfoFrameLevelOffset = callerInfoFrameLevelOffset;
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
  late Formatter formatter = _defaultFormatter;

  String _defaultFormatter(LogInfo info) {
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
  OnLogged? onLogged;

  void finest(Object? message, {Object? error}) =>
      _log(Level.FINEST, message, error);
  void finer(Object? message, {Object? error}) =>
      _log(Level.FINER, message, error);
  void fine(Object? message, {Object? error}) =>
      _log(Level.FINE, message, error);
  void config(Object? message, {Object? error}) =>
      _log(Level.CONFIG, message, error);
  void info(Object? message, {Object? error}) =>
      _log(Level.INFO, message, error);
  void warning(Object? message, {Object? error}) =>
      _log(Level.WARNING, message, error);
  void severe(Object? message, {Object? error}) =>
      _log(Level.SEVERE, message, error);
  void shout(Object? message, {Object? error}) =>
      _log(Level.SHOUT, message, error);

  // ignore: avoid_positional_boolean_parameters
  void assertOrShout(bool condition, Object message, {Object? error}) {
    assert(condition, '$message${error == null ? '' : '(error: $error)'}');
    if (!condition) {
      _log(Level.SHOUT, message, error);
    }
  }

  void log(Level level, Object message, {Object? error}) =>
      _log(level, message, error);

  void _log(Level level, Object? message, Object? error) {
    if (!isLoggable(level)) {
      return;
    }

    final String msg;
    // ignore: inference_failure_on_function_return_type
    if (message is Function()) {
      msg = message().toString();
    } else if (message is String) {
      msg = message;
    } else {
      msg = message.toString();
    }

    _logger.log(
      level,
      formatter(
        LogInfo(
          level: level,
          time: DateTime.now(),
          callerFrame: _getCallerFrame(),
          message: msg,
        ),
      ),
      error,
      includeCallerInfo && level >= stackTraceLevel ? StackTrace.current : null,
    );
  }

  Frame? _getCallerFrame() {
    if (!includeCallerInfo) {
      return null;
    }

    // Expensive
    const baseLevel = 3;
    final frames =
        Trace.current(baseLevel + _callerInfoFrameLevelOffset).frames;
    return frames.isEmpty ? null : frames.first;
  }
}

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
