---
name: api-conventions
description: Nguyên tắc tạo Request/Response class cho Retrofit service. Dùng khi viết service mới, thêm endpoint, hoặc review code có @Body() Map<String, dynamic>.
allowed-tools: Read Write Edit Bash
---

# Nguyên Tắc Request & Response

## Quy tắc cốt lõi

### ❌ KHÔNG BAO GIỜ làm thế này
```dart
// Sai — không type-safe, không refactor được
@POST('/auth/login')
Future<ApiResponse<AuthResponseModel>> login(@Body() Map<String, dynamic> body);

@GET('/products')
Future<ApiResponse<List<ProductModel>>> getProducts(@Queries() Map<String, dynamic> params);
```

### ✅ LUÔN làm thế này
```dart
// Đúng — typed Request class
@POST('/auth/login')
Future<ApiResponse<AuthResponseModel>> login(@Body() LoginRequest body);

@GET('/products')
Future<ApiResponse<ApiPaginatedData<ProductModel>>> getProducts(
  @Queries() ProductFilterRequest params,
);
```

---

## Cấu trúc file

```
features/{name}/data/models/
  {name}_model.dart      — Response models (UserModel, ProductModel, ...)
  {name}_request.dart    — Request classes (LoginRequest, CreateProductRequest, ...)
```

Request class để **riêng file** `{name}_request.dart`, không để chung với model.

---

## Cách viết Request class

### POST / PUT / PATCH body — dùng `@Body()`

```dart
// {name}_request.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name}_request.freezed.dart';
part '{name}_request.g.dart';

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
```

```dart
// service
@POST(ApiEndpoints.login)
Future<ApiResponse<AuthResponseModel>> login(@Body() LoginRequest body);
```

### GET filter / pagination — dùng `@Queries()`

```dart
@freezed
abstract class ProductFilterRequest with _$ProductFilterRequest {
  const factory ProductFilterRequest({
    @Default(1) int page,
    @Default(20) int limit,
    String? search,
    String? categoryId,
    @JsonKey(name: 'sort_by') String? sortBy,
  }) = _ProductFilterRequest;

  factory ProductFilterRequest.fromJson(Map<String, dynamic> json) =>
      _$ProductFilterRequestFromJson(json);
}
```

```dart
// service
@GET(ApiEndpoints.products)
Future<ApiResponse<ApiPaginatedData<ProductModel>>> getProducts(
  @Queries() ProductFilterRequest params,
);
```

### Single query param đơn giản — dùng `@Query()` thẳng (ngoại lệ duy nhất)

```dart
// OK khi chỉ có 1-2 param cố định, không mở rộng
@GET(ApiEndpoints.productDetail)
Future<ApiResponse<ProductModel>> getDetail(@Path('id') String id);
```

---

## Naming convention

| Loại | Suffix | Ví dụ |
|---|---|---|
| POST/PUT body | `Request` | `LoginRequest`, `CreateProductRequest` |
| GET filter/pagination | `FilterRequest` hoặc `Params` | `ProductFilterRequest` |
| Response data | `Model` | `UserModel`, `AuthResponseModel` |

---

## Snake_case mapping

Backend thường dùng `snake_case` — dùng `@JsonKey` để map:

```dart
@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'password_confirm') required String passwordConfirm,
    required String email,
    required String password,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
```

> Tip: Nếu **toàn bộ project** dùng snake_case, cấu hình `@JsonSerializable(fieldRename: FieldRename.snake)` một lần ở root thay vì `@JsonKey` từng field.

---

## Cubit nhận Request object

```dart
// Cubit — luôn nhận Request object, không dùng named params
Future<void> login(LoginRequest request) => runChain(
  chain: () async {
    final result = await _service.login(request).asResult();
    ...
  },
);

// Page tạo Request object rồi truyền vào
cubit.login(LoginRequest(email: email, password: password));
```

**Ngưỡng quyết định:**
- 1–3 field → có thể dùng named params
- 4+ field → **bắt buộc** dùng Request object
- Để **đồng nhất**: dùng Request object cho tất cả

---

## Checklist khi viết service mới

- [ ] Tạo file `{name}_request.dart` riêng
- [ ] Mỗi endpoint POST/PUT/PATCH có typed `@Body() XxxRequest`
- [ ] Endpoint GET có filter dùng `@Queries() XxxFilterRequest`
- [ ] Không có `Map<String, dynamic>` trong bất kỳ signature service nào
- [ ] Cubit nhận Request object, không nhận từng field rời
- [ ] Chạy **Build Runner** sau khi thêm class `@freezed` mới
