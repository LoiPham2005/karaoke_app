import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/modules/ads/models/ad_placements.dart';
import 'package:karaoke/modules/ads/services/ad_consent_service.dart';
import 'package:karaoke/modules/ads/services/ad_manager.dart';

/// Gắn vào MaterialApp để theo dõi vòng đời.
/// Tự động hiển thị App Open ad khi app resume từ background.
///
/// Debounce 1s — tránh resume spam khi user swipe back-forth nhanh
/// (vd: chuyển app rồi quay lại ngay) → tránh request ad liên tục.
@lazySingleton
class AdLifecycleObserver extends WidgetsBindingObserver {
  AdLifecycleObserver(this._adManager, this._consent);

  final AdManager _adManager;
  final AdConsentService _consent;

  DateTime? _lastResumeAt;
  static const _resumeDebounce = Duration(seconds: 1);

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Reset state — gọi từ `AdManager.resetSession()`. Sau reset, lần resume
  /// tiếp theo sẽ KHÔNG bị debounce nhầm bởi `_lastResumeAt` cũ.
  void resetSession() {
    _lastResumeAt = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_consent.canRequestAds) return;

    final now = DateTime.now();
    final last = _lastResumeAt;
    if (last != null && now.difference(last) < _resumeDebounce) return;
    _lastResumeAt = now;

    // _adManager.showAppOpen(AppOpenPlacement.resume);
  }
}
