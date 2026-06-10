// 📁 lib/core/services/iap/iap_service.dart
// Dùng: RevenueCat (purchases_flutter)
//
// ══ SETUP ══════════════════════════════════════════════════════
// await getIt<IapService>().initialize();
//
// ══ KIỂM TRA PREMIUM ═══════════════════════════════════════════
// getIt<IapService>().isPremium
// getIt<IapService>().premiumStream.listen(...)
//
// ══ MUA / RESTORE ══════════════════════════════════════════════
// final result = await iap.purchasePackage(package);
// final result = await iap.restorePurchases();
//
// ══ LOGIN / LOGOUT ═════════════════════════════════════════════
// await iap.loginUser(userId);
// await iap.logoutUser();

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:flutter_base/core/common/constants/app_constants.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'models/iap_models.dart';

/// Real IapService — chỉ register cho prod/stg.
/// Dev flavor dùng [MockIapService] (xem `iap_service_mock.dart`).
@LazySingleton(env: ['prod', 'stg'])
class IapService {
  static const _tag = 'IAP';

  // ── State ────────────────────────────────────────────────────

  bool _isPremium = false;
  bool _isInitialized = false;

  Offerings? _offerings;
  CustomerInfo? _customerInfo;

  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;
  Offerings? get offerings => _offerings;
  CustomerInfo? get customerInfo => _customerInfo;

  // ── Streams ──────────────────────────────────────────────────

  final _premiumCtrl = StreamController<bool>.broadcast();
  final _purchaseCtrl = StreamController<AppPurchaseResult>.broadcast();

  Stream<bool> get premiumStream => _premiumCtrl.stream;
  Stream<AppPurchaseResult> get purchaseStream => _purchaseCtrl.stream;

  // ── Init ──────────────────────────────────────────────────────

  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    final apiKey = _apiKey;
    if (apiKey == null) {
      Logger.error(
        'RevenueCat API key missing (using placeholders?). IAP will not work.',
        tag: _tag,
      );
      return;
    }

    try {
      if (FlavorConfig.isDev) await Purchases.setLogLevel(LogLevel.debug);

      final cfg = PurchasesConfiguration(apiKey);
      if (userId?.isNotEmpty == true) cfg.appUserID = userId;
      await Purchases.configure(cfg);

      // Now it is safe to call other Purchases methods
      _isInitialized = true;

      Purchases.addCustomerInfoUpdateListener(_updateStatus);

      await Future.wait([
        Purchases.getCustomerInfo().then(_updateStatus),
        fetchOfferings(),
      ]);
      Logger.success('IAP ready. Premium: $_isPremium', tag: _tag);
    } catch (e, s) {
      _isInitialized = false;
      Logger.error('IAP init failed', error: e, stackTrace: s, tag: _tag);
    }
  }

  // ── Offerings ────────────────────────────────────────────────

  Future<bool> fetchOfferings() async {
    if (!_isInitialized) {
      Logger.warning('fetchOfferings: IAP not initialized. Check your API keys.', tag: _tag);
      return false;
    }
    try {
      _offerings = await Purchases.getOfferings();
      final count = _offerings?.current?.availablePackages.length ?? 0;
      Logger.info('Offerings: $count packages', tag: _tag);
      return count > 0;
    } catch (e, s) {
      Logger.error('fetchOfferings failed', error: e, stackTrace: s, tag: _tag);
      return false;
    }
  }

  // ── Purchase & Restore ────────────────────────────────────────

  Future<AppPurchaseResult> purchasePackage(Package package, {PromotionalOffer? offer}) async {
    if (!_isInitialized) return AppPurchaseResult.error('IAP not initialized');

    try {
      Logger.info('Purchasing: ${package.identifier}', tag: _tag);

      // ✅ gọn hơn — bỏ late final + if/else
      final info = offer != null
          ? (await Purchases.purchaseDiscountedPackage(package, offer)).customerInfo
          : (await Purchases.purchasePackage(package)).customerInfo;

      final result = _updateStatus(info)
          ? AppPurchaseResult.success()
          : AppPurchaseResult.error('Premium not activated');

      _purchaseCtrl.add(result);
      return result;
    } on PlatformException catch (e) {
      final result = _mapPurchaseError(PurchasesErrorHelper.getErrorCode(e), e);
      _purchaseCtrl.add(result);
      return result;
    } catch (e, s) {
      Logger.error('Purchase failed', error: e, stackTrace: s, tag: _tag);
      final result = AppPurchaseResult.error('Purchase failed: $e');
      _purchaseCtrl.add(result);
      return result;
    }
  }

  Future<AppPurchaseResult> restorePurchases() async {
    if (!_isInitialized) return AppPurchaseResult.error('IAP not initialized');

    try {
      Logger.info('Restoring purchases…', tag: _tag);
      final info = await Purchases.restorePurchases();
      final ok = _updateStatus(info);
      Logger.info('Restore done. Premium=$ok', tag: _tag);
      return ok
          ? AppPurchaseResult.success('Purchases restored')
          : AppPurchaseResult.error('No active subscriptions found');
    } catch (e, s) {
      Logger.error('Restore failed', error: e, stackTrace: s, tag: _tag);
      return AppPurchaseResult.error('Restore failed: $e');
    }
  }

  // ── User ──────────────────────────────────────────────────────

  Future<void> loginUser(String userId) async {
    if (!_isInitialized) return;
    try {
      _updateStatus((await Purchases.logIn(userId)).customerInfo);
    } catch (e, s) {
      Logger.error('Login failed', error: e, stackTrace: s, tag: _tag);
    }
  }

  Future<void> logoutUser() async {
    if (!_isInitialized) return;
    try {
      _updateStatus(await Purchases.logOut());
    } catch (e, s) {
      Logger.error('Logout failed', error: e, stackTrace: s, tag: _tag);
    }
  }

  // ── Private ───────────────────────────────────────────────────

  String? get _apiKey {
    final key = Platform.isAndroid
        ? AppConstants.revenueCatGoogleKey
        : Platform.isIOS
        ? AppConstants.revenueCatAppleKey
        : null;
    if (key == null || key.isEmpty || key.contains('placeholder')) return null;
    return key;
  }

  /// Cập nhật trạng thái premium. Trả về trạng thái mới.
  bool _updateStatus(CustomerInfo info) {
    _customerInfo = info;
    final active = info.entitlements.all[AppConstants.premiumEntitlement]?.isActive ?? false;
    if (_isPremium != active) {
      _isPremium = active;
      _premiumCtrl.add(_isPremium);
      Logger.info('Premium → $_isPremium', tag: _tag);
    }
    return _isPremium;
  }

  /// Map RevenueCat error code → AppPurchaseResult.
  AppPurchaseResult _mapPurchaseError(PurchasesErrorCode code, PlatformException e) =>
      switch (code) {
        PurchasesErrorCode.purchaseCancelledError => AppPurchaseResult.cancelled(),
        PurchasesErrorCode.purchaseNotAllowedError => AppPurchaseResult.error(
          'Purchases not allowed on this device',
        ),
        PurchasesErrorCode.purchaseInvalidError => AppPurchaseResult.error(
          'Invalid purchase. Please try again',
        ),
        PurchasesErrorCode.networkError => AppPurchaseResult.error(
          'Network error. Check your connection',
        ),
        PurchasesErrorCode.storeProblemError => AppPurchaseResult.error(
          'Store unavailable. Try again later',
        ),
        _ => AppPurchaseResult.error('Purchase failed: ${e.message}'),
      };
}
