class LocalStorageKeys {
  LocalStorageKeys._(); // Private constructor để không ai có thể tạo instance

  // ═══════════════════════════════════════════════════════════════
  // NON-SENSITIVE DATA (SharedPreferences)
  // ═══════════════════════════════════════════════════════════════

  // Auth
  static const String userProfile = 'user_profile';
  static const String isLogin = 'is_login';

  // App Settings
  static const String isFirstRun = 'is_first_run';
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';

  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String hasRatedApp = 'has_rated_app';

  static const String keyThemeColor = 'theme_color';
  static const String keyThemeMode = 'theme_mode';

  // Ads
  static const String adFrequencyData = 'ad_frequency_data';
  static const String adSessionStart = 'ad_session_start';
}
