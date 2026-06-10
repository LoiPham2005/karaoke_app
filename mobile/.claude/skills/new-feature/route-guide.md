# Route Guide — Supporting Reference

## 1. Thêm constant

`lib/routes/config/route_names.dart`:
```dart
static const String orders = '/orders';
static const String orderDetail = '/orders/:id';
```

## 2. Khai báo typed route

`lib/routes/config/app_routes.dart`:
```dart
@TypedGoRoute<OrdersRoute>(path: RouteNames.orders)
class OrdersRoute extends GoRouteData with $OrdersRoute {
  const OrdersRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const OrdersPage();
}

// Với params
@TypedGoRoute<OrderDetailRoute>(path: RouteNames.orderDetail)
class OrderDetailRoute extends GoRouteData with $OrderDetailRoute {
  const OrderDetailRoute({required this.id});
  final String id;
  @override
  Widget build(BuildContext context, GoRouterState state) => OrderDetailPage(id: id);
}
```

## 3. Guard (nếu public)

`lib/routes/config/route_guards.dart`:
```dart
static const _publicRoutes = {
  RouteNames.orders, // ← thêm nếu không cần auth
};
```

## 4. Build Runner → navigate

```dart
const OrdersRoute().go(context);
const OrderDetailRoute(id: '42').push(context);
```
