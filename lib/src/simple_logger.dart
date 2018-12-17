import 'package:logging/logging.dart' show Level;
import 'package:stack_trace/stack_trace.dart' show Trace, Frame;

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
  var _level = Level.INFO;
  var _stacktraceEnabled = false;
  Level get level => _level;
  bool get stacktraceEnabled => _stacktraceEnabled;

  factory SimpleLogger() {
    return _singleton;
  }

  SimpleLogger._();

  bool isLoggable(Level value) => value >= level;

  /// If stacktraceEnabled is true, stack traces will be recorded for
  /// any message of this level or above automatically.
  /// Because this is expensive, this is off by default,
  /// but to output called location stacktraceEnabled should be true.
  /// So, setting stacktraceEnabled to true for debug build is recommended.
  void setLevel(Level level, {bool stacktraceEnabled = false}) {
    _level = level;
    _stacktraceEnabled = stacktraceEnabled;
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

  void finest(message) => _log(message, Level.FINEST);
  void finer(message) => _log(message, Level.FINER);
  void fine(message) => _log(message, Level.FINE);
  void config(message) => _log(message, Level.CONFIG);
  void info(message) => _log(message, Level.INFO);
  void warning(message) => _log(message, Level.WARNING);
  void severe(message) => _log(message, Level.SEVERE);
  void shout(message) => _log(message, Level.SHOUT);

  void _log(message, Level level) {
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
      time: now ?? DateTime.now(),
      lineFrame: _getTargetFrame(),
      message: msg,
    );

    final f = formatter ?? _formatter;
    print(f(info));

    onLogged(info);
  }

  Frame _getTargetFrame() {
    if (!stacktraceEnabled) {
      return null;
    }

    final stackTrace = StackTrace.current;
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
}
