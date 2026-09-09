---
name: simple_logger-logging
description: >-
  Use when configuring logging levels, capturing caller stack information,
  or writing structured application logs using simple_logger in Dart and Flutter.
---

# simple_logger Logging Guide

`simple_logger` provides a straightforward, developer-friendly logging API built on top of the standard `logging` package. It features caller file/line capture (with IDE clickable links), lazy log evaluation, customizable prefixes/emojis, and flexible output formatters.

## Guidelines

- **Instantiation**:
  - `SimpleLogger()` is implemented as a singleton factory. Calling `SimpleLogger()` returns the shared global logger instance.
- **Level Configuration**:
  - Configure the logging level early in application bootstrap (e.g., in `main()` before `runApp()`).
  - Use `logger.setLevel(...)` to set the active threshold (`Level.INFO`, `Level.WARNING`, `Level.SEVERE`, etc.).
- **Caller Info Performance**:
  - `includeCallerInfo: true` captures caller stack frame locations, making logs clickable in IDEs. Because stack trace parsing is CPU-intensive, **only enable `includeCallerInfo` in debug mode (`kDebugMode` or `!kReleaseMode`)**.
- **Lazy Evaluation**:
  - Pass a closure `() => 'message'` instead of evaluating heavy string interpolation eagerly if the log level might be suppressed.
- **Log Routing & Listeners**:
  - Use `logger.onLogged` or custom `logger.formatter` to forward logs to external error reporting services (e.g. Sentry, Crashlytics) in production.

## Examples

### 1. Basic Bootstrap and Configuration

```dart
import 'package:flutter/foundation.dart';
import 'package:simple_logger/simple_logger.dart';

void configureLogger() {
  final logger = SimpleLogger();

  logger.setLevel(
    kReleaseMode ? Level.WARNING : Level.FINEST,
    includeCallerInfo: kDebugMode,
  );

  // Optional: Custom emoji prefixes
  logger.levelPrefixes = {
    Level.INFO: '💡 INFO',
    Level.WARNING: '⚠️ WARNING',
    Level.SEVERE: '🚨 SEVERE',
  };
}
```

### 2. Logging Messages and Lazy Evaluation

```dart
import 'package:simple_logger/simple_logger.dart';

final logger = SimpleLogger();

void processPayment(String orderId, Map<String, dynamic> rawPayload) {
  // Simple message
  logger.info('Starting payment for order: $orderId');

  // Lazy evaluation (expensive serialization only executed if FINEST is enabled)
  logger.finest(() => 'Order payload: ${rawPayload.toString()}');

  try {
    // Business logic
  } catch (e, stackTrace) {
    logger.severe('Payment failed for $orderId', e, stackTrace);
  }
}
```

### 3. Custom Formatter for Production / CI

```dart
import 'package:simple_logger/simple_logger.dart';

void setupCiFormatter() {
  final logger = SimpleLogger();

  logger.formatter = (info) {
    final caller = info.callerInfo.isNotEmpty ? ' [${info.callerInfo}]' : '';
    return '[${info.time.toIso8601String()}] [${info.level.name}]$caller: ${info.message}';
  };
}
```

## Common Pitfalls & Anti-Patterns

- ❌ **Anti-pattern**: Enabling `includeCallerInfo: true` unconditionally in release builds, causing performance slowdowns.
  - ✔️ **Correct**: Guard caller info with `kDebugMode` or `assert(...)`.
- ❌ **Anti-pattern**: Using standard `print()` across the codebase alongside `SimpleLogger()`.
  - ✔️ **Correct**: Route all application logs through `SimpleLogger()` for consistent level filtering and formatting.
