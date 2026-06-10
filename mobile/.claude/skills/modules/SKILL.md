---
name: modules
description: Feature modules — Ads (AdManager/AdConfig), Analytics (AnalyticsService), IAP (IapService/RevenueCat). Dùng khi làm việc với quảng cáo, theo dõi sự kiện, mua hàng trong app.
when_to_use: Trigger khi user hỏi về hiển thị quảng cáo, track event, mua premium, RevenueCat, AdMob, Firebase Analytics, IAP, in-app purchase.
user-invocable: false
allowed-tools: Read Glob Grep
---

# Feature Modules — `lib/modules/`

```
lib/modules/
  ads/
    ad_manager.dart         — AdManager singleton (showInter/AppOpen/Rewarded)
    ad_config_service.dart  — Load AdConfig từ remote config
    ad_cache_service.dart   — Cache preloaded ads
    ad_tracker_service.dart — Track impression/click/revenue
    models/ad_config.dart   — @freezed AdConfig model
  analytics/
    analytics_service.dart  — AnalyticsService (Firebase Analytics wrapper)
  iap/
    iap_service.dart        — IapService (RevenueCat wrapper)
    models/
```

---

## Ads Module

### AdConfig (`models/ad_config.dart`)

```dart
@freezed
class AdConfig {
  // Ad unit IDs
  AdUnits units;            // inter, appOpen, rewarded, nativeFull

  // Feature flags
  bool enableAppOpen;
  bool showAllAds;
  bool nativeFullAfterInter;

  // Frequency capping
  int maxInterPerSession;
  Duration interInterval;
  Duration appOpenInterval;
}

class AdUnits {
  String inter;
  String appOpen;
  String rewarded;
  String nativeFull;
}
```

> Config được load từ Firebase Remote Config qua `AdConfigService.initialize()` (Phase 3 startup).

### AdManager

```dart
// Gọi sau AppInitializer Phase 3 (đã được init sẵn)
final adManager = getIt<AdManager>();

// Interstitial Ad
final shown = await adManager.showInter(
  onDismissed: () => doNextAction(),
  timeout: Duration(seconds: 3),
);

// App Open Ad
await adManager.showAppOpen(onDismissed: () => ...);

// Rewarded Ad
await adManager.showRewarded(
  onEarnedReward: (reward) => grantPremiumContent(),
  timeout: Duration(seconds: 5),
);
```

**Frequency capping tự động:**
- `maxInterPerSession`: giới hạn interstitial / phiên
- `interInterval`: khoảng cách tối thiểu giữa 2 inter
- `appOpenInterval`: khoảng cách tối thiểu giữa 2 app open

**Native Full after Inter:**
- Nếu `nativeFullAfterInter = true` → tự động show native full screen sau interstitial

### AdLifecycleObserver

Được init trong AppInitializer Phase 3. Tự động show App Open Ad khi app resume.

---

## Analytics Module

### AnalyticsService (`analytics_service.dart`)

```dart
final analytics = getIt<AnalyticsService>();

// --- Screen tracking ---
analytics.logScreenView('HomeScreen');
// Tự động qua NavigationObserver nếu dùng AppRouter

// --- User identity ---
analytics.setUserId(userId);
analytics.setUserProperty('plan', 'premium');
analytics.setUserDemographics(age: 25, gender: 'male', country: 'VN');

// --- Custom events ---
analytics.logEvent('custom_event', parameters: {'key': 'value'});

// --- Business events ---
analytics.logPurchase(
  transactionId: 'txn_123',
  value: 99000,
  currency: 'VND',
  itemName: 'Premium Plan',
);

analytics.logInAppPurchase(
  productId: 'premium_monthly',
  productName: 'Premium Monthly',
  price: 4.99,
  currency: 'USD',
);

analytics.logAdRevenuePaid(
  value: 0.001,
  currency: 'USD',
  adPlatform: 'AdMob',
  adSource: 'Google',
  adUnitName: 'inter_main',
  adFormat: 'Interstitial',
);

// --- UX events ---
analytics.logButtonClick('subscribe_button', screenName: 'HomeScreen');
analytics.logFeatureUsage('dark_mode');
analytics.logSearch('flutter tutorial', category: 'tutorials');
analytics.logShare('article', itemId: 'article_123', method: 'link');

// --- Error tracking ---
analytics.logError('payment_failed', errorMessage: e.toString());

// --- Lifecycle ---
analytics.logAppOpen();
analytics.logAppBackground();
analytics.logAppResume();
```

**Firebase limits (tự động xử lý):**
- Tên event: ≤40 ký tự, alphanumeric + underscore, bắt đầu bằng chữ
- Tên param: ≤40 ký tự
- Giá trị param: ≤100 ký tự
- Tối đa 25 params/event

**Navigation observer:**
```dart
// Đã tích hợp sẵn trong AppRouter
// Mỗi lần navigate → tự log screen view
```

**Enable/Disable:**
```dart
analytics.setAnalyticsCollectionEnabled(false); // e.g. user opt-out
analytics.resetAnalyticsData();
```

---

## IAP Module

### IapService (`iap_service.dart`) — RevenueCat

```dart
final iap = getIt<IapService>();

// Kiểm tra premium
iap.isPremium          // bool (sync)
iap.premiumStream      // Stream<bool> cho realtime

// Load offerings
await iap.fetchOfferings();
final offerings = iap.offerings;

// Mua
final result = await iap.purchasePackage(package);
result.when(
  success: (msg) => toast.success(msg ?? 'Mua thành công'),
  error: (msg) => toast.error(msg ?? 'Lỗi thanh toán'),
  cancelled: () => {},
);

// Restore
final result = await iap.restorePurchases();

// Gắn user ID (sau login)
await iap.loginUser(userId);
await iap.logoutUser(); // khi logout
```

**AppPurchaseResult:**
```dart
sealed class AppPurchaseResult {
  const factory AppPurchaseResult.success(String? message)
  const factory AppPurchaseResult.error(String? message)
  const factory AppPurchaseResult.cancelled()
}
```

**Premium entitlement key:** `AppConstants.premiumEntitlement`

**RevenueCat keys:**
```dart
AppConstants.revenueCatAppleKey    // iOS
AppConstants.revenueCatGoogleKey   // Android
```

**Initialize:** gọi tự động trong AppInitializer Phase 5 (non-blocking, lỗi không crash app).

---

## Quy tắc

- **Ads**: không gọi AdMob SDK trực tiếp — luôn qua `AdManager`
- **Analytics**: không gọi `FirebaseAnalytics` trực tiếp — luôn qua `AnalyticsService`
- **IAP**: không gọi `Purchases` (RevenueCat) trực tiếp — luôn qua `IapService`
- **Feature flags ads**: kiểm tra `AdConfig.showAllAds` trước khi show (AdManager tự xử lý)
- **Analytics enabled**: tự động bật theo `FlavorConfig.enableAnalytics` (dev: off, stg/prod: on)
