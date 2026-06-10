// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  // ── User ──────────────────────────────────────────────────────
  static const String profile = '/user/profile';

  // ── Business ──────────────────────────────────────────────────
  static const String products = '/products';
  static const String categories = '/categories';
  static const String venues = '/public/venues';

  // ── Public endpoints (không cần auth) ─────────────────────────
  static const List<String> publicEndpoints = [
    login,
    register,
    refreshToken,
    forgotPassword,
    resetPassword,
    venues,
  ];
}
