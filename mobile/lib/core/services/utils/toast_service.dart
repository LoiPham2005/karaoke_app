// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/toast_service.dart (SMART DIALOG)
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:injectable/injectable.dart';
import 'package:toastification/toastification.dart';

import '../../base/di/injection.dart';

ToastService get toast => getIt<ToastService>();

@LazySingleton()
class ToastService {
  // ── Default config cho toastification ──────────────────────────
  static const _defaultDuration = Duration(seconds: 3);
  static const _defaultAlignment = Alignment.topRight;
  static const _defaultStyle = ToastificationStyle.fillColored;

  // ═══════════════════════════════════════════════════════════════
  // TOAST METHODS — toastification
  // ═══════════════════════════════════════════════════════════════

  void success(String message, {String? title, Duration? duration, BuildContext? context}) =>
      _show(type: ToastificationType.success, message: message, title: title, duration: duration);

  void error(String message, {String? title, Duration? duration, BuildContext? context}) =>
      _show(type: ToastificationType.error, message: message, title: title, duration: duration);

  void warning(String message, {String? title, Duration? duration, BuildContext? context}) =>
      _show(type: ToastificationType.warning, message: message, title: title, duration: duration);

  void info(String message, {String? title, Duration? duration, BuildContext? context}) =>
      _show(type: ToastificationType.info, message: message, title: title, duration: duration);

  void _show({
    required ToastificationType type,
    required String message,
    String? title,
    Duration? duration,
  }) {
    toastification.show(
      type: type,
      style: _defaultStyle,
      alignment: _defaultAlignment,
      autoCloseDuration: duration ?? _defaultDuration,
      title: title != null
          ? Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15))
          : null,
      description: Text(
        message,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      showProgressBar: true,
      borderRadius: BorderRadius.circular(16),
      dragToClose: true,
      applyBlurEffect: false,
      closeButtonShowType: CloseButtonShowType.onHover,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOADING — flutter_smart_dialog (giữ nguyên)
  // ═══════════════════════════════════════════════════════════════

  void loading([String message = 'Đang tải...']) {
    SmartDialog.showLoading(
      msg: message,
      maskColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị loading quảng cáo (toàn màn trắng).
  void showAdLoading() {
    SmartDialog.showLoading(
      maskColor: Colors.white,
      builder: (context) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
      ),
    );
  }

  void stopLoading() => SmartDialog.dismiss(status: SmartStatus.loading);

  // ═══════════════════════════════════════════════════════════════
  // DISMISS & UTILS
  // ═══════════════════════════════════════════════════════════════

  /// Đóng tất cả: toast (toastification) + smart_dialog (loading/dialog).
  void dismiss() {
    SmartDialog.dismiss();
    toastification.dismissAll();
  }

  /// Đóng riêng toast (giữ loading/dialog).
  void dismissToasts() => toastification.dismissAll();

  void fromException(dynamic exception) {
    var message = 'Đã xảy ra lỗi';
    if (exception is Exception) {
      message = exception.toString().replaceAll('Exception: ', '');
    } else {
      message = exception.toString();
    }
    error(message, title: 'Lỗi');
  }
}
