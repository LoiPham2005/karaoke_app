// 📁 lib/modules/iap/iap_service_mock.dart
//
// Mock IapService — KHÔNG cần RevenueCat API key.
// Test UI flow purchase/restore mà không tốn tiền & không cần Google Play setup.
//
// Cơ chế DI: register cho dev flavor qua `@LazySingleton(as: IapService, env: ['dev'])`.
// Khi chạy `flutter run --flavor dev` → getIt<IapService>() trả về MockIapService.
// Khi chạy prod/stg → IapService thật (gọi RevenueCat).
import 'dart:async';

import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'iap_service.dart';
import 'models/iap_models.dart';

@LazySingleton(as: IapService, env: ['dev'])
class MockIapService implements IapService {
  static const _tag = 'IAP-MOCK';

  bool _isPremium = false;
  final _premiumCtrl = StreamController<bool>.broadcast();
  final _purchaseCtrl = StreamController<AppPurchaseResult>.broadcast();

  // ── Getters ─────────────────────────────────────────────────

  @override
  bool get isPremium => _isPremium;

  @override
  bool get isInitialized => true;

  /// Mock không có offerings thật — UI nên dùng data hardcode.
  @override
  Offerings? get offerings => null;

  @override
  CustomerInfo? get customerInfo => null;

  // ── Streams ─────────────────────────────────────────────────

  @override
  Stream<bool> get premiumStream => _premiumCtrl.stream;

  @override
  Stream<AppPurchaseResult> get purchaseStream => _purchaseCtrl.stream;

  // ── Lifecycle ───────────────────────────────────────────────

  @override
  Future<void> initialize({String? userId}) async {
    Logger.success(
      '🧪 MockIapService ready (no real RevenueCat). userId=$userId',
      tag: _tag,
    );
  }

  // ── Offerings ───────────────────────────────────────────────

  @override
  Future<bool> fetchOfferings() async {
    Logger.info(
      'Mock fetchOfferings → 0 packages. UI Premium nên dùng package list hardcode khi dev.',
      tag: _tag,
    );
    return false;
  }

  // ── Purchase & Restore ──────────────────────────────────────

  @override
  Future<AppPurchaseResult> purchasePackage(
    Package package, {
    PromotionalOffer? offer,
  }) async {
    Logger.info('Mock purchase: ${package.identifier}', tag: _tag);
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    _setPremium(true);
    final result = AppPurchaseResult.success('Mock purchase successful');
    _purchaseCtrl.add(result);
    return result;
  }

  @override
  Future<AppPurchaseResult> restorePurchases() async {
    Logger.info('Mock restore…', tag: _tag);
    await Future.delayed(const Duration(milliseconds: 500));

    _setPremium(true);
    return AppPurchaseResult.success('Mock restored');
  }

  // ── User ────────────────────────────────────────────────────

  @override
  Future<void> loginUser(String userId) async {
    Logger.info('Mock loginUser: $userId', tag: _tag);
  }

  @override
  Future<void> logoutUser() async {
    Logger.info('Mock logoutUser → reset premium', tag: _tag);
    _setPremium(false);
  }

  // ── Helpers ─────────────────────────────────────────────────

  void _setPremium(bool value) {
    if (_isPremium != value) {
      _isPremium = value;
      _premiumCtrl.add(_isPremium);
      Logger.info('Mock Premium → $_isPremium', tag: _tag);
    }
  }

  /// 🧪 Reset premium về false — dùng cho test/debug.
  /// Không có trên IapService gốc, gọi qua `(getIt<IapService>() as MockIapService).resetPremium()`.
  void resetPremium() {
    Logger.info('🔄 Mock reset premium → false', tag: _tag);
    _setPremium(false);
  }

  /// 🧪 Danh sách packages giả để render UI Premium khi chạy dev.
  /// UI Premium page nên check `svc is MockIapService` để dùng list này.
  List<MockPremiumPackage> get mockPackages => const [
    MockPremiumPackage(
      id: 'premium_monthly',
      title: 'Gói tháng',
      description: 'Truy cập toàn bộ tính năng Premium trong 1 tháng',
      priceString: '49.000 đ',
      badge: null,
    ),
    MockPremiumPackage(
      id: 'premium_yearly',
      title: 'Gói năm',
      description: 'Tiết kiệm 50%! Truy cập toàn bộ tính năng Premium 1 năm',
      priceString: '299.000 đ',
      badge: 'TIẾT KIỆM 50%',
    ),
    MockPremiumPackage(
      id: 'premium_lifetime',
      title: 'Trọn đời',
      description: 'Mua 1 lần — dùng vĩnh viễn. Không hết hạn.',
      priceString: '999.000 đ',
      badge: 'TỐT NHẤT',
    ),
  ];

  /// 🧪 Mua mock package qua ID. UI gọi method này thay vì `purchasePackage`.
  Future<AppPurchaseResult> mockPurchase(String packageId) async {
    Logger.info('Mock purchase package: $packageId', tag: _tag);
    await Future.delayed(const Duration(seconds: 1));
    _setPremium(true);
    final result = AppPurchaseResult.success('Mock purchase successful');
    _purchaseCtrl.add(result);
    return result;
  }
}

/// 🧪 Package data class cho mock — không phụ thuộc RevenueCat SDK.
class MockPremiumPackage {
  final String id;
  final String title;
  final String description;
  final String priceString;
  final String? badge;

  const MockPremiumPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.priceString,
    this.badge,
  });
}
