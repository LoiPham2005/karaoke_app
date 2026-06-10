// lib/core/storage/storage_keys.dart

// ═══════════════════════════════════════════════════════════════
// SENSITIVE DATA KEYS (FlutterSecureStorage)
// ═══════════════════════════════════════════════════════════════
class SecureStorageKeys {
  SecureStorageKeys._(); // Private constructor

  // Tokens (SENSITIVE - phải lưu encrypted)
  static const String accessToken = 'secure_access_token';
  static const String refreshToken = 'secure_refresh_token';

  // Credentials (SENSITIVE)
  static const String password = 'secure_password';
  static const String pin = 'secure_pin';
  static const String biometric = 'secure_biometric';
}
