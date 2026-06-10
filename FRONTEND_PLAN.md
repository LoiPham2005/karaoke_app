# 🎨 KẾ HOẠCH XÂY DỰNG FRONTEND - KARAOKE APP

> **Tech Stack**: Next.js 14 (App Router) + TypeScript + TailwindCSS + shadcn/ui
> **Giai đoạn**: Thiết kế UI với mock data, **chưa ghép API backend**

---

## 1. TỔNG QUAN

### 1.1. Mục tiêu giai đoạn này
- Thiết kế và build toàn bộ giao diện các màn hình
- Sử dụng **mock data** (data giả) để hiển thị
- Đảm bảo responsive: PC, tablet, mobile, smart TV
- Sẵn sàng để ghép API ở giai đoạn sau (cấu trúc theo dạng service-based)

### 1.2. Nguyên tắc thiết kế
- **Dark theme first** — hợp với không gian karaoke, đỡ chói mắt
- **Player-centric** — màn hình phát nhạc + lyrics là trung tâm
- **Mobile-friendly** — vì user thường cầm điện thoại để search bài
- **TV-mode** — UI có chế độ "cast lên TV" với font to, control đơn giản
- **Tiếng Việt chính**, có thể i18n sau

---

## 2. STACK CÔNG NGHỆ FRONTEND

| Thành phần | Công nghệ | Lý do |
|-----------|-----------|-------|
| Framework | **Next.js 14** (App Router) | SSR, file-based routing, SEO tốt |
| Ngôn ngữ | **TypeScript** | Type-safe, đồng bộ với BE |
| Styling | **TailwindCSS** | Utility-first, dev nhanh |
| UI Components | **shadcn/ui** | Copy-paste, customize hoàn toàn |
| Icons | **lucide-react** | Đẹp, đầy đủ, miễn phí |
| State (UI) | **Zustand** | Đơn giản hơn Redux |
| Server state | **TanStack Query** (sau khi ghép API) | Cache, retry, mutation |
| Forms | **react-hook-form + zod** | Performance + validation |
| YouTube Player | **react-youtube** | Wrapper IFrame API |
| Lyrics | **Custom component** | Highlight đồng bộ timestamp |
| Animation | **framer-motion** | Smooth transitions |
| Toast/Notify | **sonner** | Đẹp, accessible |
| Theme | **next-themes** | Dark/light mode |
| Font | **Inter + Be Vietnam Pro** | Sans-serif đẹp cho tiếng Việt |

---

## 3. DESIGN SYSTEM

### 3.1. Color palette (Dark theme chủ đạo)

```
Primary:    #FF3D71 (Hồng karaoke — nổi bật, energetic)
Secondary:  #8B5CF6 (Tím — accent)
Success:    #00D68F
Warning:    #FFAA00
Danger:     #FF3D71
Info:       #0095FF

Background:
  - bg-base:      #0A0A0F (đen sâu)
  - bg-elevated:  #14141B
  - bg-card:      #1C1C26
  - bg-hover:     #25252F

Text:
  - text-primary:   #FFFFFF
  - text-secondary: #B4B4C0
  - text-muted:     #6B6B7B
  - text-disabled:  #3F3F4F

Border: #2A2A35

Karaoke highlight (lyrics):
  - active:   #FF3D71 (dòng đang hát)
  - upcoming: #FFFFFF (sắp tới)
  - passed:   #6B6B7B (đã qua)
```

### 3.2. Typography
- Heading: Inter Bold
- Body: Be Vietnam Pro Regular (đẹp cho tiếng Việt)
- Mono: JetBrains Mono (cho timestamps)
- Sizes: 12, 14, 16, 18, 20, 24, 32, 48 (px)

### 3.3. Spacing
- 4px base unit: 4, 8, 12, 16, 24, 32, 48, 64, 96

### 3.4. Component patterns
- **Card**: rounded-2xl, bg-card, border subtle, hover lift
- **Button**: rounded-full hoặc rounded-xl, có hover/active state
- **Input**: rounded-xl, focus ring primary
- **Modal**: backdrop blur, slide-up trên mobile
- **Toast**: bottom-right, auto dismiss 4s

---

## 4. DANH SÁCH MÀN HÌNH (PAGES & COMPONENTS)

### 🌐 4.1. Public Pages (không cần đăng nhập)

| # | Trang | Route | Mô tả |
|---|-------|-------|-------|
| 1 | **Landing** | `/` | Giới thiệu app, CTA đăng ký |
| 2 | **Login** | `/login` | Đăng nhập email + Google |
| 3 | **Register** | `/register` | Đăng ký tài khoản |
| 4 | **Forgot Password** | `/forgot-password` | Quên mật khẩu |
| 5 | **Reset Password** | `/reset-password` | Đặt lại mật khẩu (qua link email) |
| 6 | **Verify Email** | `/verify-email` | Xác thực email |

### 🎵 4.2. App Pages (sau khi đăng nhập)

| # | Trang | Route | Mô tả |
|---|-------|-------|-------|
| 7 | **Home / Discover** | `/home` | Trang chủ: trending, đề xuất, thể loại |
| 8 | **Search** | `/search?q=` | Kết quả tìm kiếm |
| 9 | **Song Detail** | `/song/[id]` | Chi tiết bài hát + lyrics preview |
| 10 | **Player (Karaoke)** | `/play/[id]` | Phát video + lyrics đồng bộ |
| 11 | **My Library** | `/library` | Tab playlist / yêu thích / lịch sử |
| 12 | **Playlist Detail** | `/playlist/[id]` | Xem bài trong playlist |
| 13 | **Queue** | `/queue` | Hàng chờ phát |
| 14 | **Category** | `/category/[slug]` | Bài theo thể loại (Bolero, Vpop...) |
| 15 | **Artist** | `/artist/[name]` | Bài của 1 ca sĩ |
| 16 | **Profile** | `/profile` | Thông tin cá nhân |
| 17 | **Settings** | `/settings` | Cài đặt: theme, ngôn ngữ, phát |

### 👥 4.3. Social Pages (Phase 2 — UI sẵn, tính năng sau)

| # | Trang | Route | Mô tả |
|---|-------|-------|-------|
| 18 | **Room** | `/room/[code]` | Phòng hát chung realtime |
| 19 | **Feed** | `/feed` | Newsfeed bạn bè |
| 20 | **User Profile** | `/u/[username]` | Profile public của user khác |

### ⚙️ 4.4. Admin Pages (role = ADMIN)

| # | Trang | Route | Mô tả |
|---|-------|-------|-------|
| 21 | **Admin Dashboard** | `/admin` | Tổng quan stats |
| 22 | **Manage Users** | `/admin/users` | DS user, ban/edit |
| 23 | **Manage Reports** | `/admin/reports` | Báo cáo bài lỗi |
| 24 | **Manage Lyrics** | `/admin/lyrics` | Duyệt lyrics đóng góp |
| 25 | **Manage Songs** | `/admin/songs` | Quản lý cache bài hát |

### 🚫 4.5. Utility Pages

| # | Trang | Route | Mô tả |
|---|-------|-------|-------|
| 26 | **404** | `*` | Không tìm thấy |
| 27 | **500** | - | Lỗi server |
| 28 | **Offline** | - | Mất mạng |
| 29 | **Maintenance** | - | Bảo trì |

---

## 5. CHI TIẾT CÁC MÀN HÌNH

### 5.1. 🏠 Landing Page (`/`)
**Mục đích**: Marketing, thu hút user mới

**Components**:
- Hero section: tagline lớn, video demo, CTA "Hát ngay"
- Features grid: 6 tính năng nổi bật (icon + title + desc)
- "Cách hoạt động" - 3 bước (Tìm → Phát → Hát)
- Testimonials (Phase sau)
- Pricing (Free vs Premium)
- Footer: links, social, contact

### 5.2. 🔐 Auth Pages (`/login`, `/register`)

**Login**:
- Logo + tagline
- Form: email + password
- "Đăng nhập với Google" button
- Link: "Quên mật khẩu?", "Chưa có tài khoản? Đăng ký"
- Validation real-time

**Register**:
- Form: email, password, displayName
- Checkbox: đồng ý điều khoản
- "Đăng ký với Google"
- Strength indicator cho password

### 5.3. 🏡 Home / Discover (`/home`)

**Layout**: Sidebar trái + Content chính + Player bar dưới (sticky)

**Sections** (vuốt ngang trên mobile):
1. **Hero banner**: Bài hát đang hot, big card
2. **🔥 Trending**: Top 10 đang hot
3. **🎵 Đề xuất cho bạn**: Theo lịch sử
4. **💝 Đã yêu thích gần đây**
5. **📚 Thể loại**: Grid 8-12 category (Bolero, Vpop, EDM, USUK, Trữ tình...)
6. **🎤 Karaoke mới ra**: Bài mới upload
7. **⭐ Top tuần này**

**Components**:
- `<SongCard>`: Thumbnail + title + artist + nút play
- `<CategoryCard>`: Gradient bg + tên + icon
- `<TrendingList>`: Số thứ tự + thumbnail nhỏ
- `<HorizontalScroll>`: Scroll container ngang

### 5.4. 🔍 Search (`/search?q=`)

**Components**:
- Search bar to ở trên (sticky)
- Filter chips: Tất cả / Karaoke / Có lời / Không lời / Beat / Demo
- Filter dropdown: Thể loại, Thời lượng, Năm phát hành
- Sort: Liên quan / Mới nhất / Nhiều view nhất
- Kết quả grid hoặc list (toggle view)
- Empty state: "Không tìm thấy bài hát"
- Loading skeleton

**Search history** (sidebar): Lịch sử tìm kiếm gần đây, clear all

### 5.5. 🎵 Song Detail (`/song/[id]`)

**Components**:
- Hero: thumbnail lớn + tên bài + ca sĩ + thời lượng + view
- Action buttons: ▶️ Phát ngay / ➕ Thêm queue / ❤️ Yêu thích / 🔗 Share / 🚩 Báo lỗi
- Tab: **Lyrics preview** / **Thông tin** / **Bài tương tự**
- Lyrics preview: 8-10 dòng đầu, có nút "Xem lời đầy đủ"
- Bài tương tự: Grid 4-8 bài

### 5.6. ▶️ Player Page (`/play/[id]`) ⭐ **QUAN TRỌNG NHẤT**

**Layout 2 chế độ:**

#### Chế độ 1: Default (laptop/PC)
```
┌──────────────────────────────────────────────────────┐
│  Header: ← Back | Song title - Artist | ⚙️ ⛶       │
├────────────────────────────────┬─────────────────────┤
│                                │                     │
│                                │  Queue / Up next   │
│      Video Player (16:9)       │  ┌───────────────┐ │
│      (YouTube IFrame)          │  │ Bài tiếp 1    │ │
│                                │  │ Bài tiếp 2    │ │
│                                │  │ Bài tiếp 3    │ │
│                                │  └───────────────┘ │
│                                │                     │
├────────────────────────────────┴─────────────────────┤
│                                                      │
│              🎤 LYRICS HIGHLIGHT 🎤                  │
│   (Dòng trước - mờ)                                  │
│   (Dòng đang hát - to, hồng, highlight từng chữ)    │
│   (Dòng sắp tới - trắng nhạt)                       │
│                                                      │
├──────────────────────────────────────────────────────┤
│ ⏮ ⏯ ⏭   00:45 ━━━━●─────── 03:20   🔊 ⚙️ 🔄 🔀  │
└──────────────────────────────────────────────────────┘
```

#### Chế độ 2: TV Mode (fullscreen)
- Video full màn hình
- Lyrics overlay phía dưới, font cực to
- Ẩn UI thừa, chỉ hiện khi di chuột

**Components chính**:
- `<YouTubePlayer>`: Wrapper player + control
- `<LyricsHighlight>`: Component karaoke effect
- `<PlayerControls>`: ⏮ ⏯ ⏭ progress volume
- `<QueueSidebar>`: Danh sách bài tiếp
- `<SongInfo>`: Title, artist, score (nếu có)

**Lyrics highlight chi tiết**:
- Active line: font 32px, màu primary, **scale 1.1**, bold
- Word-by-word highlight (nếu LRC enhanced)
- Smooth scroll: dòng active luôn ở giữa
- Click 1 dòng → tua đến timestamp đó
- Toggle: bật/tắt lyrics, đổi font size (S/M/L/XL)

**Toolbar phát**:
- Tốc độ: 0.75x / 1x / 1.25x
- Mute vocal (nếu có file beat riêng)
- Loop bài / Loop queue
- Shuffle
- Cast to TV (cho phase sau)
- Record (Phase 3)

### 5.7. 📚 My Library (`/library`)

**Tabs**:
1. **Playlist của tôi**: Grid card playlist + nút "Tạo mới"
2. **Yêu thích**: List bài đã ❤️ + filter/sort
3. **Lịch sử**: List bài đã hát (group theo ngày: Hôm nay, Hôm qua, Tuần này, Cũ hơn)
4. **Đóng góp lyrics** (collapse): Lyrics đã gửi + trạng thái duyệt

**Playlist card**:
- Cover image (4 thumbnail ghép)
- Tên + số bài
- Public/Private icon
- Menu: edit, share, delete

### 5.8. 📋 Playlist Detail (`/playlist/[id]`)

- Cover lớn + title + description + owner + số bài + thời lượng tổng
- Actions: ▶️ Phát tất cả / 🔀 Shuffle / ➕ Thêm bài / 🔗 Share / ✏️ Edit
- Table bài hát: #, thumbnail, title, artist, duration, ❤️, ⋮ menu
- Drag-and-drop để sắp xếp lại
- Empty state: "Playlist chưa có bài nào"

### 5.9. 🎬 Queue (`/queue`)

**Có thể là 1 trang hoặc 1 sidebar trượt:**
- "Đang phát": card bài hiện tại
- "Tiếp theo" (manual added): list bài user thêm
- "Đề xuất tự động": list 5-10 bài đề xuất
- Drag-drop reorder
- Nút "Xóa toàn bộ"

### 5.10. 🎼 Category Page (`/category/[slug]`)

- Hero banner gradient theo category
- Sub-filter: Theo năm, theo độ hot
- Grid bài hát (infinite scroll)
- Top 10 trong category này

### 5.11. 👤 Profile (`/profile`)

**Components**:
- Header: Avatar (click để đổi) + Display name + Email + Edit button
- Stats: Số bài đã hát / Tổng thời gian hát / Playlist tạo / Lyrics đóng góp
- Badge: Premium / Free
- Activity chart: Heatmap 30 ngày (giống GitHub)
- Tab: **Hoạt động** / **Playlist công khai** / **Bản thu** (phase 3)

### 5.12. ⚙️ Settings (`/settings`)

**Tabs (sidebar)**:
1. **Tài khoản**: Display name, email, đổi mật khẩu, xóa tài khoản
2. **Giao diện**: Theme (dark/light/auto), ngôn ngữ
3. **Phát nhạc**:
   - Tự động phát bài tiếp theo
   - Chất lượng video (auto/720/1080)
   - Karaoke effect (highlight từng chữ)
   - Font size lyrics
4. **Thông báo**: Email, push
5. **Riêng tư**: Lịch sử công khai/riêng tư, ai có thể follow
6. **Premium**: Upgrade / Manage subscription
7. **Hỗ trợ**: FAQ, Liên hệ, Báo lỗi

### 5.13. 🏠 Room Page (`/room/[code]`) — Phase 2

- Code phòng to ở trên, share button
- Danh sách user trong phòng (avatar circle)
- Player chung
- Queue chung (ai cũng add được)
- Chat sidebar
- Host control: kick, skip

### 5.14. ⚙️ Admin Dashboard (`/admin`)

**Components**:
- Stats cards: Tổng user, DAU, MAU, Bài đã phát, Doanh thu
- Charts: User growth, Top bài hát, Heatmap giờ phát nhiều
- Recent activities: log user mới, báo cáo mới
- Quick actions: Duyệt báo cáo, Duyệt lyrics

### 5.15. 👥 Admin - Users (`/admin/users`)

- Table: avatar, name, email, role, status, last active, created
- Filter: role, status, premium
- Search by name/email
- Actions: View, edit role, ban, delete
- Bulk action: ban multiple

### 5.16. 🚩 Admin - Reports (`/admin/reports`)

- Table báo cáo: bài hát, lý do, người báo, status, ngày
- Filter: pending/resolved
- Click vào để xem chi tiết + nghe thử
- Actions: Mark resolved / Reject / Block song

### 5.17. 📝 Admin - Lyrics Contributions

- Table lyrics chờ duyệt
- Preview LRC side-by-side (cũ vs đề xuất)
- Sync test (phát thử bài + lyrics user gửi)
- Approve / Reject + lý do

---

## 6. CẤU TRÚC THƯ MỤC FRONTEND

```
frontend/
├── public/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── (auth)/                   # Auth group layout
│   │   │   ├── login/page.tsx
│   │   │   ├── register/page.tsx
│   │   │   ├── forgot-password/page.tsx
│   │   │   └── layout.tsx
│   │   ├── (main)/                   # Main app layout (có sidebar)
│   │   │   ├── home/page.tsx
│   │   │   ├── search/page.tsx
│   │   │   ├── library/page.tsx
│   │   │   ├── playlist/[id]/page.tsx
│   │   │   ├── song/[id]/page.tsx
│   │   │   ├── queue/page.tsx
│   │   │   ├── category/[slug]/page.tsx
│   │   │   ├── profile/page.tsx
│   │   │   ├── settings/page.tsx
│   │   │   └── layout.tsx
│   │   ├── (player)/                 # Player layout (fullscreen)
│   │   │   ├── play/[id]/page.tsx
│   │   │   └── layout.tsx
│   │   ├── admin/
│   │   │   ├── page.tsx
│   │   │   ├── users/page.tsx
│   │   │   ├── reports/page.tsx
│   │   │   ├── lyrics/page.tsx
│   │   │   └── layout.tsx
│   │   ├── page.tsx                  # Landing
│   │   ├── layout.tsx                # Root layout
│   │   ├── globals.css
│   │   └── not-found.tsx
│   ├── components/
│   │   ├── ui/                       # shadcn/ui primitives
│   │   ├── layout/
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Topbar.tsx
│   │   │   ├── MiniPlayer.tsx
│   │   │   └── AdminSidebar.tsx
│   │   ├── songs/
│   │   │   ├── SongCard.tsx
│   │   │   ├── SongList.tsx
│   │   │   ├── SongRow.tsx
│   │   │   └── SongActions.tsx
│   │   ├── player/
│   │   │   ├── YouTubePlayer.tsx
│   │   │   ├── PlayerControls.tsx
│   │   │   ├── LyricsHighlight.tsx
│   │   │   ├── QueueSidebar.tsx
│   │   │   └── PlayerToolbar.tsx
│   │   ├── playlists/
│   │   ├── search/
│   │   ├── auth/
│   │   └── common/
│   │       ├── Logo.tsx
│   │       ├── EmptyState.tsx
│   │       ├── LoadingSkeleton.tsx
│   │       └── ErrorBoundary.tsx
│   ├── lib/
│   │   ├── utils.ts                  # cn(), formatDuration...
│   │   ├── constants.ts
│   │   └── lrc-parser.ts             # Parse file .lrc
│   ├── hooks/
│   │   ├── usePlayer.ts
│   │   ├── useLyrics.ts
│   │   └── useDebounce.ts
│   ├── stores/                       # Zustand stores
│   │   ├── player.store.ts
│   │   ├── queue.store.ts
│   │   └── user.store.ts
│   ├── types/
│   │   ├── song.ts
│   │   ├── user.ts
│   │   └── playlist.ts
│   ├── mocks/                        # Mock data (giai đoạn này)
│   │   ├── songs.ts
│   │   ├── users.ts
│   │   ├── playlists.ts
│   │   └── lyrics.ts
│   └── services/                     # API service (chuẩn bị cho ghép API)
│       └── (sẽ thêm sau)
├── tailwind.config.ts
├── next.config.mjs
├── package.json
└── tsconfig.json
```

---

## 7. ROADMAP BUILD UI

### Tuần 1: Setup + Design System
- [ ] Init Next.js + Tailwind + shadcn
- [ ] Setup theme (dark mode)
- [ ] Component primitives: Button, Input, Card, Dialog...
- [ ] Layout: Sidebar + Topbar + MiniPlayer
- [ ] Mock data setup

### Tuần 2: Public Pages + Auth
- [ ] Landing page
- [ ] Login / Register / Forgot password
- [ ] 404 / Error pages

### Tuần 3: Core App Pages
- [ ] Home / Discover
- [ ] Search + filters
- [ ] Song Detail
- [ ] My Library (4 tabs)
- [ ] Playlist Detail
- [ ] Queue

### Tuần 4: Player Page ⭐
- [ ] Layout player + queue sidebar
- [ ] YouTube IFrame integration (mock video)
- [ ] Lyrics highlight component (parse LRC + sync)
- [ ] Player controls
- [ ] TV mode (fullscreen)
- [ ] Toolbar phát

### Tuần 5: Profile + Settings + Admin
- [ ] Profile page
- [ ] Settings (7 tabs)
- [ ] Admin dashboard
- [ ] Admin: Users / Reports / Lyrics

### Tuần 6: Polish
- [ ] Responsive mobile
- [ ] Animations (framer-motion)
- [ ] Loading states + skeletons
- [ ] Empty states + error states
- [ ] Accessibility (a11y)
- [ ] SEO meta tags

---

## 8. MOCK DATA STRATEGY

Trong giai đoạn này dùng mock data trong `src/mocks/`:
- `songs.ts`: 50 bài Vpop, Bolero, USUK
- `users.ts`: 5 user mẫu (admin + 4 user)
- `playlists.ts`: 10 playlist mẫu
- `lyrics.ts`: 10 file LRC mẫu (sync chuẩn)
- `categories.ts`: 12 thể loại

Khi ghép API, chỉ cần thay `mocks/` bằng `services/` gọi backend.

---

## 9. RESPONSIVE BREAKPOINTS

| Breakpoint | Width | Devices |
|-----------|-------|---------|
| `sm` | 640px | Mobile landscape |
| `md` | 768px | Tablet |
| `lg` | 1024px | Laptop |
| `xl` | 1280px | Desktop |
| `2xl` | 1536px | Large desktop |
| `tv` | 1920px+ | Smart TV (custom) |

**Layout adapt:**
- Mobile (< 768px): Sidebar → bottom tab, MiniPlayer → fullscreen tap
- Tablet (768-1024): Sidebar collapsed, content full
- Desktop (>= 1024): Sidebar expanded + content + (optional) right panel
- TV: Font lớn 1.5x, control hover only

---

## 10. ACCESSIBILITY (a11y)

- Keyboard navigation đầy đủ (Tab, Enter, Esc, Arrows)
- ARIA labels cho tất cả buttons
- Focus visible
- Color contrast >= AA
- Screen reader friendly cho lyrics
- Phím tắt:
  - `Space`: Play/Pause
  - `←/→`: Tua -10s/+10s
  - `↑/↓`: Volume
  - `M`: Mute
  - `F`: Fullscreen
  - `L`: Toggle lyrics
  - `/`: Focus search

---

## 11. TIÊU CHÍ HOÀN THÀNH

- [ ] Tất cả 29 trang đã có UI
- [ ] Responsive đủ 4 breakpoint
- [ ] Dark/Light mode hoạt động
- [ ] Mock data đầy đủ, demo được flow
- [ ] Loading + empty + error state
- [ ] Animations mượt
- [ ] Lighthouse score > 90 (Performance, Accessibility, Best Practices, SEO)

---

**Ngày tạo**: 2026-05-14
**Phiên bản**: 1.0
