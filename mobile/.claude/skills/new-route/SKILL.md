---
name: new-route
description: Thêm typed go_router route vào project. Dùng khi user nói "thêm route", "đăng ký route", "navigate đến màn hình mới", hoặc sau khi tạo page mới cần route.
argument-hint: [RouteName] [/path]
allowed-tools: Read Write Edit Glob Grep
---

# Thêm Route Mới: $ARGUMENTS

## Bước 1 — Route name constant

`lib/routes/constants/route_names.dart`:
```dart
static const String $ARGUMENTS[0] = '/$ARGUMENTS[1]';
```

## Bước 2 — Typed route class

`lib/routes/config/app_routes.dart`:

```dart
// Route đơn giản
@TypedGoRoute<$ARGUMENTS[0]Route>(path: RouteNames.$ARGUMENTS[0])
class $ARGUMENTS[0]Route extends GoRouteData {
  const $ARGUMENTS[0]Route();
  @override Widget build(BuildContext context, GoRouterState state) =>
      const $ARGUMENTS[0]Screen();
}

// Route có ID param
@TypedGoRoute<$ARGUMENTS[0]Route>(path: '${RouteNames.$ARGUMENTS[0]}/:id')
class $ARGUMENTS[0]Route extends GoRouteData {
  const $ARGUMENTS[0]Route({required this.id});
  final int id;
  @override Widget build(BuildContext context, GoRouterState state) =>
      $ARGUMENTS[0]Screen(id: id);
}
```

## Bước 3 — Guard

`lib/routes/guards/route_guards.dart` — chỉ thêm nếu route **không** cần auth:
```dart
static const _publicRoutes = {
  RouteNames.$ARGUMENTS[0],
};
```

## Bước 4 — Build Runner

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

## Bước 5 — Navigate

```dart
// Typed (sau build runner)
const $ARGUMENTS[0]Route().go(context);      // replace current
const $ARGUMENTS[0]Route().push(context);    // push on stack

// Với params
const $ARGUMENTS[0]Route(id: 42).go(context);
```
