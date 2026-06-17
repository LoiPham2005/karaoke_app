# 📱 KẾ HOẠCH MOBILE APP - KARAOKE (FLUTTER)

> **Base**: Clone từ `flutter_base` — Riverpod + go_router typed routes + freezed + Retrofit
> **Giai đoạn**: Build UI với mock data, chưa ghép API

---

## 1. TỔNG QUAN

### 1.1. Mục tiêu
- Mobile app karaoke chạy trên Android + iOS
- Search bài YouTube + lyrics đồng bộ
- Tận dụng kiến trúc có sẵn của `flutter_base`: BaseNotifier, AppColors, AppDimensions, shared widgets

### 1.2. Cấu trúc dự án (kế thừa)
```
mobile/
├── lib/
│   ├── config/         # Flavor, env (giữ nguyên)
│   ├── core/           # base, network, common, services (giữ nguyên)
│   ├── design/         # theme, l10n (giữ nguyên, tận dụng pink theme)
│   ├── modules/        # ads, analytics, app_config (giữ nguyên)
│   ├── routes/         # go_router typed routes (cập nhật routes mới)
│   ├── features/       # ❌ ĐÃ XÓA — build lại cho karaoke
│   ├── shared/         # ❌ ĐÃ XÓA — build lại
│   ├── app.dart
│   └── main_*.dart
```

### 1.3. State management
- **Riverpod + codegen** (theo CLAUDE.md): `@riverpod class XxxNotifier extends _$XxxNotifier with BaseNotifier<T>`
- Giai đoạn này dùng mock data inline trong Notifier `build()` (không gọi service)

### 1.4. Theme
- Dùng `AppPalette.pink` làm theme mặc định cho karaoke (đã có sẵn trong dự án)
- Tận dụng `context.brandPrimary`, `context.bgPage`, `context.textTitle`...

---

## 2. DANH SÁCH FEATURES & MÀN HÌNH

### 2.1. 🚀 splash
| Page | Route | Mô tả |
|------|-------|-------|
| SplashPage | `/splash` | Logo + loading 2s → /onboarding hoặc /home |

### 2.2. 👋 onboarding
| Page | Route | Mô tả |
|------|-------|-------|
| OnboardingPage | `/onboarding` | 3 slides giới thiệu app (lần đầu mở) |

### 2.3. 🔐 auth
| Page | Route | Mô tả |
|------|-------|-------|
| LoginPage | `/login` | Email + password + Google |
| RegisterPage | `/register` | Đăng ký |
| ForgotPasswordPage | `/forgot-password` | Quên mật khẩu |

### 2.4. 🏠 main (shell với BottomNav)
| Tab | Route | Page |
|-----|-------|------|
| Trang chủ | `/home` | HomePage |
| Tìm kiếm | `/search` | SearchPage |
| Thư viện | `/library` | LibraryPage |
| Profile | `/profile` | ProfilePage |

### 2.5. 🎵 song
| Page | Route | Mô tả |
|------|-------|-------|
| SongDetailPage | `/song/:id` | Chi tiết bài hát + tab lyrics/info/similar |

### 2.6. ▶️ player ⭐
| Page | Route | Mô tả |
|------|-------|-------|
| PlayerPage | `/play/:id` | Karaoke fullscreen — Video + lyrics đồng bộ + controls |

### 2.7. 📋 playlist
| Page | Route | Mô tả |
|------|-------|-------|
| PlaylistDetailPage | `/playlist/:id` | Chi tiết playlist + ds bài |
| QueuePage | `/queue` | Hàng chờ phát |

### 2.8. 🎼 category
| Page | Route | Mô tả |
|------|-------|-------|
| CategoryPage | `/category/:slug` | Bài theo thể loại |

### 2.9. ⚙️ settings
| Page | Route | Mô tả |
|------|-------|-------|
| SettingsPage | `/settings` | Cài đặt (theme, ngôn ngữ, phát) |
| EditProfilePage | `/settings/profile` | Chỉnh sửa thông tin |
| PremiumPage | `/premium` | Nâng cấp premium |

---

## 3. SHARED WIDGETS (lib/shared/widgets/)

| Widget | Mô tả |
|--------|-------|
| `KaraokeLogo` | Logo app với gradient |
| `SongCard` | Card bài hát (vertical) — thumbnail + title + artist |
| `SongTile` | List tile bài hát (horizontal) — cho danh sách |
| `CategoryCard` | Card thể loại với gradient màu |
| `PlaylistCard` | Card playlist |
| `MiniPlayerBar` | Bottom mini player (sticky trên BottomNav) |
| `LyricsHighlight` | Lyrics đồng bộ — highlight dòng đang hát |
| `SearchBar` | Search input có suggestions |
| `SectionHeader` | Header section "Xem tất cả →" |
| `EmptyState` | Empty state generic |
| `LoadingState` | Loading state |

## 4. SHARED MODELS (lib/shared/models/)

```dart
// Song
@freezed
class SongModel with _$SongModel {
  const factory SongModel({
    required String youtubeId,
    required String title,
    required String artist,
    required String thumbnailUrl,
    required int duration,
    required int viewCount,
    @Default(false) bool hasLyrics,
    @Default('vpop') String category,
    @Default(false) bool isFavorite,
  }) = _SongModel;
}

// Playlist, Category, UserProfile, LyricLine — tương tự
```

---


---

## 6. ROADMAP

### Phase 1: Foundation (đang làm)
- [x] Clone flutter_base
- [x] Xóa features + shared cũ
- [ ] Tạo shared models (freezed) + mock data
- [ ] Tạo shared widgets
- [ ] Update routes
- [ ] Set theme pink làm default

### Phase 2: Splash + Auth
- [ ] Splash + Onboarding
- [ ] Login + Register + Forgot password

### Phase 3: Main shell + Home
- [ ] Main shell với BottomNav
- [ ] Home (discover, trending, categories)
- [ ] Search với filter

### Phase 4: Player ⭐
- [ ] Song detail
- [ ] Player page với lyrics đồng bộ
- [ ] Queue management

### Phase 5: Library + Profile + Settings
- [ ] Library (playlists/favorites/history)
- [ ] Playlist detail
- [ ] Profile + Edit
- [ ] Settings + Premium

### Phase 6: Polish
- [ ] Animation transitions
- [ ] Pull-to-refresh
- [ ] Empty/error states
- [ ] Dark mode test
- [ ] Tablet responsive

---

## 7. CÁCH CHẠY

```bash
cd /Users/loipd/personal/karaoke_app/mobile

# Cài deps
flutter pub get

# Build runner (cho freezed + go_router codegen)
dart run build_runner build --delete-conflicting-outputs

# Chạy dev
flutter run --flavor dev -t lib/main_dev.dart
```

Hoặc dùng VSCode Tasks có sẵn trong dự án.
