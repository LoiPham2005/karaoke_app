// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/app_auth/app_auth_service.dart
// ════════════════════════════════════════════════════════════════
import 'dart:async';

import 'package:flutter_base/core/common/constants/api_endpoints.dart';
import 'package:flutter_base/core/common/mixins/api_handler_mixin.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/core/data/network/dio_client.dart';
import 'package:flutter_base/core/data/storage/local/local_storage_service.dart';
import 'package:flutter_base/core/data/storage/secure/secure_storage_service.dart';
// import 'package:flutter_base/features/auth/data/models/auth_model.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../base/state/base_status.dart';

/// 🎯 AppAuthService - Centralized Authentication Service for the entire App
@LazySingleton()
class AppAuthService with ApiHandlerMixin {
  final SecureStorage _secureStorage;
  final LocalStorageService _storageService;
  final DioClient _dioClient;

  AppAuthService(this._secureStorage, this._storageService, this._dioClient);

  final _authStateController = StreamController<AuthStatus>.broadcast();
  Stream<AuthStatus> get authStateStream => _authStateController.stream;

  AuthStatus _currentStatus = AuthStatus.initial;
  AuthStatus get currentStatus => _currentStatus;

  Future<AuthStatus> checkInitialStatus() async {
    final token = await _secureStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      _updateStatus(AuthStatus.unauthenticated);
      return AuthStatus.unauthenticated;
    }

    if (isTokenExpired(token)) {
      final success = await refreshToken();
      if (!success) {
        await logout();
        return AuthStatus.unauthenticated;
      }
    }

    final userData = _storageService.getUser();
    if (userData == null) {
      _updateStatus(AuthStatus.unauthenticated);
      return AuthStatus.unauthenticated;
    }

    _updateStatus(AuthStatus.authenticated);
    return AuthStatus.authenticated;
  }

  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final result = await safeCall(() async {
        final response = await _dioClient.dio.post(
            ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
        );
        return response.data as Map<String, dynamic>;
      });

      return result.fold(
        onSuccess: (data) async {
          final accessToken = data['access_token'] ?? data['accessToken'];
          final newRefreshToken = data['refresh_token'] ?? data['refreshToken'];

          if (accessToken != null) {
            await _secureStorage.saveAccessToken(accessToken);
          }
          if (newRefreshToken != null) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }
          return true;
        },
        onFailure: (failure) {
          Logger.error('AppAuthService: Refresh failed: ${failure.message}');
          return false;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkAndRefreshToken() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) return false;

    if (isTokenExpiringSoon(token)) {
      return await refreshToken();
    }
    return !isTokenExpired(token);
  }

  bool isTokenExpiringSoon(
    String token, {
    Duration threshold = const Duration(minutes: 5),
  }) {
    try {
      final expiryDate = JwtDecoder.getExpirationDate(token);
      return DateTime.now().isAfter(expiryDate.subtract(threshold));
    } catch (e) {
      return true;
    }
  }

  // Future<void> saveLoginData(AuthResponseModel response) async {
  //   await _secureStorage.saveAccessToken(response.accessToken);
  //   await _secureStorage.saveRefreshToken(response.refreshToken);
  //   await _storageService.saveUser(response.user.toJson());
  //   await _storageService.setLoggedIn(true);
  //   _updateStatus(AuthStatus.authenticated);
  // }

  Future<void> logout() async {
    try {
      await _secureStorage.clearTokens();
      await _storageService.clearAuthData();
      _dioClient.clearAuthorization();
      _updateStatus(AuthStatus.unauthenticated);
    } catch (e) {
      Logger.error('AppAuthService: Logout failed', error: e);
    }
  }

  // UserModel? get currentUser {
  //   final data = _storageService.getUser();
  //   if (data == null) return null;
  //   try {
  //     return UserModel.fromJson(data);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  void _updateStatus(AuthStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _authStateController.add(status);
      Logger.info('AppAuthService: Status -> $status');
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
