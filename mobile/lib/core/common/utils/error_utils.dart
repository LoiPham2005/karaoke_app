import 'package:flutter/foundation.dart';

/// 🛠️ Utility for error handling and location extraction
class ErrorUtils {
  ErrorUtils._();

  /// Extracts the file location (lib/...) from [FlutterErrorDetails]
  static String? extractLocation(FlutterErrorDetails details) {
    try {
      final msg = details.toString();

      // 1. Try to extract from summary/context (matches package:app or lib/)
      final match = RegExp(r'(?:package:[a-z0-9_]+/|lib/)([^)\s]+\.dart:\d+:\d+)').firstMatch(msg);
      if (match != null) return 'lib/${match.group(1)}';

      // 2. Fallback to stack trace analysis
      if (details.stack != null) {
        final stack = details.stack.toString();
        // Adjust the package name match if necessary
        for (final line in stack.split('\n')) {
          if (line.contains('package:flutter_base') || line.contains('lib/')) {
            final m = RegExp(r'(?:package:[a-z0-9_]+/|lib/)([^)\s]+\.dart:\d+:\d+)').firstMatch(line);
            if (m != null) return 'lib/${m.group(1)}';
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
