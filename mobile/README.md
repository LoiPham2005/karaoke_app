# 📱 Karaoke Mobile (Flutter)

Mobile app cho SingNow karaoke — clone từ `flutter_base` với toàn bộ features karaoke build mới.

> **Lưu ý**: Giai đoạn này chỉ build UI với mock data, chưa ghép API.

## 📦 Stack (kế thừa từ flutter_base)

- **Flutter** + **Dart 3**
- **Riverpod + codegen** (state management)
- **go_router + typed routes** (navigation)
- **freezed** (model — dùng khi ghép API)
- **theme_tailor** (design tokens)
- **flutter_screenutil** (responsive)

## 🎨 Theme

App tận dụng theme system có sẵn:
- `context.brandPrimary` — màu chủ đạo (đổi theme qua Settings)
- `context.bgPage`, `context.bgCard`, `context.bgInput`
- `context.textTitle`, `context.textBody`, `context.textSub`

Có thể đổi theme sang `AppPalette.pink` (đã có sẵn) cho phù hợp karaoke.

## 📁 Cấu trúc đã build

```
lib/
├── features/
│   ├── splash/                — Logo + delay 2s
│   ├── onboarding/            — 3 slides giới thiệu
│   ├── auth/                  — Login, Register, Forgot password
│   ├── main/                  — Shell với BottomNav (4 tabs)
│   ├── home/                  — Trang chủ Discover
│   ├── search/                — Tìm kiếm + filter chips
│   ├── library/               — Tab Playlist/Yêu thích/Lịch sử
│   ├── profile/               — Profile + stats + menu
│   ├── song/                  — Chi tiết bài hát
│   ├── player/                — ⭐ Player karaoke + lyrics đồng bộ
│   ├── playlist/              — Chi tiết playlist
│   ├── queue/                 — Hàng chờ phát
│   ├── category/              — Bài theo thể loại
│   ├── settings/              — Cài đặt
│   └── premium/               — Nâng cấp Premium
└── shared/
    ├── models/                — SongModel, PlaylistModel, ...
    ├── mocks/                 — Mock data cho UI
    ├── utils/                 — formatDuration, formatNumber
    └── widgets/               — KaraokeLogo, SongCard, SongTile,
                                  CategoryCard, PlaylistCard,
                                  MiniPlayerBar, LyricsHighlight,
                                  SectionHeader
```

## 🚀 Cách chạy

### 1. Cài deps

```bash
cd /Users/loipd/personal/karaoke_app/mobile
flutter pub get
```

### 2. Regen codegen (BẮT BUỘC)

Vì routes đã thay đổi hoàn toàn:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> ⚠️ Lệnh này regen `app_routes.g.dart` cho typed routes mới. Nếu không chạy sẽ báo lỗi `Classes can only mix in mixins and classes` (không tìm thấy `$XxxRoute` mixin).

### 3. Chạy app

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

Hoặc dùng VSCode Task có sẵn.

## ⚠️ Lưu ý về `core/services/app_auth/`

Khi xoá features cũ, một số file trong `core/services/app_auth/` còn import `features/auth/data/...`. Để build chạy được:

**Cách nhanh nhất (cho UI demo):** Tạo stub model tối thiểu

```dart
// lib/features/auth/data/models/auth_user_model.dart
class AuthUserModel {
  final String id;
  final String email;
  const AuthUserModel({required this.id, required this.email});
}
```

**Cách sạch (khi ghép API thật):** Refactor `core/services/app_auth/` không phụ thuộc features cụ thể.

## 📋 Routes đã đăng ký

| Route | Path | Page |
|-------|------|------|
| Splash | `/` | SplashPage |
| Onboarding | `/onboarding` | OnboardingPage (3 slides) |
| Login | `/login` | LoginPage |
| Register | `/register` | RegisterPage |
| Forgot password | `/forgot-password` | ForgotPasswordPage |
| Main shell | `/main`, `/home`, `/search`, `/library`, `/profile` | MainPage với BottomNav |
| Song detail | `/song/:id` | SongDetailPage |
| **Player ⭐** | `/play/:id` | PlayerPage (karaoke + lyrics đồng bộ) |
| Playlist detail | `/playlist/:id` | PlaylistDetailPage |
| Queue | `/queue` | QueuePage |
| Category | `/category/:slug` | CategoryPage |
| Settings | `/settings` | SettingsPage |
| Premium | `/premium` | PremiumPage |

Xem chi tiết kế hoạch: [../MOBILE_PLAN.md](../MOBILE_PLAN.md)

## 🎯 Tính năng nổi bật

### Player Page (`/play/:id`)
- **LyricsHighlight** widget: parse LRC + tự động cuộn theo dòng đang hát
- 4 size font lyrics: S/M/L/XL (chọn qua bottom sheet)
- Player controls đầy đủ: play/pause, prev/next, shuffle, slider tua
- Queue sidebar trượt từ dưới lên
- Click vào dòng lyrics để tua đến đúng vị trí

### Home Page
- Hero banner bài đang hot
- Trending horizontal scroll
- Categories grid với gradient màu theo từng thể loại
- Top charts

### Shared widgets có thể tái sử dụng
- `SongCard`, `SongTile`, `CategoryCard`, `PlaylistCard`
- `MiniPlayerBar` sticky trên BottomNav
- `LyricsHighlight` chuẩn karaoke

## 📌 Bước tiếp theo

1. Chạy `flutter pub get` + `dart run build_runner build`
2. Fix các import features cũ trong `core/services/app_auth/` (xem mục lưu ý ở trên)
3. Test UI trên máy ảo
4. Khi sẵn sàng ghép API:
   - Thay mock data trong `shared/mocks/` bằng Retrofit service
   - Migrate plain class models sang freezed
   - Thêm Riverpod notifier extending `BaseNotifier<T>` (xem CLAUDE.md)
