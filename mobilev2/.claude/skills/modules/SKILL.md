---
name: modules
description: Feature modules trong lib/modules/ — Ads (AdMob), IAP (RevenueCat), Analytics (Firebase), AppConfig (Remote Config). Đọc khi cần show quảng cáo, track event, mua premium, đọc maintenance mode hoặc notice banner.
---

# Modules — Ads / IAP / Analytics / AppConfig

## 📋 Tổng quan

| Module | Path | Plugin | Tự init? |
|---|---|---|---|
| `AdManager` | `modules/ads/` | google_mobile_ads | ✅ Qua AppInitializer |
| `IapService` | `modules/iap/` | purchases_flutter | ✅ Qua AppInitializer |
| `AnalyticsService` | `modules/analytics/` | firebase_analytics | Manual |
| `AppConfigService` | `modules/app_config/` | firebase_remote_config | ✅ Qua AppInitializer |

## 📢 AdsModule (AdManager) — Production-ready 100%

**Path**: `lib/modules/ads/`

### Structure (19 files)
```
ads/
├── models/
│   ├── ad_config.dart          # @freezed AdConfig + AdRules + AdUnits + AdUnit
│   └── ad_placements.dart      # PlacementKey interface + enums + RawPlacement
├── utils/
│   ├── ad_defaults.dart        # Test IDs + kUseRemoteConfig flag (flavor-aware)
│   ├── ad_sizes.dart           # Adaptive banner sizes
│   └── ad_retry_policy.dart    # ⭐ Exponential backoff + jitter
├── services/
│   ├── ad_cache_service.dart   # Cache ads + TTL 1h + safe-dispose + hit/miss stats
│   ├── ad_config_service.dart  # Firebase Remote Config (key `ad_config`)
│   ├── ad_consent_service.dart # ⭐ UMP (GDPR/CCPA) + ATT iOS
│   ├── ad_stats_service.dart   # Firebase Analytics + in-memory debug stats
│   ├── ad_manager.dart         # ⭐ Facade chính
│   └── handlers/
│       ├── full_screen_ad_handler.dart  # Base class + retry + network guard
│       ├── inter_handler.dart
│       ├── app_open_handler.dart
│       └── rewarded_handler.dart        # Expando ad↔placement (race-free)
├── observers/
│   └── ad_lifecycle_observer.dart  # AppLifecycle → AppOpen resume (debounced)
└── widgets/
    ├── ad_banner_widget.dart       # Adaptive + rotation race-safe
    ├── native_ad_widget.dart       # 3 sizes: small / medium / full
    └── native_ad_full_screen.dart  # Overlay full-screen (theme-aware)
```

### Boot order (AppInitializer)
```
1. AdConfigService.initialize()   ← fetch Remote Config
2. AdConsentService.ensureConsent()  ← ATT (iOS) + UMP — TRƯỚC MobileAds.init
3. AdManager.initialize()          ← RequestConfiguration + MobileAds + preload + network listener
4. AdLifecycleObserver.init()      ← addObserver (last)
```

### Data Model (`ad_config.dart`)

```dart
AdConfig                       // top-level: flags + frequency + ad units
  ├── flags: showAllAds, enableInter/AppOpen/Rewarded/Native/Banner, ...
  ├── AdRules rules            // frequency cap rules
  └── AdUnits adUnits          // ← tên match AdMob Console "Ad units" menu

AdUnits                        // Map<String, AdUnit> per type
  ├── inter:    Map<String, AdUnit>  // {'splash': AdUnit, 'after_quiz': AdUnit}
  ├── appOpen:  Map<String, AdUnit>
  ├── rewarded: Map<String, AdUnit>
  ├── native:   Map<String, AdUnit>
  └── banner:   Map<String, AdUnit>

AdUnit                         // 1 ad unit
  ├── id:      String           // primary AdMob unit ID
  ├── id2:     String           // alternate ID (A/B test / fallback)
  ├── useId2:  bool?            // null=follow global, true=luôn id2, false=luôn id
  └── enable:  bool             // soft-off without removing
```

### Lookup pattern

```dart
// Truy cập trực tiếp qua field `adUnits` + key String:
final unit = cfg.adUnits.inter['splash'];           // ← Map lookup runtime
final unit = cfg.adUnits.inter[InterstitialPlacement.splash.key];  // ← via enum

// Hoặc extension `byPlacement` (ad_placements.dart):
final unit = cfg.adUnits.inter.byPlacement(InterstitialPlacement.splash);
final unit = cfg.adUnits.inter.byPlacement(const RawPlacement('experimental_v2'));
```

**Thêm placement mới = chỉ thêm key vào Firebase Remote Config JSON**, không cần sửa Dart code (trừ khi muốn add enum để type-safe API).

### Public API

```dart
final ads = adManager; // top-level getter = getIt<AdManager>()

// Interstitial
await ads.showInter(InterstitialPlacement.afterAction, onDismissed: () { ... });

// App Open trên RESUME (auto qua observer, không cần gọi)
// App Open trên COLD START — GỌI TỪ SPLASH PAGE:
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    adManager.showAppOpenOnLaunch();  // idempotent — chỉ fire 1 lần/session
  });
}

// Rewarded
await ads.showRewarded(
  RewardedPlacement.bonus,
  onEarnedReward: (reward) => print('+${reward.amount} ${reward.type}'),
);

// Native overlay full-screen (qua showDialog, dùng ad đã preload — instant)
ads.showNativeFull(onClosed: () { /* tiếp tục flow */ });

// Native widget in-feed (lazy load, 3 size)
const NativeAdWidget(placement: NativePlacement.home)                        // medium mặc định
const NativeAdWidget(placement: NativePlacement.home, size: NativeAdSize.small)
const NativeAdWidget(placement: NativePlacement.home, size: NativeAdSize.full)
const NativeAdWidget(placement: NativePlacement.home, height: 200)          // override height

// Banner widget (adaptive, tự reload khi rotate)
const AdBannerWidget(placement: BannerPlacement.home)

// Reset session (sau IAP refund / re-login / unsubscribe)
ads.resetSession();  // reset frequency cap + observer + cold start sentinel

// Consent — sau khi user mở Privacy options form
await getIt<AdConsentService>().showPrivacyOptionsForm();
ads.onConsentChanged();  // re-preload nếu user grant lại
```

### Placements (`ad_placements.dart`)

```dart
enum InterstitialPlacement { splash('splash'), afterQuiz('after_quiz') }
enum AppOpenPlacement { splash('splash'), resume('resume') }
enum RewardedPlacement { bonus('bonus') }
enum NativePlacement { afterInter('after_inter'), nativeFull('native_full'),
                       language('language'), intro1('intro_1'), home('home') }
enum BannerPlacement { home('home') }

// A/B test dynamic placement (không cần thêm enum value)
adManager.showInter(const RawPlacement('experimental_v2'));
```

### Frequency cap (per-TYPE, không per-placement)

`AdRules` config (Firebase Remote Config):
```dart
@Default(30) int interInterval,         // tất cả Inter share cooldown 30s
@Default(30) int appOpenInterval,
@Default(30) int rewardedInterval,
@Default(30) int nativeFullInterval,
@Default(3) int maxInterPerSession,     // 3 Inter total, không phải 3/placement
@Default(5) int maxRewardedPerSession,
```

Cross-handler cooldown 10s (hard-coded): Inter/Rewarded vừa show → AppOpen blocked.

### Production-grade features (all working)

| Feature | Cách hoạt động |
|---------|----------------|
| **UMP Consent** | `ConsentInformation` API, chạy trước MobileAds.init, support Privacy Options form |
| **ATT iOS** | `app_tracking_transparency` package, request sau 200ms delay (Apple guideline) |
| **Retry exponential** | `AdRetryPolicy` 2s→4s→8s, max 3 retry, ±20% jitter |
| **Network auto re-preload** | Listen `NetworkInfo.onStatusChange` → online lại = `_preloadAll()` |
| **Offline guard** | Skip load nếu `!network.isConnected` |
| **Cold start AppOpen** | `showAppOpenOnLaunch()` idempotent sentinel |
| **Race protection** | `_showing` Set + `_loading` Completer + `_nativeLoading` Set + `Expando` cho Rewarded |
| **Memory safe** | Safe-dispose try/catch trong AdCacheService + dispose hooks |
| **Test device prod guard** | `_testDeviceIds` forced empty ở prod flavor |
| **RequestConfiguration** | Max rating T, COPPA/EEA flags, test device list |

### Native setup (3 factories registered)

**Android** (`MainActivity.kt`):
- `nativeSmall` → `res/layout/native_ad_small.xml`
- `nativeMedium` → `res/layout/native_ad_medium.xml`
- `nativeFull` → `res/layout/native_ad_full.xml` (MediaView fill space, CTA dồn đáy)

**iOS** (`AppDelegate.swift`):
- `nativeSmall` → `NativeAdSmallView.xib`
- `nativeMedium` → `NativeAdMediumView.xib`
- `nativeFull` → `NativeAdFullView.xib` ⚠️ **chưa tạo XIB** — phải tạo qua Xcode Interface Builder trước khi test iOS

**AdMob configs**:
- `AndroidManifest.xml` → `com.google.android.gms.ads.APPLICATION_ID` (đang test ID)
- `ios/Runner/Info.plist` → `GADApplicationIdentifier` + 15 `SKAdNetworkItems` + `NSUserTrackingUsageDescription`

### Demo page

`lib/features/ads_demo/presentation/pages/ads_demo_page.dart` — page demo mọi loại ads với button click per placement, SegmentedButton để switch native size, auto-filter theo `AdConfig` enable flags. Route: `AdsDemoRoute()`.

### ⚠️ Production checklist (5 bước)

1. **Đổi test ID → real ID**:
   - `android/app/src/main/AndroidManifest.xml` — `APPLICATION_ID`
   - `ios/Runner/Info.plist:75` — `GADApplicationIdentifier`
2. **Setup AdMob console**:
   - Tạo Ad Units real, lấy IDs
   - Cấu hình UMP form (Privacy & messaging → GDPR + CCPA + Privacy options)
3. **Firebase Remote Config**:
   - Key `ad_config` với JSON match `AdConfig.toJson()` schema (xem mẫu bên dưới)
   - Bắt đầu rules tight (interval 60s, max 3/session) → loose dần theo retention data

   **JSON schema mẫu** cho key `ad_config`:
   ```json
   {
     "show_all_ads": true,
     "use_remote_config": true,
     "enable_inter": true,
     "enable_app_open": true,
     "enable_rewarded": true,
     "enable_native": true,
     "enable_native_full": true,
     "enable_banner": true,
     "native_full_after_inter": true,
     "rules": {
       "inter_interval": 30,
       "app_open_interval": 30,
       "rewarded_interval": 30,
       "native_full_interval": 30,
       "max_inter_per_session": 3,
       "max_rewarded_per_session": 5
     },
     "ad_units": {
       "inter":    { "splash": {"id":"ca-app-pub-.../...", "enable":true},
                     "after_quiz": {"id":"ca-app-pub-.../...", "enable":true} },
       "app_open": { "splash": {"id":"...", "enable":true},
                     "resume": {"id":"...", "enable":true} },
       "rewarded": { "bonus": {"id":"...", "enable":true} },
       "native":   { "after_inter": {"id":"...", "enable":true},
                     "native_full": {"id":"...", "enable":true},
                     "language":    {"id":"...", "enable":true},
                     "intro_1":     {"id":"...", "enable":true},
                     "home":        {"id":"...", "enable":true} },
       "banner":   { "home": {"id":"...", "enable":true} }
     }
   }
   ```

   → Field `adUnits` (Dart) ↔ key `ad_units` (JSON) via `FieldRename.snake`. Thêm placement mới = chỉ thêm key vào JSON này.
4. **Splash page** thêm `showAppOpenOnLaunch()` trong `postFrameCallback`
5. **Test devices**: lấy hash từ logcat sau lần load đầu, thêm vào `AdManager._testDeviceIds` (auto rỗng ở prod)

### Trace nhanh khi debug

| Vấn đề | Check |
|--------|-------|
| Ad không show | Check `_showing` Set, frequency cap, cross-handler cooldown, network |
| iOS CPM thấp | Verify ATT prompt hiện ra (real device, không simulator) |
| EU user không thấy ad | Check UMP — `_consentService.canRequestAds`, có thể consent required + not obtained |
| Native bị clip CTA | Bump `NativeAdSize.defaultHeight` hoặc dùng `height` param override |
| Banner sai size sau rotate | Check `_desiredWidth` vs `_loadedWidth` mismatch |
| Rewarded callback null | Check `Expando[ad]` có set ở `onAdLoadedHook` không |

## 💳 IapService — RevenueCat

**Path**: `lib/modules/iap/`

### DI env-aware

```dart
@LazySingleton(env: ['prod', 'stg'])
class IapService { ... }  // Real RevenueCat

@LazySingleton(as: IapService, env: ['dev'])
class MockIapService implements IapService { ... }  // Mock cho dev
```

→ Inject 1 chỗ, flavor quyết định instance.

### Setup
```dart
// AppInitializer tự gọi:
await getIt<IapService>().initialize();
// hoặc với user ID:
await getIt<IapService>().initialize(userId: 'user_123');
```

### Premium status

```dart
final iap = getIt<IapService>();

iap.isPremium;                                    // bool snapshot
iap.premiumStream.listen((p) => print('Premium: $p'));  // reactive
```

### Purchase + Restore

```dart
final result = await iap.purchasePackage(package);

switch (result.errorType) {
  case null:                                return 'Mua thành công';
  case PurchaseErrorType.cancelled:         return null;
  case PurchaseErrorType.network:           return 'Kiểm tra mạng';
  case PurchaseErrorType.storeUnavailable:  return 'Store tạm sự cố';
  case PurchaseErrorType.notAllowed:        return 'Thiết bị không cho phép';
  default: return result.message;
}

// Restore
final result = await iap.restorePurchases();
if (result.isSuccess) { /* re-grant premium */ }
```

### Mock test (dev flavor)

```dart
final mock = getIt<IapService>() as MockIapService;

// Simulate cancel
mock.setNextResult(AppPurchaseResult.cancelled());
await iap.purchasePackage(pkg); // → cancelled

// Simulate network error
mock.setNextResult(AppPurchaseResult.error(
  'No internet',
  type: PurchaseErrorType.network,
));

// Mock packages cho UI dev
mock.mockPackages; // List<MockPremiumPackage>
```

### Production keys

```dart
// lib/core/common/constants/app_constants.dart
revenueCatGoogleKey = 'goog_xxx';       // thay placeholder
revenueCatAppleKey = 'appl_xxx';
premiumEntitlement = 'premium';          // match RevenueCat dashboard
```

## 📊 AnalyticsService

**Path**: `lib/modules/analytics/analytics_service.dart`

```dart
final analytics = getIt<AnalyticsService>();

// Custom event
await analytics.logEvent(
  name: 'tutorial_complete',
  parameters: {'step': 5},
);

// Helpers
await analytics.logButtonClick(buttonName: 'cta_buy_premium');
await analytics.logScreenView('home');
await analytics.setUserId('user_123');

// Ad revenue (Firebase Ad Revenue spec)
await analytics.logAdRevenuePaid(
  value: 0.50,
  currency: 'USD',
  adPlatform: 'AdMob',
  adSource: 'AdMob',
  adUnitName: 'inter_home',
  adFormat: 'inter',
);

// FirebaseAnalyticsObserver cho GoRouter (track screen views auto)
final observer = analytics.observer;
```

→ Auto check `FlavorConfig.current.enableAnalytics` — disable ở dev.

## ⚙️ AppConfigService

**Path**: `lib/modules/app_config/`

### Firebase Remote Config schema (1 key duy nhất)

**Key**: `app_config` (String, JSON)
```json
{
  "maintenance_mode": false,
  "maintenance_message": "Bảo trì 2h-4h sáng",
  "notice_enabled": true,
  "notice_title": "🎉 Khuyến mãi cuối tuần",
  "notice_body": "Giảm 50%",
  "notice_url": "https://example.com/promo",
  "policy_url": "https://example.com/privacy",
  "terms_url": "https://example.com/terms"
}
```

### Toggle local mode

**Path**: `lib/modules/app_config/utils/app_config_defaults.dart`
```dart
const bool kUseAppRemoteConfig = true;  // false → dùng kAppConfigDev (no Firebase)
```

### Use — generic

```dart
final cfg = getIt<AppConfigService>();

if (cfg.isMaintenance) {
  return MaintenanceScreen(message: cfg.maintenanceMessage);
}

if (cfg.hasNotice) {
  showNoticeBanner(
    title: cfg.noticeTitle,
    body: cfg.noticeBody,
    onTap: cfg.hasNoticeAction ? () => launchUrl(cfg.noticeUrl) : null,
  );
}

// Custom feature flag
final showNewUi = cfg.getBool('show_new_checkout_ui');
final maxItems = cfg.getInt('max_cart_items');
```

### Use — reactive với Riverpod

```dart
class HomePage extends HookConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(appConfigSnapshotProvider).valueOrNull
        ?? AppConfigSnapshot.empty;

    if (cfg.isMaintenance) return MaintenanceScreen(...);
    // ...
  }
}
```

### Pull to refresh

```dart
RefreshIndicator(
  onRefresh: () => getIt<AppConfigService>().refresh(),
  child: ...,
)
```

## 📂 Files quan trọng

| File | Vai trò |
|---|---|
| `lib/modules/ads/services/ad_manager.dart` | ⭐ AdManager facade — entry point chính |
| `lib/modules/ads/services/ad_consent_service.dart` | UMP (GDPR/CCPA) + ATT iOS |
| `lib/modules/ads/services/ad_config_service.dart` | Remote Config loader |
| `lib/modules/ads/services/ad_stats_service.dart` | Analytics + debug stats |
| `lib/modules/ads/services/handlers/full_screen_ad_handler.dart` | Base class — retry + network + frequency cap |
| `lib/modules/ads/services/handlers/rewarded_handler.dart` | Expando ad↔placement (race-free) |
| `lib/modules/ads/observers/ad_lifecycle_observer.dart` | AppLifecycle → AppOpen resume (debounced) |
| `lib/modules/ads/utils/ad_retry_policy.dart` | Exponential backoff + jitter |
| `lib/modules/ads/utils/ad_defaults.dart` | Test IDs + flavor-aware kUseRemoteConfig |
| `lib/modules/ads/models/ad_config.dart` | @freezed AdConfig + AdRules + **AdUnits** + AdUnit |
| `lib/modules/ads/models/ad_placements.dart` | PlacementKey interface + 5 enums + `RawPlacement` + `byPlacement` extension |
| `lib/modules/ads/widgets/*.dart` | Banner / Native (3 sizes) / NativeFull overlay |
| `lib/features/ads_demo/presentation/pages/ads_demo_page.dart` | Demo page — auto filter theo config |
| `lib/modules/iap/iap_service.dart` | Real RevenueCat |
| `lib/modules/iap/iap_service_mock.dart` | Mock cho dev |
| `lib/modules/iap/models/iap_models.dart` | AppPurchaseResult + PurchaseErrorType |
| `lib/modules/analytics/analytics_service.dart` | Firebase Analytics wrapper |
| `lib/modules/app_config/services/app_config_service.dart` | RemoteConfig wrapper |
| `lib/modules/app_config/models/app_config_snapshot.dart` | Freezed snapshot |
| `lib/modules/app_config/providers/app_config_provider.dart` | Riverpod stream provider |
| `lib/modules/app_config/utils/app_config_defaults.dart` | Toggle + fallback |

## ❌ Anti-patterns

```dart
// ❌ Không check premium trước khi show ads
adManager.showInter(InterstitialPlacement.splash);

// ✅ Skip ads nếu user premium
if (!getIt<IapService>().isPremium) {
  await adManager.showInter(InterstitialPlacement.splash);
}

// ❌ Hard-code maintenance message
const message = 'App đang bảo trì';

// ✅ Đọc từ AppConfigService
final cfg = getIt<AppConfigService>();
final message = cfg.maintenanceMessage;

// ❌ Tạo Firebase Analytics instance mới
FirebaseAnalytics.instance.logEvent(...)

// ✅ Dùng AnalyticsService (tự skip nếu dev)
getIt<AnalyticsService>().logEvent(name: ...)

// ❌ Gọi MobileAds.instance.initialize trực tiếp
await MobileAds.instance.initialize();  // bỏ qua consent → vi phạm GDPR

// ✅ Dùng AdManager.initialize() — tự gọi consent trước, RequestConfiguration đúng
await getIt<AdManager>().initialize();

// ❌ Show AppOpen splash từ AppLifecycleObserver (chỉ fire trên resume, không cold start)
// → Đời nào AppOpen splash không show ra

// ✅ Gọi từ Splash page sau frame đầu
WidgetsBinding.instance.addPostFrameCallback((_) {
  adManager.showAppOpenOnLaunch();
});

// ❌ Tạo NativeAd thủ công với factoryId chưa register
NativeAd(factoryId: 'customFactory', ...)  // crash: NativeAdError

// ✅ Dùng NativeAdWidget — chỉ có 3 factory đã register (small/medium/full)
const NativeAdWidget(placement: NativePlacement.home, size: NativeAdSize.small)

// ❌ Bypass cooldown để show ad ngay khi user vừa thấy ad khác
// (không có API — base class chặn qua _showing + cross-handler cooldown)

// ✅ Trust frequency cap — Remote Config tunable, không hardcode override
```
