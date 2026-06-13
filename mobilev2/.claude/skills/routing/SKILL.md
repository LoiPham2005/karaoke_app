---
name: routing
description: auto_route typed routes + guards + deep linking. Đọc khi thêm route mới, navigate giữa pages, setup AutoTabsRouter (bottom nav), hoặc auth guard redirect.
---

# Routing — auto_route

## 🗺️ Architecture

```
lib/routes/
├── base/
│   └── not_found_page.dart            # 404 page
└── config/
    ├── app_router.dart                # @LazySingleton + @AutoRouterConfig — khai báo routes
    ├── app_router.gr.dart             # 🤖 Auto-gen (build_runner) — KHÔNG sửa tay
    ├── route_paths.dart               # String constants (tham khảo)
    └── route_guards.dart              # AuthGuard extends AutoRouteGuard
```

## 🎯 Setup chính

### app_router.dart

```dart
@LazySingleton()
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: NoConnectionRoute.page, path: '/no-connection'),
    AutoRoute(
      page: MainRoute.page,
      path: '/',
      guards: [AuthGuard()],
      children: [
        AutoRoute(page: HomeRoute.page, path: ''),
        AutoRoute(page: VoucherListRoute.page, path: 'vouchers'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
    AutoRoute(page: CharacterListRoute.page, path: '/characters', guards: [AuthGuard()]),
    AutoRoute(page: CharacterDetailRoute.page, path: '/characters/:id', guards: [AuthGuard()]),
  ];
}
```

### Page annotation

Mỗi page **bắt buộc** có `@RoutePage()`:

```dart
@RoutePage()
class HomePage extends StatelessWidget { ... }

// Page có params — auto_route tự đọc constructor
@RoutePage()
class CharacterDetailPage extends ConsumerWidget {
  const CharacterDetailPage({required this.id, super.key});
  final String id;
  ...
}
```

### main_page.dart — AutoTabsRouter (bottom nav shell)

```dart
@RoutePage()
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [HomeRoute(), VoucherListRoute(), SettingsRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            items: [...],
          ),
        );
      },
    );
  }
}
```

### app.dart — wire vào MaterialApp

```dart
final router = getIt<AppRouter>();
MaterialApp.router(
  routerConfig: router.config(
    navigatorObservers: () => [AutoRouteObserver()],
  ),
)
```

Auth listener để navigate khi logout:
```dart
ref.listen<AppAuthState>(appAuthProvider, (previous, next) {
  if (previous?.isAuthenticated == true && !next.isAuthenticated) {
    _router.replaceAll([const LoginRoute()]);
  }
});
```

## ➕ Thêm route mới

### 1. Thêm `@RoutePage()` vào page

```dart
@RoutePage()
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.id, super.key});
  final String id;
  ...
}
```

### 2. ⚠️ **IMPORT page vào `app_router.dart`** (dễ quên — gây lỗi build)

`app_router.gr.dart` là `part of 'app_router.dart'` → mọi class refer trong file generated phải resolve được từ **imports của file chính**.

```dart
// app_router.dart
import 'package:flutter_base2/features/products/presentation/pages/product_detail_page.dart';
//                                                                          ↑ MUST add this
```

**Bỏ qua bước này → compile error**:
```
Error: Couldn't find constructor 'ProductDetailPage'.
  return ProductDetailPage(...);
         ^^^^^^^^^^^^^^^^^
```

### 3. Khai báo trong `app_router.dart`

```dart
// Top-level (full screen, không có bottom nav)
AutoRoute(page: ProductDetailRoute.page, path: '/products/:id'),

// Trong shell (bottom nav visible — thêm vào children của MainRoute)
AutoRoute(page: MainRoute.page, children: [
  ...
  AutoRoute(page: ProductListRoute.page, path: 'products'),
]),
```

### 4. Generate

```bash
make gen
```

→ Sinh class `ProductDetailRoute` mixin `$ProductDetailRoute` trong `app_router.gr.dart`.

### 5. Navigate

```dart
// Push
context.router.push(ProductDetailRoute(id: '123'));

// Replace current
context.router.replace(const LoginRoute());

// Clear stack + navigate
context.router.replaceAll([const MainRoute()]);

// Pop
context.router.pop();

// Navigate từ service (không có context)
getIt<AppRouter>().push(const CharacterListRoute());
```

## 🛡️ AuthGuard

```dart
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final auth = globalContainer.read(appAuthProvider);
    if (auth.isAuthenticated) {
      resolver.next();
    } else {
      router.replaceAll([const LoginRoute()]);
    }
  }
}
```

## 🍃 Pattern phổ biến

### Pass data qua route

```dart
// Path param (:id) — tự map với constructor param tên `id`
AutoRoute(page: CharacterDetailRoute.page, path: '/characters/:id'),

// Query param — constructor param optional
@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({this.q, super.key});
  final String? q;  // /search?q=foo
}
```

### appContext (navigation không có BuildContext)

```dart
// Dùng navigatorKey từ AppRouter
BuildContext get appContext => getIt<AppRouter>().navigatorKey.currentContext!;

// Navigate từ service:
getIt<AppRouter>().push(const LoginRoute());
```

## 📂 Files quan trọng

| File | Vai trò |
|---|---|
| `lib/routes/config/app_router.dart` | `@AutoRouterConfig` — khai báo routes |
| `lib/routes/config/app_router.gr.dart` | 🤖 Generated — chứa `HomeRoute`, `LoginRoute`… |
| `lib/routes/config/route_guards.dart` | `AuthGuard extends AutoRouteGuard` |

## ❌ Anti-patterns

```dart
// ❌ Quên @RoutePage()
class HomePage extends StatelessWidget { ... }

// ✅
@RoutePage()
class HomePage extends StatelessWidget { ... }

// ❌ Dùng Navigator.push thay auto_route
Navigator.push(context, MaterialPageRoute(builder: (_) => ProductPage()));

// ✅
context.router.push(const ProductRoute());

// ❌ Hardcode string path
context.router.navigateNamed('/products/123');

// ✅ Typed
context.router.push(ProductDetailRoute(id: '123'));
```
