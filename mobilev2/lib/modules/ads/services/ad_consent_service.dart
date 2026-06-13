import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/services/utils/logger.dart';

/// Tổng hợp 2 luồng consent BẮT BUỘC trước khi load ads:
///
/// 1. **UMP (User Messaging Platform)** — GDPR/CCPA. Google bắt buộc khi user
///    ở EU/UK/California; account bị flag nếu thiếu.
/// 2. **ATT (App Tracking Transparency)** — iOS 14.5+. Không request ATT →
///    `IDFA = 0` → SKAdNetwork rỗng → CPM iOS giảm 3–5×.
///
/// Trình tự BẮT BUỘC: ATT trước (iOS) → UMP sau → MobileAds.initialize().
///
/// Service idempotent — gọi `ensureConsent()` nhiều lần an toàn.
@lazySingleton
class AdConsentService {
  AdConsentService();

  static const _tag = 'ADS CONSENT';

  bool _attRequested = false;
  bool _umpRequested = false;

  TrackingStatus? _attStatus;
  ConsentStatus? _consentStatus;

  TrackingStatus? get attStatus => _attStatus;
  ConsentStatus? get consentStatus => _consentStatus;

  /// `true` khi ads có thể request — UMP chưa REQUIRED hoặc đã obtained.
  bool get canRequestAds {
    final s = _consentStatus;
    return s == null ||
        s == ConsentStatus.notRequired ||
        s == ConsentStatus.obtained;
  }

  /// Chạy 1 lần ở `AppInitializer._initAds()` TRƯỚC khi `MobileAds.initialize()`.
  Future<void> ensureConsent() async {
    await _requestAtt();
    await _requestUmp();
  }

  // ── ATT (iOS only) ─────────────────────────────────────────────

  Future<void> _requestAtt() async {
    if (!Platform.isIOS || _attRequested) return;
    _attRequested = true;
    try {
      final current = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (current == TrackingStatus.notDetermined) {
        // Apple guideline: delay nhẹ để system dialog không đè splash.
        await Future<void>.delayed(const Duration(milliseconds: 200));
        _attStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
      } else {
        _attStatus = current;
      }
      Logger.info('ATT status: $_attStatus', tag: _tag);
    } catch (e, s) {
      Logger.error('ATT request failed', error: e, stackTrace: s, tag: _tag);
    }
  }

  // ── UMP (GDPR/CCPA) ────────────────────────────────────────────

  Future<void> _requestUmp() async {
    if (_umpRequested) return;
    _umpRequested = true;
    try {
      await _updateInfo(ConsentRequestParameters());
      if (_consentStatus == ConsentStatus.required) {
        await _loadAndShowFormIfNeeded();
      }
      Logger.info('UMP status: $_consentStatus', tag: _tag);
    } catch (e, s) {
      Logger.error('UMP request failed', error: e, stackTrace: s, tag: _tag);
    }
  }

  Future<void> _updateInfo(ConsentRequestParameters params) {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        _consentStatus = await ConsentInformation.instance.getConsentStatus();
        if (!completer.isCompleted) completer.complete();
      },
      (err) {
        Logger.warning(
          'UMP info update failed: ${err.errorCode} ${err.message}',
          tag: _tag,
        );
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  Future<void> _loadAndShowFormIfNeeded() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((err) async {
      if (err != null) {
        Logger.warning(
          'UMP form failed: ${err.errorCode} ${err.message}',
          tag: _tag,
        );
      }
      _consentStatus = await ConsentInformation.instance.getConsentStatus();
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  /// Cho phép user thay đổi consent từ Settings — hiển thị privacy options form.
  Future<void> showPrivacyOptionsForm() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((err) async {
      if (err != null) {
        Logger.warning(
          'Privacy options failed: ${err.errorCode} ${err.message}',
          tag: _tag,
        );
      }
      _consentStatus = await ConsentInformation.instance.getConsentStatus();
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  Future<bool> get isPrivacyOptionsRequired async {
    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Debug-only — reset consent state để test lại UMP flow.
  Future<void> resetForDebug() async {
    await ConsentInformation.instance.reset();
    _umpRequested = false;
    _consentStatus = null;
    Logger.info('UMP reset (debug)', tag: _tag);
  }
}
