// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_base/core/data/storage/secure/secure_storage_keys.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  /// ════════════════════════════════════════════════════════════════
  /// GENERIC METHODS
  /// ════════════════════════════════════════════════════════════════

  /// Write encrypted data
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      Logger.debug('✅ Secure write: $key');
    } catch (e) {
      Logger.error('❌ Secure write error: $key', error: e);
      rethrow;
    }
  }

  /// Read decrypted data
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      Logger.error('❌ Secure read error: $key', error: e);
      return null;
    }
  }

  /// Delete encrypted data
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      Logger.debug('Secure delete: $key');
    } catch (e) {
      Logger.error('Secure delete error: $key', error: e);
      rethrow;
    }
  }

  /// Delete all encrypted data
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      Logger.debug('Secure deleteAll completed');
    } catch (e) {
      Logger.error('Secure deleteAll error', error: e);
      rethrow;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      Logger.error('Secure containsKey error: $key', error: e);
      return false;
    }
  }

  /// Read all encrypted data
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      Logger.error('Secure readAll error', error: e);
      return {};
    }
  }

  /// ════════════════════════════════════════════════════════════════
  /// TOKEN METHODS (SENSITIVE - ENCRYPTED)
  /// ════════════════════════════════════════════════════════════════

  /// Save access token (encrypted)
  Future<void> saveAccessToken(String token) async {
    await write(SecureStorageKeys.accessToken, token);
    Logger.info('🔐 Access token saved securely');
  }

  /// Get access token (decrypted)
  Future<String?> getAccessToken() async {
    return await read(SecureStorageKeys.accessToken);
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    await delete(SecureStorageKeys.accessToken);
    Logger.info('🔐 Access token deleted');
  }

  /// Save refresh token (encrypted)
  Future<void> saveRefreshToken(String token) async {
    await write(SecureStorageKeys.refreshToken, token);
    Logger.info('🔐 Refresh token saved securely');
  }

  /// Get refresh token (decrypted)
  Future<String?> getRefreshToken() async {
    return await read(SecureStorageKeys.refreshToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await delete(SecureStorageKeys.refreshToken);
    Logger.info('🔐 Refresh token deleted');
  }

  /// Clear all tokens at once
  Future<void> clearTokens() async {
    try {
      await deleteAccessToken();
      await deleteRefreshToken();
      Logger.info('🔐 All tokens cleared');
    } catch (e) {
      Logger.error('❌ Failed to clear tokens', error: e);
      rethrow;
    }
  }

  /// ════════════════════════════════════════════════════════════════
  /// PASSWORD & CREDENTIALS (SENSITIVE - ENCRYPTED)
  /// ════════════════════════════════════════════════════════════════

  /// Save password (encrypted)
  Future<void> savePassword(String password) async {
    await write(SecureStorageKeys.password, password);
    Logger.info('🔐 Password saved securely');
  }

  /// Get password (decrypted)
  Future<String?> getPassword() async {
    return await read(SecureStorageKeys.password);
  }

  /// Delete password
  Future<void> deletePassword() async {
    await delete(SecureStorageKeys.password);
    Logger.info('🔐 Password deleted');
  }

  /// ════════════════════════════════════════════════════════════════
  /// PIN & BIOMETRIC (SENSITIVE - ENCRYPTED)
  /// ════════════════════════════════════════════════════════════════

  /// Save PIN (encrypted)
  Future<void> savePIN(String pin) async {
    await write(SecureStorageKeys.pin, pin);
    Logger.info('🔐 PIN saved securely');
  }

  /// Get PIN (decrypted)
  Future<String?> getPIN() async {
    return await read(SecureStorageKeys.pin);
  }

  /// Delete PIN
  Future<void> deletePIN() async {
    await delete(SecureStorageKeys.pin);
    Logger.info('🔐 PIN deleted');
  }

  /// Enable biometric
  Future<void> enableBiometric(String value) async {
    await write(SecureStorageKeys.biometric, value);
    Logger.info('🔐 Biometric enabled');
  }

  /// Check if biometric enabled
  Future<bool> isBiometricEnabled() async {
    final value = await read(SecureStorageKeys.biometric);
    return value != null;
  }

  /// Delete biometric
  Future<void> disableBiometric() async {
    await delete(SecureStorageKeys.biometric);
    Logger.info('🔐 Biometric disabled');
  }

  /// ════════════════════════════════════════════════════════════════
  /// CLEAR ALL SENSITIVE DATA
  /// ════════════════════════════════════════════════════════════════

  /// Clear all sensitive data (comprehensive cleanup)
  Future<void> clearAll() async {
    try {
      await clearTokens();
      await deletePassword();
      await deletePIN();
      await disableBiometric();
      Logger.success('🔐 All sensitive data cleared');
    } catch (e) {
      Logger.error('Failed to clear all sensitive data', error: e);
      rethrow;
    }
  }
}
