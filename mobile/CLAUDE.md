# Flutter Base — Project Instructions

## Language
Reply in **Vietnamese**. Keep code, class names, file names, and technical terms in English.

## Architecture
```
lib/
  config/           — Flavor, env config
  core/
    base/
      di/           — injectable + get_it (DI)
      errors/       — Result<T>, Failure subtypes, ErrorHandler
      state/
        bloc/       — BaseState, BaseCubit (legacy, không dùng cho feature mới)
        riverpod/   — BaseNotifier mixin (PRIMARY — dùng cho tất cả feature mới)
    data/network/   — ApiResponse<T>, ApiPaginatedData<T>, DioClient
    common/         — extensions, constants, utils
  features/{name}/
    data/
      models/       — @freezed + json_serializable
      services/     — @RestApi (Retrofit)
      <!-- repositories/ — optional, chỉ khi cần Domain layer -->
    presentation/
      providers/    — @riverpod class extends + with BaseNotifier<T>
      pages/        — HookConsumerWidget
  routes/
    base/           — observer, refresh stream, annotation, not_found_page
    config/         — app_router, app_routes, route_names, route_guards
```

## State Management — Riverpod + codegen (PRIMARY)

### Notifier pattern
```dart
// Mẫu chuẩn — xem lib/features/example/voucher/presentation/providers/voucher_pure_notifier.dart
@riverpod
class NameNotifier extends _$NameNotifier with BaseNotifier<List<NameModel>> {
  late NameService _service;

  @override
  Future<List<NameModel>> build() async {
    _service = NameService(ref.read(dioProvider));
    return _service.getList();
  }

  Future<void> refresh() => runAsync(
    action: _service.getList,
    keepPreviousOnLoading: true,
    cancelPrevious: true,
  );

  Future<void> search(String query) => runAsync(
    action: () => _service.search(query),
    cancelPrevious: true,
    keepPreviousOnLoading: true,
  );
}
```

### runAsync method selection
| Service trả về | Method | Ghi chú |
|---|---|---|
| `Future<T>` (raw) | `runAsync` | phổ biến nhất — service trả thẳng data |
| `Future<ApiResponse<R>>` | `runUnwrap` | unwrap + mapper |
| `Future<ApiResponse<ApiPaginatedData<R>>>` | `runPagination` | phân trang |
| `Future<Result<R>>` | `runResult` | repository trả Result |

### runAsync flags
| Flag | Tác dụng |
|---|---|
| `cancelPrevious: true` | Hủy call cũ — bắt buộc với search/filter |
| `keepPreviousOnLoading: true` | Giữ data cũ khi refresh (không flash trắng) |
| `emitEmptyForEmptyList: true` | `notifier.isEmpty = true` khi list rỗng |
| `successMessage: '...'` | Toast tự động qua `useAsyncValueListener` |
| `errorMessage: '...'` | Prefix cho toast lỗi |
| `onError: (e, s) => ...` | Rollback optimistic update |

### Page pattern
```dart
// Mẫu chuẩn — xem lib/features/example/voucher/presentation/pages/voucher_pure_page.dart
class NamePage extends HookConsumerWidget {
  const NamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nameProvider);
    final notifier = ref.read(nameProvider.notifier);

    useAsyncValueListener(provider: nameProvider, ref: ref);

    return Scaffold(
      body: switch (state) {
        AsyncValue(:final value?, isLoading: true) => Stack(        // refresh overlay
          children: [_buildContent(value), const LinearProgressIndicator()],
        ),
        AsyncData(value: final list) when list.isEmpty =>           // empty
          const EmptyWidget(),
        AsyncData(:final value) => _buildContent(value),           // success
        AsyncError(:final error) => ErrorWidget(                   // error
          onRetry: notifier.refresh,
        ),
        _ => const LoadingWidget(),                                 // initial load
      },
    );
  }
}
```

## Service return type
```dart
// ĐÚNG — interceptor xử lý exception → Failure tự động
Future<List<T>>                             // raw, dùng với runAsync
Future<ApiResponse<T>>                      // dùng với runUnwrap
Future<ApiResponse<ApiPaginatedData<T>>>    // dùng với runPagination
Future<void>                                // DELETE, side-effect

// SAI — không bao giờ wrap Result ở service layer
Future<Result<ApiResponse<T>>>
```

## DI annotations
- **Notifier**: không cần annotation — Riverpod codegen tự quản lý lifecycle
- `@LazySingleton()` → Service, Repository, stateful singletons
- `@Singleton()` → eager init at boot

## After any code-gen change
Run task: **⚡ Build Runner: Build**

## Skills
- `.claude/skills/commands/` — Makefile targets + VSCode Tasks + Dart tools
- `.claude/skills/app-config/` — FlavorConfig, AppInitializer, AppStartup, Observers, SystemUI
- `.claude/skills/new-feature/` — scaffold feature mới (Riverpod pattern)
- `.claude/skills/new-notifier/` — viết Notifier từ đầu
- `.claude/skills/new-route/` — thêm typed go_router route
- `.claude/skills/code-review/` — review checklist
- `.claude/skills/core-architecture/` — Extensions, Utils, Mixins, Network, Cache, Services
- `.claude/skills/design-system/` — AppColors, AppDimensions, AppTextStyles, AppTheme
- `.claude/skills/shared/` — Shared widgets, Base models, CommonParam
- `.claude/skills/modules/` — AdManager, AnalyticsService, IapService (RevenueCat)
- `.claude/skills/app-entry/` — app.dart, main_common, entry points, error zones, AppRouter
- `.claude/skills/api-conventions/` — Request/Response class, không dùng Map<String, dynamic>
