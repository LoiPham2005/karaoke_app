---
name: commands
description: Tra cứu toàn bộ câu lệnh có sẵn — Makefile, VSCode Tasks, và Dart tools trong tools/. Dùng khi user hỏi "lệnh nào để...", "chạy bằng lệnh gì", "make gì", "task nào", hoặc cần biết cách thực thi một thao tác.
when_to_use: Trigger khi user hỏi về cách chạy lệnh, build, test, generate code, theme, l10n, route, rename package, tạo feature, hoặc bất kỳ thao tác nào có thể thực hiện qua terminal hoặc VSCode.
allowed-tools: Bash
---

# Câu lệnh có sẵn trong project

---

## 1. Makefile (`make <target>`)

```!
make help
```

---

## 2. VSCode Tasks (`Ctrl+Shift+P` → "Run Task")

| Task | Tương đương Makefile |
|---|---|
| `🚀 Run: Debug` | `make run-dev / run-stg / run-prod` |
| `🚀 Build: APK` | `make apk-dev / apk-stg / apk-prod` |
| `🚀 Build: AAB` | `make aab-prod` |
| `🍎 Build: iOS` | *(macOS only)* |
| `⚡ Build Runner` | `make gen` (build) / `make watch` |
| `🌐 Localization` | `make l10n / l10n_sync / l10n_sync_translate` |
| `📦 Assets & Resources` | `make gen-assets / icons / splash / bloc_gen` |
| `🛣️ Route: Info` | `make route-list / route-scan` |
| `🛣️ Route: Generate New` | `make route-gen` |
| `🧹 Maintenance` | `make get / clean / upgrade / full-gen` |
| `🔧 Quality` | `make analyze / format / fix` |
| `🧪 Testing` | `make test / cov` |
| `🧱 Mason: Generate Feature` | `make feature-rut-gon-gen / feature-co-dien / ...` |
| `🔧 Rename: Package Name` | `make rename-package name="new_name"` |
| `🏷️ Rename: App Label` | `make rename-app name="New App"` |
| `⚙️ FVM: Info` | `fvm list / releases / global` |
| `⚙️ FVM: Version` | `fvm use / install / remove <version>` |

---

## 3. Dart Tools (`tools/`)

### `tools/generate_bloc_helper.dart`
Quét toàn bộ `*_cubit.dart` và `*_bloc.dart` có `@injectable`, sinh ra `BuildContext` extensions tại `lib/core/base/state/bloc/auto_bloc/bloc_extensions.g.dart`.

```bash
# Chạy trực tiếp
fvm dart run tools/generate_bloc_helper.dart

# Qua Makefile
make bloc_gen
```

> Chạy sau khi thêm Cubit/Bloc mới để có `context.read<MyCubit>()` extension.

---

### `tools/generate_route.dart`
Quản lý typed go_router routes. Hỗ trợ 3 modes:

```bash
# Liệt kê tất cả routes đã đăng ký
fvm dart run tools/generate_route.dart --list
make route-list

# Quét lib/features/ để tìm page chưa có route
fvm dart run tools/generate_route.dart --scan
make route-scan

# Thêm route mới (điền đủ 5 tham số)
fvm dart run tools/generate_route.dart \
  --name ProfileRoute \
  --path /profile \
  --page ProfilePage \
  --import features/profile/presentation/pages/profile_page.dart \
  --group Main
```

> Sau khi gen route: chạy `make gen` để build_runner sinh `$RouteNameRoute` mixin.

---

### Theme system
Không cần codegen — toàn bộ theme nằm trong `lib/design/theme/app_palette.dart`:
- `enum AppPalette { classic, ocean, blossom, forest, sunset, ruby, amethyst, gold }` — thêm 1 màu = thêm 1 dòng enum.
- Mỗi entry chỉ cần `seed color`. Material3 `ColorScheme.fromSeed` tự sinh full ColorScheme cho cả light/dark.
- `AppExtraColors` (`success`/`warning`/`info`) qua `ThemeExtension`. Truy cập: `context.extras.success`.

> Config: `lib/design/theme/colors/color_config.json` · Source theme: `light`

---

### `tools/l10n_sync.dart`
Đồng bộ ARB files và auto-translate. Source: `lib/design/l10n/translations/app_en.arb`.

```bash
# Sync ARB + dịch tự động
fvm dart run tools/l10n_sync.dart --translate
make l10n_sync

# Sync + translate + gen-l10n (full pipeline)
fvm dart run tools/l10n_sync.dart --translate && fvm flutter gen-l10n
make l10n_sync_translate

# Dry run — xem thay đổi, không ghi file
fvm dart run tools/l10n_sync.dart --dry-run

# Verbose — log chi tiết
fvm dart run tools/l10n_sync.dart --translate --verbose

# Chỉ gen-l10n (không sync/translate)
fvm flutter gen-l10n
make l10n
```

> ARB directory: `lib/design/l10n/translations/` · Source file: `app_en.arb`

---

## Gợi ý nhanh

| Muốn làm gì | Lệnh ngắn nhất |
|---|---|
| Cài dependencies | `make get` |
| Generate code (1 lần) | `make gen` |
| Theo dõi thay đổi liên tục | `make watch` |
| Reset hoàn toàn | `make full-gen` |
| Tạo feature mới | `make feature-rut-gon-gen` |
| Chạy app dev | `make run-dev` |
| Build APK prod | `make apk-prod` |
| Build AAB prod | `make aab-prod` |
| Thêm route mới | `make route-scan` rồi `make gen` |
| Gen bloc extensions | `make bloc_gen` |
| Update theme tokens | `make theme-sync` |
| Sync bản dịch | `make l10n_sync` |
| Đổi tên package | `make rename-package name="my_app"` |
| Đổi tên app | `make rename-app name="My App"` |
