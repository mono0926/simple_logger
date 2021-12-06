// ignore_for_file: lines_longer_than_80_chars, cascade_invocations
import 'package:simple_logger/simple_logger.dart';
import 'package:test/test.dart';

void main() {
  group('Simple Logger tests', () {
    final target = SimpleLogger();
    test('test', () {
      expect(target.level, Level.INFO);
      expect(target.isLoggable(Level.INFO), true);
      expect(target.isLoggable(Level.FINE), false);
      expect(target.isLoggable(Level.SHOUT), true);
      expect(target.formatter, null);
      expect(target.levelPrefixes.isNotEmpty, true);
      expect(target.includeCallerInfo, false);
      expect(target.callerInfoFrameLevel, 0);

      target.info('test');
      target.setLevel(Level.INFO, includeCallerInfo: true);
      target.info('test');
    });
  });
}
