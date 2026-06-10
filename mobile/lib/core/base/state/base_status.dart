// ════════════════════════════════════════════════════════════════
// 📁 lib/core/state/base_status.dart
// ════════════════════════════════════════════════════════════════

/// 🎯 Universal status for all state management scenarios
/// Covers both queries (fetch data) and mutations (submit actions)
enum BaseStatus {
  /// Initial state - nothing has happened yet
  initial,

  /// Loading data or processing action
  /// Use flags (isRefreshing, isLoadingMore, isSubmitting) to differentiate
  loading,

  /// Operation completed successfully
  success,

  /// Success but no data returned (empty list, null result, etc.)
  empty,

  /// Operation failed
  failure,
}

/// 🔐 Authentication-specific status
enum AuthStatus {
  /// Not determined yet (app startup, checking cached session)
  initial,

  /// Checking authentication (validating token, refreshing session)
  loading,

  /// Not logged in
  unauthenticated,

  /// Successfully authenticated
  authenticated,

  /// Token/session expired - needs re-authentication
  expired,

  /// Authenticated but lacks permission for current resource
  unauthorized,
}
