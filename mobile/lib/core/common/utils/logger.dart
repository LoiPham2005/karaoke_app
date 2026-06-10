// ════════════════════════════════════════════════════════════════
// 📁 lib/core/utils/logger.dart (WITH BORDER FRAMES)
// ════════════════════════════════════════════════════════════════
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_base/core/services/crashlytics/crashlytics_service.dart';

/// Simple & Powerful Logger Configuration
class LogConfig {
  // ═══════════════════════════════════════════════════════════════
  // CORE SETTINGS
  // ═══════════════════════════════════════════════════════════════

  /// Enable all logs (master switch)
  static bool enabled = kDebugMode;

  /// Show HTTP logs
  static bool showHttp = kDebugMode;

  /// Show BLoC logs
  static bool showBloc = kDebugMode;

  /// Mask sensitive data (password, token, etc.)
  static bool maskSensitive = !kDebugMode;

  /// Send errors to crash reporting (Firebase, Sentry)
  static bool crashReporting = kReleaseMode;

  // ═══════════════════════════════════════════════════════════════
  // SENSITIVE FIELDS (auto-masked)
  // ═══════════════════════════════════════════════════════════════

  static const sensitiveFields = {
    'password',
    'token',
    'access_token',
    'refresh_token',
    'authorization',
    'secret',
    'api_key',
    'pin',
    'otp',
    'cvv',
  };
}

/// Logger with Beautiful Border Frames
class Logger {
  Logger._();

  static const _name = 'APP';
  static const _maxLength = 10000;
  static const _width = 60;

  // Box drawing characters
  static const _line = '═';
  static const _divider = '─';
  static const _topLeft = '╔';
  static const _topRight = '╗';
  static const _bottomLeft = '╚';
  static const _bottomRight = '╝';
  static const _middleLeft = '╠';
  static const _middleRight = '╣';
  static const _vertical = '║';

  // Border helpers
  static String get _top => '$_topLeft${_line * _width}$_topRight';
  static String get _middle => '$_middleLeft${_line * _width}$_middleRight';
  static String get _bottom => '$_bottomLeft${_line * _width}$_bottomRight';
  static String get _section => '$_middleLeft${_divider * _width}$_middleRight';

  // ═══════════════════════════════════════════════════════════════
  // 📝 BASIC LOGS
  // ═══════════════════════════════════════════════════════════════

  static void info(String message, {String? tag}) {
    if (!LogConfig.enabled) return;
    final tagStr = tag != null ? '[$tag] ' : '';
    developer.log('ℹ️ $tagStr$message', name: _name);
  }

  static void warning(String message, {String? tag}) {
    if (!LogConfig.enabled) return;
    final tagStr = tag != null ? '[$tag] ' : '';
    developer.log('⚠️ $tagStr$message', name: _name);
  }

  static void success(String message, {String? tag}) {
    if (!LogConfig.enabled) return;
    final tagStr = tag != null ? '[$tag] ' : '';
    developer.log('✅ $tagStr$message', name: _name);
  }

  static void debug(String message, {String? tag}) {
    if (!LogConfig.enabled) return;
    final tagStr = tag != null ? '[$tag] ' : '';
    developer.log('🐛 $tagStr$message', name: _name);
  }

  // ═══════════════════════════════════════════════════════════════
  // ❌ ERROR LOG (WITH BORDER)
  // ═══════════════════════════════════════════════════════════════

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    String? location,
  }) {
    if (!LogConfig.enabled) return;

    final buffer = StringBuffer();
    final tagStr = tag != null ? '[$tag] ' : '';

    buffer.writeln('\n$_top');
    buffer.writeln('$_vertical ❌ ERROR $tagStr');
    buffer.writeln(_middle);
    buffer.writeln('$_vertical $message');

    if (error != null) {
      buffer.writeln(_section);
      buffer.writeln('$_vertical Details: ${error.toString()}');
    }

    if (location != null) {
      buffer.writeln(_section);
      buffer.writeln('$_vertical Location: $location');
    }

    if (kDebugMode && stackTrace != null) {
      buffer.writeln(_section);
      buffer.writeln('$_vertical Stack Trace (Top 3):');
      final lines = stackTrace.toString().split('\n').take(3);
      for (final line in lines) {
        buffer.writeln('$_vertical   $line');
      }
    }

    buffer.writeln(_bottom);
    developer.log(buffer.toString(), name: _name, level: 1000);

    if (LogConfig.crashReporting) {
      _sendToCrashReporting(message, error, stackTrace);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌐 HTTP REQUEST (WITH BORDER)
  // ═══════════════════════════════════════════════════════════════

  static void httpRequest(String method, String url, {dynamic data}) {
    if (!LogConfig.enabled || !LogConfig.showHttp) return;

    final buffer = StringBuffer();
    final uri = Uri.parse(url);

    // buffer.writeln(_top);
    buffer.writeln('\n$_top');
    buffer.writeln('$_vertical 🚀 REQUEST: $method');
    buffer.writeln(_middle);
    buffer.writeln('$_vertical Domain: ${uri.host}');
    buffer.writeln('$_vertical Endpoint: ${uri.path}');

    if (uri.queryParameters.isNotEmpty) {
      buffer.writeln('$_vertical Query: ${uri.queryParameters}');
    }

    // Log body for mutations
    if (data != null && ['POST', 'PUT', 'PATCH'].contains(method)) {
      buffer.writeln(_section);
      buffer.writeln('$_vertical 📦 Body:');
      final body = _formatBody(data);
      for (final line in body.split('\n')) {
        buffer.writeln('$_vertical   $line');
      }
    }

    buffer.writeln(_bottom);
    developer.log(buffer.toString(), name: _name);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌐 HTTP RESPONSE (WITH BORDER)
  // ═══════════════════════════════════════════════════════════════

  static void httpResponse(
    String method,
    String url,
    int statusCode, {
    dynamic data,
    Duration? duration,
  }) {
    if (!LogConfig.enabled || !LogConfig.showHttp) return;

    final buffer = StringBuffer();
    final uri = Uri.parse(url);
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final emoji = isSuccess ? '✅' : '⚠️';
    final time = duration != null ? ' (${duration.inMilliseconds}ms)' : '';

    // buffer.writeln(_top);
    buffer.writeln('\n$_top');
    buffer.writeln('$_vertical $emoji RESPONSE: $statusCode$time');
    buffer.writeln(_middle);
    buffer.writeln('$_vertical $method ${uri.path}');

    // Log response data
    if (data != null) {
      buffer.writeln(_section);
      buffer.writeln('$_vertical 📥 Response Data:');
      final response = _formatJson(data);
      for (final line in response.split('\n')) {
        buffer.writeln('$_vertical   $line');
      }
    }

    buffer.writeln(_bottom);
    developer.log(buffer.toString(), name: _name);

    // Send 5xx errors to crash reporting
    if (LogConfig.crashReporting && statusCode >= 500) {
      _sendToCrashReporting('HTTP $statusCode: $method $url', data, null);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌐 HTTP ERROR (WITH BORDER)
  // ═══════════════════════════════════════════════════════════════

  static void httpError(
    String method,
    String url,
    int? statusCode,
    dynamic errorData, {
    Duration? duration,
  }) {
    if (!LogConfig.enabled || !LogConfig.showHttp) return;

    final buffer = StringBuffer();
    final time = duration != null ? ' (${duration.inMilliseconds}ms)' : '';

    // buffer.writeln(_top);
    buffer.writeln('\n$_top');
    buffer.writeln('$_vertical ❌ HTTP ERROR [$statusCode]$time');
    buffer.writeln(_middle);
    buffer.writeln('$_vertical $method $url');

    if (errorData != null) {
      buffer.writeln(_section);
      buffer.writeln('$_vertical Response:');
      final response = _formatJson(errorData);
      for (final line in response.split('\n')) {
        buffer.writeln('$_vertical   $line');
      }
    }

    buffer.writeln(_bottom);
    developer.log(buffer.toString(), name: _name, level: 900);

    if (LogConfig.crashReporting) {
      _sendToCrashReporting('HTTP Error $statusCode: $method $url', errorData, null);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 BLOC EVENT
  // ═══════════════════════════════════════════════════════════════

  static void blocEvent(String bloc, Object event) {
    if (!LogConfig.enabled || !LogConfig.showBloc) return;
    developer.log('📤 [$bloc] ${event.runtimeType}', name: _name);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 BLOC STATE
  // ═══════════════════════════════════════════════════════════════

  static void blocState(String bloc, dynamic prev, dynamic next) {
    if (!LogConfig.enabled || !LogConfig.showBloc) return;

    final prevStatus = _extractStatus(prev);
    final nextStatus = _extractStatus(next);

    // Only log status changes
    if (prevStatus != nextStatus) {
      developer.log('📥 [$bloc] $prevStatus → $nextStatus', name: _name);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 BLOC ERROR (WITH BORDER)
  // ═══════════════════════════════════════════════════════════════

  static void blocError(String bloc, Object error, StackTrace stackTrace) {
    final buffer = StringBuffer();

    buffer.writeln(_top);
    buffer.writeln('$_vertical ❌ BLOC ERROR [$bloc]');
    buffer.writeln(_middle);
    buffer.writeln('$_vertical ${error.toString()}');

    if (kDebugMode) {
      buffer.writeln(_section);
      buffer.writeln('$_vertical Stack Trace:');
      final lines = stackTrace.toString().split('\n').take(3);
      for (final line in lines) {
        buffer.writeln('$_vertical   $line');
      }
    }

    buffer.writeln(_bottom);
    developer.log(buffer.toString(), name: _name, level: 1000);

    if (LogConfig.crashReporting) {
      _sendToCrashReporting('BLoC Error: $bloc', error, stackTrace);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📺 ADS TABLE LOG
  // ═══════════════════════════════════════════════════════════════

  /// Log thông tin ads dạng bảng — dễ quan sát trên console.
  /// [rows] là list cặp [label, value] hiển thị theo hàng.
  static void adTable(
    String title, {
    required List<(String, String)> rows,
    String? tag,
    bool isError = false,
  }) {
    if (!LogConfig.enabled) return;

    const colLabel = 22; // độ rộng cột label
    const colValue = 50; // độ rộng cột value
    const totalWidth = colLabel + colValue + 3; // 3 = '│ ' + ' │' giữa + ' │'

    final hr = '├${'─' * (colLabel + 2)}┼${'─' * (colValue + 2)}┤';
    final top = '┌${'─' * (colLabel + 2)}┬${'─' * (colValue + 2)}┐';
    final bot = '└${'─' * (colLabel + 2)}┴${'─' * (colValue + 2)}┘';

    String cell(String text, int width) {
      if (text.length > width) return '${text.substring(0, width - 1)}…';
      return text.padRight(width);
    }

    final emoji = isError ? '❌' : '📺';
    final tagStr = tag != null ? ' [$tag]' : '';
    final buffer = StringBuffer('\n');

    buffer.writeln(top);

    // Title row (full-width)
    final titleLine = ' $emoji ADS$tagStr │ $title';
    buffer.writeln('│ ${cell(titleLine, totalWidth + 1)}│');
    buffer.writeln(hr);

    // Header
    buffer.writeln('│ ${'FIELD'.padRight(colLabel)} │ ${'VALUE'.padRight(colValue)} │');
    buffer.writeln(hr);

    // Data rows
    for (final (label, value) in rows) {
      buffer.writeln('│ ${cell(label, colLabel)} │ ${cell(value, colValue)} │');
    }

    buffer.writeln(bot);
    developer.log(buffer.toString(), name: _name, level: isError ? 900 : 0);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  static String _formatBody(dynamic data) {
    if (data == null) return 'null';

    if (data is Map) {
      final mapData = data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);

      final masked = _maskSensitiveData(mapData);
      return masked.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    }

    return _truncate(data.toString());
  }

  static String _formatJson(dynamic data) {
    if (data == null) return 'null';

    try {
      final json = const JsonEncoder.withIndent('  ').convert(data);
      return _truncate(json);
    } catch (_) {
      return _truncate(data.toString());
    }
  }

  static Map<String, dynamic> _maskSensitiveData(Map<String, dynamic> data) {
    if (!LogConfig.maskSensitive) return data;

    return data.map((key, value) {
      final isSensitive = LogConfig.sensitiveFields.any(
        (field) => key.toLowerCase().contains(field),
      );
      return MapEntry(key, isSensitive ? '******' : value);
    });
  }

  static String _extractStatus(dynamic state) {
    if (state == null) return 'null';

    final str = state.toString();
    final match = RegExp(r'status:\s*BlocStatus\.(\w+)').firstMatch(str);

    return match?.group(1) ?? state.runtimeType.toString();
  }

  static String _truncate(String text) {
    if (text.length <= _maxLength) return text;
    return '${text.substring(0, _maxLength)}...';
  }

  static void _sendToCrashReporting(String message, Object? error, StackTrace? stackTrace) {
    // Ghi breadcrumb message trước
    CrashlyticsService.instance.log('[Logger] $message');

    // Gửi lỗi lên Crashlytics
    final recordedError = error ?? Exception(message);
    CrashlyticsService.instance.recordError(
      recordedError,
      stackTrace,
      reason: message,
      fatal: false,
    );

    if (kDebugMode) {
      developer.log('📡 Crash reporting: $message', name: _name);
    }
  }
}
