// ════════════════════════════════════════════════════════════════
// 📁 lib/routes/config/route_names.dart
// ════════════════════════════════════════════════════════════════

/// Centralized route path constants — single source of truth.
/// Dùng trực tiếp trong @TypedGoRoute annotation và GoRouter redirect.
class RouteNames {
  RouteNames._();

  // ── Auth & Onboarding ───────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ── Main shell (BottomNav) ──────────────────────────────────
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String library = '/library';
  static const String profile = '/profile';

  // ── Song / Player / Playlist ────────────────────────────────
  static const String songDetail = '/song/:id';
  static const String player = '/play/:id';
  static const String playlistDetail = '/playlist/:id';
  static const String queue = '/queue';
  static const String category = '/category/:slug';

  // ── Settings ────────────────────────────────────────────────
  static const String settings = '/settings';
  static const String editProfile = '/settings/profile';
  static const String premium = '/premium';

  // ── Debug ────────────────────────────────────────
  static const String appConfigDebug = '/app-config-debug';
}
