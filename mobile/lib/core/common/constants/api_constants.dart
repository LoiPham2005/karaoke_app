class ApiConstants {
  ApiConstants._();

  // ── Domains (private — chỉ dùng nội bộ file này) ──────────────
  static const String _domainDev = 'http://192.168.2.6:3000';
  static const String _domainStg = 'http://192.168.2.7:3000';
  static const String _domainProd = 'https://api.example.com';

  // ── Base REST URLs ────────────────────────────────────────────
  static const String baseUrlDev = '$_domainDev/api/v1';
  static const String baseUrlStg = '$_domainStg/api/v1';
  static const String baseUrlProd = '$_domainProd/api/v1';

  // ── WebSocket URLs ────────────────────────────────────────────
  static const String wsUrlDev = 'ws://192.168.2.4:3000/ws';
  static const String wsUrlStg = 'ws://192.168.2.7:3000/ws';
  static const String wsUrlProd = 'wss://api.example.com/ws';

  // ── Timeouts (dùng chung 3 môi trường) ───────────────────────
  static const Duration connectTimeoutDev = Duration(seconds: 30);
  static const Duration connectTimeoutStg = Duration(seconds: 30);
  static const Duration connectTimeoutProd = Duration(seconds: 30);

  static const Duration receiveTimeoutDev = Duration(seconds: 30);
  static const Duration receiveTimeoutStg = Duration(seconds: 30);
  static const Duration receiveTimeoutProd = Duration(seconds: 30);

  // ── Google Maps API Keys ──────────────────────────────────────
  static const String googleMapsKeyDev = 'android_key_dev';
  static const String googleMapsKeyStg = 'android_key_stg';
  static const String googleMapsKeyProd = 'android_key_prod';

  // ── Stripe Public Keys ────────────────────────────────────────
  static const String stripeKeyDev = 'pk_test_dev';
  static const String stripeKeyStg = 'pk_test_stg';
  static const String stripeKeyProd = 'pk_live_prod'; 

  // ── Feature Flags ───────────────────────────────────────────
  static const bool enableLoggingDev = true;
  static const bool enableLoggingStg = true;
  static const bool enableLoggingProd = false;

  static const bool enableDebugToolsDev = true;
  static const bool enableDebugToolsStg = true;
  static const bool enableDebugToolsProd = false;

  static const bool enableAnalyticsDev = false;
  static const bool enableAnalyticsStg = true;
  static const bool enableAnalyticsProd = true;
}
