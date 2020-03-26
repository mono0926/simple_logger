# simple_logger

Provides super simple APIs for logging. The log also includes caller info by setting includeCallerInfo to true. On Android Studio, jump to caller info by clicking the log.


## Usage

```dart
// Singleton (factory)
final logger = SimpleLogger();

// Printed without called location
logger.info('Hello info!');
// -> 👻 INFO  2018-12-16 21:46:20.092695 [caller info not available] Hello info!

// Printed function which returns object
logger.info(() => 'Hello info!');
// -> 👻 INFO  2018-12-16 21:46:20.092695 [caller info not available] Hello info!

logger.setLevel(Level.WARNING);

// Not printed
logger.info('Hello info!');

// Printed
logger.warning('Hello warning!');
// -> ⚠️ WARNING  2018-12-16 21:46:20.101114 [caller info not available] Hello warning!

logger.shout('Hello shout!');
// -> 😡 SHOUT  2018-12-16 21:46:20.101308 [caller info not available] Hello shout!

logger.setLevel(
  Level.INFO,
  // Includes  caller info, but this is expensive.
  includeCallerInfo: true,
);

// Printed with called location
logger.info('Hello info!');
// -> 👻 INFO  2018-12-16 21:50:03.562583 [example/simple_logger_example.dart 29:10 in main] Hello info!

// Customize level prefix
logger.levelPrefixes = {};
logger.info('Hello info!');
// -> INFO  2018-12-16 21:50:03.562583 [example/simple_logger_example.dart 29:10 in main] Hello info!

logger.formatter = (info) => 'Customized output: (${info.message})';
logger.info('Hello info!');
// -> Customized output: (Hello info!)

logger.onLogged = (info) => print('Insert your logic with $info');
logger.info('Hello info!');
// -> Customized output: (Hello info!)
// -> Insert your logic with Instance of 'LogInfo'
```

## Technical Articles

- [Dartのログ出力に呼び出し元の情報を含めてクリックで飛べるようにする – Flutter 🇯🇵 – Medium](https://medium.com/flutter-jp/logger-ec25d8dd179a)

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/mono0926/simple_logger/issues
