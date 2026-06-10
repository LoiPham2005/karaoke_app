// 📁 lib/design/theme/styles/app_colors.dart
//
// ⚠️ HƯỚNG DẪN DÙNG MÀU:
//
// 1) MÀU THEO THEME (đổi theo light/dark/blue/pink/green):
//    → Dùng `context.brandPrimary`, `context.bgPage`, `context.textTitle`, …
//    → Định nghĩa trong: lib/design/theme/styles/app_color_tokens.dart
//    → Codegen: theme_tailor sinh `app_color_tokens.tailor.dart`
//
// 2) MÀU CỐ ĐỊNH (không bao giờ đổi theo theme):
//    → Dùng `AppColors.xxx` trong file này
//    → Ví dụ: brand bên thứ 3 (Facebook/Google), trắng/đen tuyệt đối, neutral grey
//
// 3) MÀU "LEGACY" bên dưới (primaryLightBrand, mutedLight, …):
//    → ❗ Đây là **LEGACY** từ giai đoạn đầu — trùng ý đồ với token theme.
//    → Code mới NÊN dùng `context.X` (token) để hỗ trợ multi-theme.
//    → Khi rảnh: migrate dần các reference sang token. Không thêm mới ở section này.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // CORE — Màu cố định tuyệt đối (không đổi theo theme)
  // ═══════════════════════════════════════════════════════════════
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // ─── Third-party brand (theo brand guideline) ───
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFDB4437);

  // ─── Neutral / Grey ───
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);

  // ═══════════════════════════════════════════════════════════════
  // ⚠️ LEGACY — Trùng ý đồ với token theme. Migrate sang
  //    context.X khi có dịp. KHÔNG thêm mới ở đây.
  // ═══════════════════════════════════════════════════════════════

  // ─── Semantic Text → context.textXxx ───
  @Deprecated('Dùng context.textTitle')
  static const Color textPrimary = Color(0xFF1A1D23);

  @Deprecated('Dùng context.textBody')
  static const Color textSecondary = Color(0xFF4A4F5A);

  @Deprecated('Dùng context.textSub')
  static const Color textHint = Color(0xFF9098A9);

  @Deprecated('Dùng context.textDisabled')
  static const Color textDisabled = Color(0xFFCDD1D9);

  // ─── Status → context.statusXxx ───
  @Deprecated('Dùng context.statusSuccess')
  static const Color success = Color(0xFF43A047);

  @Deprecated('Dùng context.statusWarning')
  static const Color warning = Color(0xFFFFB300);

  @Deprecated('Dùng context.statusError')
  static const Color error = Color(0xFFE53935);

  @Deprecated('Dùng context.statusInfo')
  static const Color info = Color(0xFF1E88E5);

  // ─── Light theme palette (Shadcn/Tailwind sync) — migrate dần sang token ───
  @Deprecated('Dùng context.bgCard')
  static const Color backgroundLight = Color(0xFFFFFFFF);
  @Deprecated('Dùng context.textTitle')
  static const Color foregroundLight = Color(0xFF020817);
  @Deprecated('Dùng context.bgCard')
  static const Color cardLight = Color(0xFFFFFFFF);
  @Deprecated('Dùng context.bgModal')
  static const Color popoverLight = Color(0xFFFFFFFF);
  @Deprecated('Dùng context.brandPrimary')
  static const Color primaryLightBrand = Color(0xFF16A34A);
  @Deprecated('Dùng context.textOnPrimary')
  static const Color primaryForegroundLight = Color(0xFFFFF1F2);
  @Deprecated('Dùng context.bgInput')
  static const Color secondaryLightBrand = Color(0xFFF1F5F9);
  @Deprecated('Dùng context.textTitle')
  static const Color secondaryForegroundLight = Color(0xFF0F172A);
  @Deprecated('Dùng context.bgInput')
  static const Color mutedLight = Color(0xFFF1F5F9);
  @Deprecated('Dùng context.textSub')
  static const Color mutedForegroundLight = Color(0xFF64748B);
  @Deprecated('Dùng context.bgInput')
  static const Color accentLight = Color(0xFFF1F5F9);
  @Deprecated('Dùng context.textTitle')
  static const Color accentForegroundLight = Color(0xFF0F172A);
  @Deprecated('Dùng context.statusError')
  static const Color destructiveLight = Color(0xFFEF4444);
  @Deprecated('Dùng context.textOnPrimary')
  static const Color destructiveForegroundLight = Color(0xFFF8FAFC);
  @Deprecated('Dùng context.borderDefault')
  static const Color borderLight = Color(0xFFE2E8F0);
  @Deprecated('Dùng context.bgInput')
  static const Color inputLight = Color(0xFFE2E8F0);
  @Deprecated('Dùng context.borderFocus')
  static const Color ringLight = Color(0xFF16A34A);

  // ─── Dark theme palette ───
  @Deprecated('Dùng context.bgPage')
  static const Color backgroundDark = Color(0xFF020817);
  @Deprecated('Dùng context.textTitle')
  static const Color foregroundDark = Color(0xFFF8FAFC);
  @Deprecated('Dùng context.bgCard')
  static const Color cardDark = Color(0xFF020817);
  @Deprecated('Dùng context.bgModal')
  static const Color popoverDark = Color(0xFF020817);
  @Deprecated('Dùng context.brandPrimary')
  static const Color primaryDarkBrand = Color(0xFF22C55E);
  @Deprecated('Dùng context.textOnPrimary')
  static const Color primaryForegroundDark = Color(0xFF052E16);
  @Deprecated('Dùng context.bgInput')
  static const Color secondaryDarkBrand = Color(0xFF1E293B);
  @Deprecated('Dùng context.textTitle')
  static const Color secondaryForegroundDark = Color(0xFFF8FAFC);
  @Deprecated('Dùng context.bgInput')
  static const Color mutedDark = Color(0xFF1E293B);
  @Deprecated('Dùng context.textSub')
  static const Color mutedForegroundDark = Color(0xFF94A3B8);
  @Deprecated('Dùng context.bgInput')
  static const Color accentDark = Color(0xFF1E293B);
  @Deprecated('Dùng context.textTitle')
  static const Color accentForegroundDark = Color(0xFFF8FAFC);
  @Deprecated('Dùng context.statusError')
  static const Color destructiveDark = Color(0xFF7F1D1D);
  @Deprecated('Dùng context.textOnPrimary')
  static const Color destructiveForegroundDark = Color(0xFFF8FAFC);
  @Deprecated('Dùng context.borderDefault')
  static const Color borderDark = Color(0xFF1E293B);
  @Deprecated('Dùng context.bgInput')
  static const Color inputDark = Color(0xFF1E293B);
  @Deprecated('Dùng context.borderFocus')
  static const Color ringDark = Color(0xFF16A34A);
}
