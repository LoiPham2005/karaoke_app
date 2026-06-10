// 📁 lib/design/theme/styles/app_color_tokens.dart
//
// Theme tokens — `copyWith` / `lerp` / `==` / `hashCode` + extension trên
// `BuildContext` (vd: `context.brandPrimary`) sinh tự động bởi theme_tailor
// trong file part `app_color_tokens.tailor.dart`.
//
// CÁCH DÙNG (ưu tiên):
//   Container(color: context.bgPage)
//   Text(style: TextStyle(color: context.textTitle))
//   // ... 21 getters đều có sẵn trên `BuildContext`.
//
// (Khi cần truyền tokens qua function/widget):
//   final tokens = context.appColorTokens; // hoặc Theme.of(context).extension<AppColorTokens>()!
//
// THÊM TOKEN MỚI:
//   1. Thêm `final Color xxx` vào class + `required this.xxx` vào constructor
//   2. Thêm 1 dòng vào MỖI static instance (light/dark/blue/pink/green)
//   3. Chạy `build_runner build` để regen `.tailor.dart`
//
// THÊM THEME MỚI:
//   1. Thêm 1 static const instance (vd: `static const AppColorTokens purple = ...`)
//   2. Thêm 1 entry vào enum `AppPalette`

import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_color_tokens.tailor.dart';

/// Enum cho theme picker — gắn liền với data
enum AppPalette {
  light(label: '⚪ Light', icon: Icons.wb_sunny),
  dark(label: '⚫ Dark', icon: Icons.nightlight_round),
  blue(label: '🔵 Ocean Blue', icon: Icons.water_drop),
  pink(label: '🌸 Blossom Pink', icon: Icons.favorite),
  green(label: 'Green', icon: Icons.wb_sunny);

  final String label;
  final IconData icon;
  const AppPalette({required this.label, required this.icon});

  AppColorTokens get tokens => switch (this) {
    AppPalette.light => AppColorTokens.light,
    AppPalette.dark => AppColorTokens.dark,
    AppPalette.blue => AppColorTokens.blue,
    AppPalette.pink => AppColorTokens.pink,
    AppPalette.green => AppColorTokens.green,
  };
}

@TailorMixin()
class AppColorTokens extends ThemeExtension<AppColorTokens> with _$AppColorTokensTailorMixin {
  // ─── Brand ───
  @override
  final Color brandPrimary;
  @override
  final Color brandPrimaryLight;
  @override
  final Color brandSecondary;

  // ─── Background ───
  @override
  final Color bgPage;
  @override
  final Color bgCard;
  @override
  final Color bgInput;
  @override
  final Color bgModal;

  // ─── Text ───
  @override
  final Color textTitle;
  @override
  final Color textBody;
  @override
  final Color textSub;
  @override
  final Color textDisabled;
  @override
  final Color textOnPrimary;

  // ─── Border ───
  @override
  final Color borderDefault;
  @override
  final Color borderFocus;

  // ─── Status ───
  @override
  final Color statusSuccess;
  @override
  final Color statusWarning;
  @override
  final Color statusError;
  @override
  final Color statusInfo;

  // ─── Surface ───
  @override
  final Color surfaceShadow;
  @override
  final Color surfaceDivider;
  @override
  final Color surfaceOverlay;

  const AppColorTokens({
    required this.brandPrimary,
    required this.brandPrimaryLight,
    required this.brandSecondary,
    required this.bgPage,
    required this.bgCard,
    required this.bgInput,
    required this.bgModal,
    required this.textTitle,
    required this.textBody,
    required this.textSub,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.borderDefault,
    required this.borderFocus,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.statusInfo,
    required this.surfaceShadow,
    required this.surfaceDivider,
    required this.surfaceOverlay,
  });

  // ═══════════════════════════════════════════════════════════════
  // STATIC INSTANCES (1 cho mỗi theme)
  // ═══════════════════════════════════════════════════════════════

  static const AppColorTokens light = AppColorTokens(
    brandPrimary: Color(0xFF5C6BC0),
    brandPrimaryLight: Color(0xFF9FA8DA),
    brandSecondary: Color(0xFFFF7043),
    bgPage: Color(0xFFF4F6F9),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFF0F2F5),
    bgModal: Color(0xFFFFFFFF),
    textTitle: Color(0xFF1A1D23),
    textBody: Color(0xFF4A4F5A),
    textSub: Color(0xFF9098A9),
    textDisabled: Color(0xFFCDD1D9),
    textOnPrimary: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFE2E6ED),
    borderFocus: Color(0xFF5C6BC0),
    statusSuccess: Color(0xFF43A047),
    statusWarning: Color(0xFFFFB300),
    statusError: Color(0xFFE53935),
    statusInfo: Color(0xFF1E88E5),
    surfaceShadow: Color(0x1A000000),
    surfaceDivider: Color(0xFFECEFF4),
    surfaceOverlay: Color(0x80000000),
  );

  static const AppColorTokens dark = AppColorTokens(
    brandPrimary: Color(0xFF7986CB),
    brandPrimaryLight: Color(0xFFBBC4ED),
    brandSecondary: Color(0xFFFF8A65),
    bgPage: Color(0xFF0F1117),
    bgCard: Color(0xFF1A1D23),
    bgInput: Color(0xFF23262E),
    bgModal: Color(0xFF1A1D23),
    textTitle: Color(0xFFECEFF4),
    textBody: Color(0xFFB0B8C8),
    textSub: Color(0xFF6B7280),
    textDisabled: Color(0xFF3A3F4A),
    textOnPrimary: Color(0xFF0F1117),
    borderDefault: Color(0xFF2D3139),
    borderFocus: Color(0xFF7986CB),
    statusSuccess: Color(0xFF66BB6A),
    statusWarning: Color(0xFFFFCA28),
    statusError: Color(0xFFEF5350),
    statusInfo: Color(0xFF42A5F5),
    surfaceShadow: Color(0x33000000),
    surfaceDivider: Color(0xFF23262E),
    surfaceOverlay: Color(0x99000000),
  );

  static const AppColorTokens blue = AppColorTokens(
    brandPrimary: Color(0xFF1565C0),
    brandPrimaryLight: Color(0xFF5E92F3),
    brandSecondary: Color(0xFF00ACC1),
    bgPage: Color(0xFFEEF4FF),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFE8F0FE),
    bgModal: Color(0xFFFFFFFF),
    textTitle: Color(0xFF0D1B3E),
    textBody: Color(0xFF2C3E6B),
    textSub: Color(0xFF7D8FB3),
    textDisabled: Color(0xFFBCC8E4),
    textOnPrimary: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFD0DCEF),
    borderFocus: Color(0xFF1565C0),
    statusSuccess: Color(0xFF2E7D32),
    statusWarning: Color(0xFFF57F17),
    statusError: Color(0xFFC62828),
    statusInfo: Color(0xFF0277BD),
    surfaceShadow: Color(0x1A1565C0),
    surfaceDivider: Color(0xFFDDE6F5),
    surfaceOverlay: Color(0x801565C0),
  );

  static const AppColorTokens pink = AppColorTokens(
    brandPrimary: Color(0xFFAD1457),
    brandPrimaryLight: Color(0xFFE91E8C),
    brandSecondary: Color(0xFF7B1FA2),
    bgPage: Color(0xFFFFF0F6),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFFCE4EC),
    bgModal: Color(0xFFFFFFFF),
    textTitle: Color(0xFF3B0020),
    textBody: Color(0xFF6D2B4A),
    textSub: Color(0xFFB07090),
    textDisabled: Color(0xFFDDB8CA),
    textOnPrimary: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFEFCFDE),
    borderFocus: Color(0xFFAD1457),
    statusSuccess: Color(0xFF388E3C),
    statusWarning: Color(0xFFF9A825),
    statusError: Color(0xFFD32F2F),
    statusInfo: Color(0xFF1976D2),
    surfaceShadow: Color(0x1AAD1457),
    surfaceDivider: Color(0xFFF5DCE8),
    surfaceOverlay: Color(0x80AD1457),
  );

  static const AppColorTokens green = AppColorTokens(
    brandPrimary: Color(0xFF5C6BC0),
    brandPrimaryLight: Color(0xFF9FA8DA),
    brandSecondary: Color(0xFF5E92F3),
    bgPage: Color(0xFFF4F6F9),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFF0F2F5),
    bgModal: Color(0xFFFFFFFF),
    textTitle: Color(0xFF1A1D23),
    textBody: Color(0xFF4A4F5A),
    textSub: Color(0xFF9098A9),
    textDisabled: Color(0xFFCDD1D9),
    textOnPrimary: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFE2E6ED),
    borderFocus: Color(0xFF5C6BC0),
    statusSuccess: Color(0xFF43A047),
    statusWarning: Color(0xFFFFB300),
    statusError: Color(0xFFE53935),
    statusInfo: Color(0xFF1E88E5),
    surfaceShadow: Color(0x1A000000),
    surfaceDivider: Color(0xFFECEFF4),
    surfaceOverlay: Color(0x80000000),
  );
}
