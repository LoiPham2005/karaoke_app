// lib/core/storage/storage_service.dart
import 'dart:convert';

import 'package:flutter_base/core/data/storage/local/local_storage_keys.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton()
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// ════════════════════════════════════════════════════════════════
  /// GENERIC METHODS
  /// ════════════════════════════════════════════════════════════════
  T? get<T>(String key) {
    return _prefs.get(key) as T?;
  }

  Future<bool> set<T>(String key, T value) {
    if (value is String) return _prefs.setString(key, value);
    if (value is bool) return _prefs.setBool(key, value);
    if (value is int) return _prefs.setInt(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    if (value is List<String>) return _prefs.setStringList(key, value);
    return Future.value(false);
  }

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clearAll() => _prefs.clear();

  /// ════════════════════════════════════════════════════════════════
  /// USER PROFILE & LOGIN STATUS (Non-sensitive)
  /// ════════════════════════════════════════════════════════════════

  /// Save user profile
  Future<bool> saveUser(Map<String, dynamic> user) async {
    try {
      return set(LocalStorageKeys.userProfile, json.encode(user));
    } catch (e) {
      return false;
    }
  }

  /// Get user profile
  Map<String, dynamic>? getUser() {
    try {
      final userString = get<String>(LocalStorageKeys.userProfile);
      if (userString == null) return null;
      return json.decode(userString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Set login status
  Future<bool> setLoggedIn(bool value) => set(LocalStorageKeys.isLogin, value);

  /// Check if logged in
  bool isLoggedIn() => get<bool>(LocalStorageKeys.isLogin) ?? false;

  /// Clear auth data (user profile + login status)
  /// NOTE: Tokens are cleared in SecureStorage.clearTokens()
  Future<void> clearAuthData() async {
    await remove(LocalStorageKeys.userProfile);
    await remove(LocalStorageKeys.isLogin);
  }

  /// ════════════════════════════════════════════════════════════════
  /// APP SETTINGS
  /// ════════════════════════════════════════════════════════════════

  /// Set first run flag
  Future<bool> setFirstRun(bool value) =>
      set(LocalStorageKeys.isFirstRun, value);

  /// Check if first run
  bool isFirstRun() => get<bool>(LocalStorageKeys.isFirstRun) ?? true;

  // ✅ Theme Color
  String? getThemeColor() => _prefs.getString(LocalStorageKeys.keyThemeColor);

  Future<bool> saveThemeColor(String color) =>
      _prefs.setString(LocalStorageKeys.keyThemeColor, color);

  // ✅ Theme Mode
  String? getThemeMode() => _prefs.getString(LocalStorageKeys.keyThemeMode);

  Future<bool> saveThemeMode(String mode) =>
      _prefs.setString(LocalStorageKeys.keyThemeMode, mode);

  /// Save language code
  Future<bool> saveLanguageCode(String code) =>
      set(LocalStorageKeys.languageCode, code);

  /// Get language code
  String? getLanguageCode() => get<String>(LocalStorageKeys.languageCode);
}
