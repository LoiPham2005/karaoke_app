// ════════════════════════════════════════════════════════════════
// 📁 lib/core/network/network_info.dart (UPGRADED)
// ════════════════════════════════════════════════════════════════
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Core network connectivity checker
/// - Không phụ thuộc UI/BuildContext
/// - Testable với DI
/// - Dùng trong business logic, repositories, use cases
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetStatus> get onStatusChange;

  // Helper methods
  String getConnectionTypeName(InternetStatus status);
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _internetConnection;

  NetworkInfoImpl(this._internetConnection);

  @override
  Future<bool> get isConnected async {
    return await _internetConnection.hasInternetAccess;
  }

  @override
  Stream<InternetStatus> get onStatusChange {
    return _internetConnection.onStatusChange;
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  @override
  String getConnectionTypeName(InternetStatus status) {
    switch (status) {
      case InternetStatus.connected:
        return 'Connected';
      case InternetStatus.disconnected:
        return 'Disconnected';
    }
  }
}
