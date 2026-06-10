---
name: shared
description: Shared layer — Base entities/models, CommonParam, shared widgets (AppButton, AppTextField, AppScaffold, dialogs, responsive). Dùng khi cần widget tái sử dụng, base class cho model/entity, pagination params.
when_to_use: Trigger khi user hỏi về widget có sẵn, AppButton, AppTextField, AppScaffold, dialog, empty state, loading widget, base model, CommonParam, pagination.
user-invocable: false
allowed-tools: Read Glob Grep
---

# Shared Layer — `lib/shared/`

```
lib/shared/
  models/
    base/
      base_entity.dart       — BaseEntity, IdentifiableEntity, TimestampEntity
      base_model.dart        — BaseModel, JsonSerializable mixin, EntityMapper mixin
      common_param.dart      — CommonParam (filter/pagination params)
      paginated_response.dart
  widgets/
    layout/                  — AppScaffold, BasePage, LoadingScaffold, TabbedScaffold
    responsive/              — ResponsiveBuilder, ResponsiveValue, ResponsiveGrid
    buttons/                 — AppButton
    inputs/                  — AppTextField, AppCheckbox, AppDropdown, AppSearchField
    display/                 — AppCard, InfoCard, CustomImage, UserAvatar
    list/                    — AppListView, AppGridView, EmptyListWidget
    dialogs/                 — AppDialog, ConfirmDialog, LoadingDialog, RatingDialog
    state/                   — LoadingWidget, EmptyWidget, ErrorWidget, StateBuilder
    other/                   — AppAppBar, PageTransition, RatingBar, CustomCarousel, Dash
```

---

## Base Models & Entities

### BaseEntity / IdentifiableEntity / TimestampEntity

```dart
// Dùng cho Domain layer (nếu có)
abstract class BaseEntity extends Equatable {}

abstract class IdentifiableEntity extends BaseEntity {
  dynamic get id;
}

abstract class TimestampEntity extends IdentifiableEntity {
  DateTime? get createdAt;
  DateTime? get updatedAt;
}
```

### BaseModel

```dart
abstract class BaseModel extends Equatable {
  Map<String, dynamic> toJson();
  BaseModel copyWith();
}

// Mixins dùng khi implement
mixin JsonSerializable {
  Map<String, dynamic> toJson();
}

mixin EntityMapper<E> {
  E toEntity();       // Chuyển Model → Entity (khi dùng Domain layer)
}
```

> **Thực tế**: hầu hết model dùng `@freezed` trực tiếp — BaseModel chỉ cần khi muốn type-safe base class.

### CommonParam (filter/pagination)

```dart
class CommonParam {
  final int page;         // default 1
  final int limit;        // default AppConstants.defaultPageSize
  final String? search;
  final String? sortBy;
  final SortOrder sortOrder;  // SortOrder.asc | SortOrder.desc
  final Map<String, dynamic> filters;
  final DateTime? startDate;
  final DateTime? endDate;

  // Factory helpers
  CommonParam.initial()    // page 1, default limit
  CommonParam.search(query) // tìm kiếm

  // Methods
  CommonParam nextPage()   // tăng page lên 1
  CommonParam refresh()    // reset về page 1
  CommonParam withSearch(String query)
}
```

**Dùng trong Cubit:**
```dart
class ProductListCubit extends BaseCubit<List<ProductModel>> {
  CommonParam _params = CommonParam.initial();

  Future<void> loadList({CommonParam? params}) {
    _params = params ?? CommonParam.initial();
    return runServiceUnwrap(
      action: () => _service.getList(params: _params),
      cancelPrevious: true,
    );
  }

  Future<void> refresh() => runServiceUnwrap(
    action: () => _service.getList(params: _params.refresh()),
    loadingState: BaseState.loading(previousData: state.data),
    cancelPrevious: true,
  );
}
```

---

## Shared Widgets

### AppScaffold (layout)

```dart
AppScaffold(
  appBar: AppAppBar(title: 'Trang chủ'),
  body: content,
  padding: EdgeInsets.all(16),
  safeArea: true,
  backgroundColor: Theme.of(context).colorScheme.background,
  floatingActionButton: FloatingActionButton(...),
)
```

### BasePage (stateful base)

```dart
class MyPage extends BasePage {
  const MyPage({super.key});

  @override
  Widget buildPage(BuildContext context) => ...;

  // Override nếu cần
  @override PreferredSizeWidget? get appBar => AppAppBar(title: '...');
  @override bool get safeArea => true;
}
```

### TabbedScaffold

```dart
TabbedScaffold(
  tabs: ['Tab 1', 'Tab 2', 'Tab 3'],
  children: [Widget1(), Widget2(), Widget3()],
)
```

---

### AppButton

```dart
// Types: primary (default), secondary, outline, text, danger
// Sizes: small, medium (default), large

AppButton(
  label: 'Đăng nhập',
  onPressed: () => cubit.login(),
  isLoading: state.isLoading,     // hiện spinner, disable button
  type: AppButtonType.primary,
  size: AppButtonSize.large,
  fullWidth: true,
  icon: Icons.login,
)

AppButton.outline(
  label: 'Hủy',
  onPressed: () => Navigator.pop(context),
)

AppButton.danger(
  label: 'Xóa',
  onPressed: () => cubit.delete(id),
)
```

---

### AppTextField

```dart
AppTextField(
  label: 'Email',
  hint: 'example@email.com',
  controller: _emailController,
  validator: Validators.email,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
)

AppTextField.password(
  label: 'Mật khẩu',
  controller: _pwdController,
  validator: Validators.password,
  // toggle visibility tự động có sẵn
)
```

### AppSearchField

```dart
AppSearchField(
  hint: 'Tìm kiếm...',
  onChanged: (query) => cubit.search(query),
  onClear: () => cubit.clearSearch(),
)
```

---

### Dialog widgets

```dart
// Alert dialog đơn giản
showDialog(context: context, builder: (_) => AppDialog(
  title: 'Thông báo',
  content: 'Nội dung',
  actions: [AppButton(label: 'OK', onPressed: () => Navigator.pop(context))],
));

// Confirm với 2 nút
showDialog(context: context, builder: (_) => ConfirmDialog(
  title: 'Xác nhận',
  content: 'Bạn có chắc muốn xóa?',
  onConfirm: () => cubit.delete(id),
  confirmLabel: 'Xóa',
  cancelLabel: 'Hủy',
  isDanger: true,
));

// Loading overlay
showDialog(context: context, builder: (_) => LoadingDialog(
  message: 'Đang xử lý...',
));

// Rating dialog
showDialog(context: context, builder: (_) => RatingDialog(
  onRated: (rating) => analytics.logEvent('app_rated', parameters: {'rating': rating}),
));
```

---

### State Widgets

```dart
// Loading
LoadingWidget()
LoadingWidget(message: 'Đang tải...')

// Empty state
EmptyWidget(
  message: 'Không có dữ liệu',
  icon: Icons.inbox_outlined,
  action: AppButton(label: 'Thêm mới', onPressed: ...),
)

// Error state
ErrorWidget(
  message: state.error ?? 'Có lỗi xảy ra',
  onRetry: () => cubit.reload(),
)

// Conditional render
StateBuilder<MyData>(
  state: state,
  onLoading: () => LoadingWidget(),
  onSuccess: (data) => MyContent(data: data),
  onEmpty: () => EmptyWidget(),
  onError: (msg) => ErrorWidget(message: msg, onRetry: cubit.reload),
)
```

---

### Display Widgets

```dart
// Image với fallback
CustomImage(
  url: user.avatarUrl,
  width: 80,
  height: 80,
  borderRadius: AppDimensions.circle,
  placeholder: Icons.person,
)

// User avatar
UserAvatar(
  user: currentUser,
  size: 48,
  onTap: () => ProfileRoute().push(context),
)

// Rating bar
RatingBar(
  rating: product.rating,
  maxRating: 5,
  onRatingChanged: (r) => cubit.rate(r),
)

// Dashed divider
Dash(color: AppColors.grey, height: 1)
```

---

### AppAppBar

```dart
AppAppBar(
  title: 'Chi tiết sản phẩm',
  showBack: true,
  actions: [
    IconButton(icon: Icon(Icons.share), onPressed: ...),
  ],
)
```

---

## Responsive Design

```dart
// Breakpoints (từ AppDimensions)
// Mobile  < 600
// Tablet  600-900
// Desktop > 900

ResponsiveBuilder(
  mobile: (_) => MobileLayout(),
  tablet: (_) => TabletLayout(),
  desktop: (_) => DesktopLayout(),
)

// ScreenInfo
final screen = ScreenInfo.of(context);
screen.isMobile     // bool
screen.isTablet     // bool
screen.deviceType   // DeviceType enum
screen.orientation  // Orientation

// Responsive padding
ResponsivePadding(
  mobile: EdgeInsets.all(16),
  tablet: EdgeInsets.all(24),
)
```
