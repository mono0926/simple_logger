## 1.5.1

- Add `assertOrShout`.
  - Execute assert and shout if condition is false.

## 1.4.0

- Rename to `LoggerMode.print` from `LoggerMode.stdout`.

## 1.3.0 

- Omit time if `mode` is `LoggerMode.log`.

## 1.2.0

- Include `stackTrace` to log if `mode` is `LoggerMode.log` and `stackTraceLevel` is higher than passed `level`.

## 1.1.0

- Add LoggerMode
  - Default is LoggerMode.log, which uses `dart:developer`'s `log` function.
  - If LoggerMode.stdout is selected, `print` function will be used.
## 1.0.0

- Bump up to 1.0.0

## 0.7.5

- Update documentation.

## 0.7.0

- Rename to `includeCallerInfo` from `includesCallerInfo`.

## 0.6.0

- Rename to `includesCallerInfo` from `stacktraceEnabled`.
- Documentation comments added.

## 0.5.0

- Rename to `callerFrame` from `lineFrame`
- Change log to 'caller info not available' from 'stacktrace disabled' when `includesCallerInfo` is `false`

## 0.4.0

- Rename to `includesCallerInfo` from `stacktraceEnabled`


## 0.2.0

- Delete `now` property


## 0.1.1

- First Release
