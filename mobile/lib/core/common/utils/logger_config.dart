// ════════════════════════════════════════════════════════════════
// 📁 lib/core/config/logger_config.dart
// ════════════════════════════════════════════════════════════════

import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:flutter_base/core/common/utils/logger.dart';

class LoggerConfig {
  static void configure() {
    LogConfig.enabled = FlavorConfig.enableLogging;
    LogConfig.showHttp = FlavorConfig.enableLogging;
    LogConfig.showBloc = FlavorConfig.isDev;
    LogConfig.maskSensitive = !FlavorConfig.isDev;
    LogConfig.crashReporting = FlavorConfig.enableCrashReporting;
  }
}

// ════════════════════════════════════════════════════════════════
// 📘 USAGE EXAMPLES
// ════════════════════════════════════════════════════════════════

/*

void main() {
  // Configure logger theo environment
  LoggerConfig.configure();

  runApp(MyApp());
}

// Basic logs
Logger.info('App started');
Logger.success('Login successful');
Logger.warning('Token expiring soon');
Logger.debug('Cache hit: user_123');

// Error log
Logger.error(
  'Failed to load users',
  error: exception,
  stackTrace: stackTrace,
);

// HTTP logs (tự động gọi từ Dio interceptor)
Logger.httpRequest('POST', '/api/login', data: {'email': 'user@test.com'});
Logger.httpResponse('POST', '/api/login', 200, duration: Duration(milliseconds: 234));

// BLoC logs (tự động gọi từ BlocObserver)
Logger.blocEvent('AuthBloc', LoginEvent());
Logger.blocState('AuthBloc', prevState, nextState);
Logger.blocError('AuthBloc', error, stackTrace);

*/
