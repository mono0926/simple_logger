import 'package:simple_logger/simple_logger.dart';

// Singleton (factory)
final logger = SimpleLogger();

void main() {
  // Printed without called location
  logger.info('Hello info!');
  // -> 👻 INFO  2018-12-16 21:46:20.092695 [stacktrace disabled] Hello info!

  // Printed function which returns object
  logger.info(() => 'Hello info!');
  // -> 👻 INFO  2018-12-16 21:46:20.092695 [stacktrace disabled] Hello info!

  logger.setLevel(Level.WARNING);

  // Not printed
  logger.info('Hello info!');

  // Printed
  logger.warning('Hello warning!');
  // -> ⚠️ WARNING  2018-12-16 21:46:20.101114 [stacktrace disabled] Hello warning!

  logger.shout('Hello shout!');
  // -> 😡 SHOUT  2018-12-16 21:46:20.101308 [stacktrace disabled] Hello shout!

  logger.setLevel(
    Level.INFO,
    // Includes  caller info, but this is expensive.
    includesCallerInfo: true,
  );

  // Printed with called location
  logger.info('Hello info!');
  // -> 👻 INFO  2018-12-16 21:50:03.562583 [example/simple_logger_example.dart 29:10 in main] Hello info!

  // Customize level prefix
  logger.levelSuffixes = {};
  logger.info('Hello info!');
  // -> INFO  2018-12-16 21:50:03.562583 [example/simple_logger_example.dart 29:10 in main] Hello info!

  logger.formatter = (info) => 'Customized output: (${info.message})';
  logger.info('Hello info!');
  // -> Customized output: (Hello info!)

  logger.onLogged = (_log, info) => print('Insert your logic with $info');
  logger.info('Hello info!');
  // -> Customized output: (Hello info!)
  // -> Insert your logic with Instance of 'LogInfo'
}
