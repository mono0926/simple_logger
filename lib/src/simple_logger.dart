import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

class LogInfo {
  final Level level;
  final DateTime time;
  final Frame lineFrame;
  final String message;

  LogInfo({
    this.level,
    this.time,
    this.lineFrame,
    this.message,
  });
}

typedef Formatter = String Function(LogInfo);

typedef OnLogged = void Function(LogInfo);

class SimpleLogger {
  static final _singleton = SimpleLogger._();
  final _logger = Logger('Simple Logger');
  var _level = Logger.root.level;
  Level get level => _level;

  factory SimpleLogger() {
    return _singleton;
  }

  SimpleLogger._() {
    Logger.root.onRecord.listen((record) {
      final frame = _getTargetFrame(record);
      final info = LogInfo(
        level: record.level,
        time: now ?? record.time,
        lineFrame: frame,
        message: record.message,
      );
      final f = formatter ?? _formatter;
      print(f(info));
      onLogged(info);
    });
  }

  /// If stacktraceEnabled is true, stack traces will be recorded for
  /// any message of this level or above automatically.
  /// Because this is expensive, this is off by default,
  /// but to output called location stacktraceEnabled should be true.
  /// So, setting stacktraceEnabled to true for debug build is recommended.
  void setLevel(Level level, {bool stacktraceEnabled = false}) {
    recordStackTraceAtLevel = stacktraceEnabled ? level : Level.OFF;
    Logger.root.level = level;
    _level = level;
  }

  /// Override read recorded time.
  DateTime now;

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

  Formatter formatter;

  String _formatter(LogInfo info) {
    final level = '${levelSuffixes[info.level] ?? ''}${info.level}';
    return '$level  ${info.time} [${info.lineFrame ?? 'stacktrace disabled'}] ${info.message}';
  }

  OnLogged onLogged = (_info) {};

  Frame _getTargetFrame(LogRecord record) {
    final stackTrace = record.stackTrace;
    if (stackTrace == null) {
      return null;
    }
    final frames = Trace.from(stackTrace).frames;
    const index = 3;
    if (frames.length > index) {
      return frames[index];
    }
    return frames.last;
  }

  void finest(message) => _logger.finest(message);
  void finer(message) => _logger.finer(message);
  void fine(message) => _logger.fine(message);
  void config(message) => _logger.config(message);
  void info(message) => _logger.info(message);
  void warning(message) => _logger.warning(message);
  void severe(message) => _logger.severe(message);
  void shout(message) => _logger.shout(message);
}
