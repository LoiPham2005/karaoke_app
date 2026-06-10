# 🎤 KẾ HOẠCH XÂY DỰNG ỨNG DỤNG KARAOKE

> **Mô hình**: App karaoke kiểu "YouTube wrapper" — search bài từ YouTube + lyrics đồng bộ từ LRCLIB, người dùng hát qua trình duyệt/mobile.

---

## 1. TỔNG QUAN DỰ ÁN

### 1.1. Mục tiêu
Xây dựng app karaoke miễn phí cho người dùng cá nhân/gia đình, với kho nhạc "vô hạn" thông qua YouTube, có lyrics đồng bộ, playlist, lịch sử, và các tính năng social cơ bản.

### 1.2. Đối tượng người dùng
- **Primary**: Người dùng cá nhân muốn hát karaoke tại nhà
- **Secondary**: Nhóm bạn bè, gia đình hát chung qua TV/máy chiếu
- **Tương lai**: Quán karaoke mini, phòng hát di động

### 1.3. Nền tảng triển khai
- **Giai đoạn 1**: Web app (responsive — chạy được trên PC, mobile, smart TV browser)
- **Giai đoạn 2**: Mobile app (Flutter)
- **Giai đoạn 3**: Desktop app (Electron) cho quán

### 1.4. Mô hình kinh doanh (tham khảo)
- Free tier: Có quảng cáo, giới hạn 50 bài/ngày
- Premium: 30-50k VND/tháng — bỏ quảng cáo, không giới hạn, chấm điểm AI, recording

---

## 2. STACK CÔNG NGHỆ

### 2.1. Backend
| Thành phần | Công nghệ | Lý do chọn |
|-----------|-----------|------------|
| Framework | **NestJS** (TypeScript) | Cấu trúc rõ ràng, dễ scale, đồng bộ type với FE |
| ORM | **Prisma** | Type-safe, migration tự động, DX tốt nhất hiện tại |
| Database | **PostgreSQL** | Mạnh, ổn định, free, hỗ trợ JSON, full-text search |
| Cache | **Redis** | Cache search YouTube, session, queue |
| Auth | **JWT + Passport.js** | Chuẩn industry, dễ tích hợp |
| Realtime | **Socket.IO** (built-in NestJS Gateway) | Sync queue, hát chung phòng |
| API Doc | **Swagger** (auto từ NestJS) | Tự sinh từ decorator |
| Validation | **class-validator + class-transformer** | Chuẩn NestJS |
| Queue Job | **BullMQ** | Xử lý task nền (gửi email, sync data) |

### 2.2. Frontend (giai đoạn 2)
| Thành phần | Công nghệ |
|-----------|-----------|
| Framework | Next.js 14+ (App Router) |
| Styling | TailwindCSS + shadcn/ui |
| State | Zustand hoặc TanStack Query |
| Player | YouTube IFrame API |
| Lyrics | react-lrc hoặc tự build |

### 2.3. External APIs
| API | Mục đích | Free tier |
|-----|----------|-----------|
| **YouTube Data API v3** | Search bài, lấy metadata | 10,000 quota/ngày |
| **LRCLIB API** | Lấy lyrics đồng bộ (.lrc) | Không giới hạn |
| **Musixmatch API** | Fallback lyrics | 2,000 call/ngày |
| **Google OAuth** | Đăng nhập | Free |

### 2.4. DevOps & Hosting
| Mục | Công cụ |
|-----|---------|
| Version control | Git + GitHub |
| CI/CD | GitHub Actions |
| Backend hosting | Railway / Render / Fly.io (free tier) |
| Database hosting | Supabase / Neon (PostgreSQL free) |
| Redis hosting | Upstash (free 10k commands/day) |
| Frontend hosting | Vercel (free) |
| Monitoring | Sentry (error) + Better Uptime |

---

## 3. KIẾN TRÚC HỆ THỐNG

```
┌──────────────────────────────────────────────────────────┐
│                      CLIENT LAYER                         │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│   │  Web App    │  │ Mobile App  │  │  Smart TV   │    │
│   │ (Next.js)   │  │  (Flutter)  │  │  (Browser)  │    │
│   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
└──────────┼─────────────────┼─────────────────┼──────────┘
           │ HTTPS/WSS       │                 │
           └─────────┬───────┴─────────────────┘
                     │
┌────────────────────▼──────────────────────────────────┐
│              API GATEWAY (NestJS)                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐  │
│  │   Auth   │ │  Songs   │ │ Playlist │ │  Queue  │  │
│  │  Module  │ │  Module  │ │  Module  │ │ Module  │  │
│  └──────────┘ └──────────┘ └──────────┘ └─────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐  │
│  │  Users   │ │  Lyrics  │ │  Social  │ │WebSocket│  │
│  │  Module  │ │  Module  │ │  Module  │ │ Gateway │  │
│  └──────────┘ └──────────┘ └──────────┘ └─────────┘  │
└─────┬──────────────┬──────────────┬────────────────────┘
      │              │              │
      ▼              ▼              ▼
┌──────────┐  ┌──────────┐  ┌─────────────────┐
│PostgreSQL│  │  Redis   │  │ External APIs   │
│ (Prisma) │  │  Cache   │  │ YouTube/LRCLIB  │
└──────────┘  └──────────┘  └─────────────────┘
```

---

## 4. DANH SÁCH CHỨC NĂNG (FEATURES)

### 4.1. 🔐 Authentication & User
- [x] Đăng ký bằng email/password
- [x] Đăng nhập email/password
- [x] Đăng nhập Google OAuth
- [x] Quên mật khẩu (gửi email reset)
- [x] Xác thực email (OTP)
- [x] Refresh token / Logout
- [x] Profile: avatar, tên, bio
- [x] Đổi mật khẩu
- [x] Xóa tài khoản (GDPR)

### 4.2. 🎵 Song Search & Discovery
- [x] Search bài hát qua YouTube API
- [x] Filter: karaoke, beat, có lời, không lời
- [x] Autocomplete khi gõ
- [x] Trending bài hát (theo lượt phát trong app)
- [x] Đề xuất theo lịch sử
- [x] Đề xuất theo thể loại (Bolero, Vpop, Nhạc trẻ, EDM...)
- [x] Top bài hot trong tuần/tháng
- [x] Tìm theo ca sĩ
- [x] Cache kết quả search trong Redis (giảm gọi YouTube API)

### 4.3. ▶️ Player & Playback
- [x] Phát video YouTube embed
- [x] Phát toàn màn hình
- [x] Điều khiển: play/pause, tua, volume
- [x] Tự động phát bài tiếp theo trong queue
- [x] Loop bài hiện tại / shuffle
- [x] Báo cáo bài lỗi (video bị gỡ, sai key)

### 4.4. 📝 Lyrics đồng bộ (Karaoke effect)
- [x] Lấy LRC từ LRCLIB API
- [x] Parse file LRC thành timeline
- [x] Highlight dòng đang hát (chuyển màu)
- [x] Highlight từng chữ trong dòng (word-by-word nếu có enhanced LRC)
- [x] Hiển thị lyrics overlay trên video
- [x] Toggle bật/tắt lyrics
- [x] Tùy chỉnh font size, màu chữ
- [x] Nếu không có LRC: hiển thị "Đang cập nhật lời"
- [x] User contribute lyrics (community-driven)

### 4.5. 📋 Playlist & Queue
- [x] Tạo playlist cá nhân
- [x] Thêm/xóa bài khỏi playlist
- [x] Sắp xếp thứ tự bài trong playlist
- [x] Playlist công khai/riêng tư
- [x] Share playlist qua link
- [x] **Queue (hàng chờ)**: thêm bài để hát tiếp
- [x] Reorder queue
- [x] Clear queue
- [x] Lưu queue theo session

### 4.6. ❤️ User Actions
- [x] Yêu thích bài hát
- [x] Lịch sử bài đã hát
- [x] Đánh dấu bài hay nhất (rate 1-5 sao)
- [x] Báo cáo bài lỗi/không phù hợp
- [x] Đóng góp lyrics

### 4.7. 👥 Social Features (Giai đoạn 2)
- [ ] Follow user khác
- [ ] Newsfeed: bạn bè đang hát gì
- [ ] Share bản thu lên app (như Smule)
- [ ] Comment, like bản thu
- [ ] Duet/song ca với bạn bè
- [ ] Phòng hát chung realtime (room code)

### 4.8. 🎙️ Recording & AI (Giai đoạn 3)
- [ ] Ghi âm giọng hát (Web Audio API)
- [ ] Mix giọng hát + beat (server-side với FFmpeg)
- [ ] Tải về file mp3/mp4
- [ ] **Chấm điểm AI** (pitch detection bằng Python service)
- [ ] So sánh giọng với ca sĩ gốc
- [ ] Auto-tune giọng hát (vui)
- [ ] Voice effect: echo, reverb, robot

### 4.9. ⚙️ Admin Panel
- [x] Dashboard: tổng user, bài hát phát, lượt hát
- [x] Quản lý user (ban, xóa, đổi role)
- [x] Quản lý báo cáo bài lỗi
- [x] Duyệt lyrics user đóng góp
- [x] Quản lý quảng cáo
- [x] Cấu hình system (rate limit, feature flag)

### 4.10. 💰 Monetization (Giai đoạn 4)
- [ ] Quảng cáo banner (Google AdSense)
- [ ] Quảng cáo video pre-roll
- [ ] Premium subscription (VNPay, Momo, Stripe)
- [ ] Gift coin cho user khác
- [ ] Mua hiệu ứng giọng đặc biệt

---

## 5. DATABASE SCHEMA (Prisma)

### 5.1. Bảng chính

```prisma
// User & Auth
model User {
  id              String   @id @default(uuid())
  email           String   @unique
  passwordHash    String?
  googleId        String?  @unique
  displayName     String
  avatarUrl       String?
  bio             String?
  role            Role     @default(USER)
  isEmailVerified Boolean  @default(false)
  isPremium       Boolean  @default(false)
  premiumUntil    DateTime?
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  playlists       Playlist[]
  favorites       Favorite[]
  history         History[]
  queueItems      QueueItem[]
  contributions   LyricsContribution[]
  reports         SongReport[]
  refreshTokens   RefreshToken[]
}

enum Role {
  USER
  MODERATOR
  ADMIN
}

model RefreshToken {
  id        String   @id @default(uuid())
  userId    String
  token     String   @unique
  expiresAt DateTime
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}

// Songs cache (giảm gọi YouTube API)
model Song {
  youtubeId    String   @id
  title        String
  artist       String?
  thumbnailUrl String?
  duration     Int      // seconds
  viewCount    Int      @default(0)
  hasLyrics    Boolean  @default(false)
  isKaraoke    Boolean  @default(true)
  category     String?  // Vpop, Bolero, USUK...
  cachedAt     DateTime @default(now())
  lastCheckedAt DateTime @default(now())

  lyrics       Lyrics?
  favorites    Favorite[]
  history      History[]
  playlistItems PlaylistItem[]
  reports      SongReport[]

  @@index([title])
  @@index([artist])
  @@index([category])
}

// Lyrics
model Lyrics {
  id           String   @id @default(uuid())
  songId       String   @unique
  lrcContent   String   @db.Text  // raw LRC format
  source       String   // 'lrclib', 'musixmatch', 'user'
  language     String?  // 'vi', 'en'
  isVerified   Boolean  @default(false)
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  song         Song     @relation(fields: [songId], references: [youtubeId], onDelete: Cascade)
  contributions LyricsContribution[]
}

model LyricsContribution {
  id         String   @id @default(uuid())
  userId     String
  lyricsId   String
  content    String   @db.Text
  status     ContribStatus @default(PENDING)
  createdAt  DateTime @default(now())

  user       User     @relation(fields: [userId], references: [id])
  lyrics     Lyrics   @relation(fields: [lyricsId], references: [id])
}

enum ContribStatus {
  PENDING
  APPROVED
  REJECTED
}

// Playlist
model Playlist {
  id          String   @id @default(uuid())
  userId      String
  name        String
  description String?
  isPublic    Boolean  @default(false)
  coverUrl    String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  items       PlaylistItem[]
}

model PlaylistItem {
  id         String   @id @default(uuid())
  playlistId String
  songId     String
  position   Int
  addedAt    DateTime @default(now())

  playlist   Playlist @relation(fields: [playlistId], references: [id], onDelete: Cascade)
  song       Song     @relation(fields: [songId], references: [youtubeId])

  @@unique([playlistId, songId])
  @@index([playlistId, position])
}

// Queue (hàng chờ phát)
model QueueItem {
  id        String   @id @default(uuid())
  userId    String
  songId    String
  position  Int
  addedAt   DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, position])
}

// Favorite
model Favorite {
  id        String   @id @default(uuid())
  userId    String
  songId    String
  createdAt DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  song      Song     @relation(fields: [songId], references: [youtubeId])

  @@unique([userId, songId])
}

// History
model History {
  id        String   @id @default(uuid())
  userId    String
  songId    String
  playedAt  DateTime @default(now())
  duration  Int?     // số giây user hát thực tế

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  song      Song     @relation(fields: [songId], references: [youtubeId])

  @@index([userId, playedAt])
}

// Report bài lỗi
model SongReport {
  id        String   @id @default(uuid())
  userId    String
  songId    String
  reason    String
  status    ReportStatus @default(PENDING)
  createdAt DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id])
  song      Song     @relation(fields: [songId], references: [youtubeId])
}

enum ReportStatus {
  PENDING
  RESOLVED
  REJECTED
}
```

### 5.2. Bảng cho giai đoạn sau

```prisma
// Room (hát chung realtime) — Phase 2
model Room {
  id        String   @id @default(uuid())
  code      String   @unique  // 6 ký tự random
  hostId    String
  name      String?
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
}

// Recording — Phase 3
model Recording {
  id         String   @id @default(uuid())
  userId     String
  songId     String
  audioUrl   String   // S3/R2 URL
  score      Float?   // điểm AI chấm
  isPublic   Boolean  @default(false)
  createdAt  DateTime @default(now())
}

// Subscription — Phase 4
model Subscription {
  id        String   @id @default(uuid())
  userId    String
  plan      String   // 'monthly', 'yearly'
  status    String   // 'active', 'cancelled', 'expired'
  startAt   DateTime
  endAt     DateTime
  amount    Int
  provider  String   // 'vnpay', 'momo', 'stripe'
}
```

---

## 6. CẤU TRÚC THƯ MỤC PROJECT (NestJS)

```
karaoke-backend/
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── common/
│   │   ├── decorators/        # @CurrentUser, @Roles
│   │   ├── guards/            # JwtAuthGuard, RolesGuard
│   │   ├── filters/           # HttpExceptionFilter
│   │   ├── interceptors/      # TransformInterceptor
│   │   ├── pipes/             # ValidationPipe
│   │   └── utils/
│   ├── config/
│   │   ├── configuration.ts
│   │   └── env.validation.ts
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── strategies/
│   │   │   │   ├── jwt.strategy.ts
│   │   │   │   └── google.strategy.ts
│   │   │   └── dto/
│   │   ├── users/
│   │   ├── songs/
│   │   │   ├── songs.controller.ts
│   │   │   ├── songs.service.ts
│   │   │   ├── youtube.service.ts
│   │   │   └── dto/
│   │   ├── lyrics/
│   │   │   ├── lyrics.service.ts
│   │   │   └── lrclib.service.ts
│   │   ├── playlists/
│   │   ├── queue/
│   │   ├── favorites/
│   │   ├── history/
│   │   ├── reports/
│   │   └── admin/
│   ├── prisma/
│   │   ├── prisma.module.ts
│   │   └── prisma.service.ts
│   ├── redis/
│   │   ├── redis.module.ts
│   │   └── redis.service.ts
│   └── websocket/
│       └── queue.gateway.ts
├── test/
├── .env.example
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── package.json
├── tsconfig.json
└── README.md
```

---

## 7. API ENDPOINTS (REST)

### 7.1. Auth
```
POST   /auth/register              - Đăng ký
POST   /auth/login                 - Đăng nhập
POST   /auth/google                - Login Google
POST   /auth/refresh               - Refresh access token
POST   /auth/logout                - Đăng xuất
POST   /auth/forgot-password       - Quên mật khẩu
POST   /auth/reset-password        - Reset mật khẩu
POST   /auth/verify-email          - Xác thực email
```

### 7.2. Users
```
GET    /users/me                   - Thông tin user hiện tại
PATCH  /users/me                   - Cập nhật profile
POST   /users/me/avatar            - Upload avatar
PATCH  /users/me/password          - Đổi mật khẩu
DELETE /users/me                   - Xóa tài khoản
```

### 7.3. Songs
```
GET    /songs/search?q=&filter=    - Search YouTube
GET    /songs/:youtubeId           - Chi tiết bài
GET    /songs/trending             - Bài trending trong app
GET    /songs/recommendations      - Gợi ý theo lịch sử user
GET    /songs/category/:name       - Bài theo category
POST   /songs/:id/report           - Báo bài lỗi
```

### 7.4. Lyrics
```
GET    /lyrics/:songId             - Lấy LRC
POST   /lyrics/:songId/contribute  - User đóng góp lyrics
```

### 7.5. Playlists
```
GET    /playlists                  - DS playlist của user
POST   /playlists                  - Tạo mới
GET    /playlists/:id              - Chi tiết playlist
PATCH  /playlists/:id              - Update info
DELETE /playlists/:id              - Xóa
POST   /playlists/:id/songs        - Thêm bài
DELETE /playlists/:id/songs/:sid   - Xóa bài
PATCH  /playlists/:id/reorder      - Sắp xếp
```

### 7.6. Queue (hàng chờ phát)
```
GET    /queue                      - Hàng chờ hiện tại
POST   /queue                      - Thêm bài
DELETE /queue/:id                  - Xóa bài khỏi queue
DELETE /queue                      - Clear toàn bộ
PATCH  /queue/reorder              - Sắp xếp lại
```

### 7.7. Favorites
```
GET    /favorites                  - DS yêu thích
POST   /favorites/:songId          - Thêm yêu thích
DELETE /favorites/:songId          - Bỏ yêu thích
```

### 7.8. History
```
GET    /history                    - Lịch sử phát
POST   /history                    - Ghi lại 1 lần hát
DELETE /history                    - Xóa toàn bộ lịch sử
```

### 7.9. Admin
```
GET    /admin/stats                - Dashboard
GET    /admin/users                - DS user
PATCH  /admin/users/:id            - Update user
GET    /admin/reports              - DS báo cáo
PATCH  /admin/reports/:id          - Xử lý báo cáo
GET    /admin/contributions        - Duyệt lyrics đóng góp
```

### 7.10. WebSocket Events
```
queue:add          - Thêm bài vào queue
queue:remove       - Xóa khỏi queue
queue:reorder      - Sắp xếp
playback:state     - Sync trạng thái phát
room:join          - Vào phòng hát chung
room:leave         - Rời phòng
```

---

## 8. ROADMAP TRIỂN KHAI

### 🎯 Phase 1: MVP Backend (4-6 tuần)

**Tuần 1: Setup & Foundation**
- [ ] Khởi tạo project NestJS + Prisma
- [ ] Setup PostgreSQL local + Docker Compose
- [ ] Cấu hình env, config module
- [ ] Setup Prisma schema cơ bản (User, Song, Lyrics)
- [ ] Migration đầu tiên
- [ ] Setup Swagger
- [ ] Setup Jest cho test

**Tuần 2: Auth Module**
- [ ] Register/Login email-password
- [ ] JWT access + refresh token
- [ ] Google OAuth
- [ ] Email verification (Mailtrap dev)
- [ ] Guard, decorator @CurrentUser
- [ ] Unit test auth service

**Tuần 3: Songs & YouTube Integration**
- [ ] YouTube Data API service
- [ ] Cache search result Redis
- [ ] Endpoint search/detail bài hát
- [ ] LRCLIB integration cho lyrics
- [ ] Songs DB cache logic
- [ ] Trending bài (cron job đếm play)

**Tuần 4: Playlist + Favorite + History**
- [ ] Playlist CRUD + reorder
- [ ] Favorite toggle
- [ ] History tracking
- [ ] Queue management

**Tuần 5: Polish & Testing**
- [ ] Validation chặt cho tất cả DTO
- [ ] Exception filter, response interceptor
- [ ] Rate limiting (per user, per IP)
- [ ] Logging (Winston / Pino)
- [ ] Integration test các flow chính
- [ ] API documentation đầy đủ

**Tuần 6: Deploy & Monitoring**
- [ ] Dockerize backend
- [ ] Setup Railway/Render
- [ ] Setup Neon/Supabase cho Postgres
- [ ] Setup Upstash Redis
- [ ] Setup Sentry error tracking
- [ ] CI/CD GitHub Actions

### 🎯 Phase 2: Frontend Web + Realtime (4-6 tuần)
- [ ] Next.js setup + auth flow
- [ ] Search & player page
- [ ] Lyrics highlight component
- [ ] Playlist + queue UI
- [ ] WebSocket sync queue
- [ ] Phòng hát chung (room code)
- [ ] Deploy Vercel

### 🎯 Phase 3: Mobile + Social (8 tuần)
- [ ] Flutter
- [ ] Core features parity với web
- [ ] Follow, newsfeed
- [ ] Share bản thu
- [ ] Recording (Web Audio API)

### 🎯 Phase 4: AI & Monetization (8-12 tuần)
- [ ] Python microservice cho AI scoring
- [ ] Pitch detection (librosa/pytorch)
- [ ] So sánh giọng với gốc
- [ ] Tích hợp VNPay/Momo
- [ ] Premium subscription
- [ ] Admin panel hoàn chỉnh

---

## 9. ƯỚC LƯỢNG TÀI NGUYÊN

### 9.1. Chi phí hạ tầng (giai đoạn MVP)
| Mục | Free tier | Trả phí (khi cần scale) |
|-----|-----------|-------------------------|
| Backend hosting | Railway $5 credit/tháng | $5-20/tháng |
| PostgreSQL | Neon free 0.5GB | $19/tháng (10GB) |
| Redis | Upstash free 10k/day | $10/tháng |
| Frontend | Vercel free | $20/tháng |
| Domain | ~250k VND/năm | - |
| **Tổng** | **~250k/năm** | **~1.5tr VND/tháng** |

### 9.2. Quota giới hạn cần lưu ý
- **YouTube API**: 10,000 unit/ngày (mỗi search = 100 unit → 100 search/ngày). Khi scale cần xin tăng quota hoặc rotate nhiều key.
- **LRCLIB**: Không giới hạn cứng nhưng nên cache aggressive.

### 9.3. Nhân lực
- **MVP**: 1 fullstack dev — 4-6 tuần
- **Production scale**: 2 BE + 2 FE + 1 designer + 1 QA — 3-6 tháng

---

## 10. RỦI RO & GIẢI PHÁP

| Rủi ro | Mức độ | Giải pháp |
|--------|--------|-----------|
| YouTube đổi ToS, cấm app karaoke | Cao | Đa dạng nguồn (SoundCloud, Vimeo), không tải về |
| Hết quota YouTube API | Trung bình | Cache aggressive, rotate nhiều API key, premium quota |
| Vấn đề bản quyền nhạc | Cao | Chỉ embed, không download. Disclaimer rõ ràng |
| Video bị gỡ → bài lỗi | Trung bình | Cron job check link, replace tự động |
| Chi phí scale lên cao | Trung bình | Monetize sớm, optimize cache, CDN |
| Cạnh tranh từ app lớn | Trung bình | Tập trung ngách (VN, gia đình, AI scoring) |

---

## 11. TIÊU CHÍ THÀNH CÔNG (KPI)

### MVP (3 tháng)
- 100 user đăng ký
- 50 DAU
- 10 bài/user/tuần
- Uptime > 99%
- < 500ms API response time

### Năm 1
- 10,000 user
- 1,000 DAU
- 100 premium user (~ 5tr VND/tháng revenue)

---

## 12. BƯỚC TIẾP THEO

1. ✅ Tạo file kế hoạch này
2. ⏭️ **Init project NestJS + Prisma** (sẽ làm tiếp)
3. ⏭️ Setup database schema cơ bản
4. ⏭️ Build module Auth đầu tiên
5. ⏭️ Test với Postman/Swagger

---

**Ngày tạo**: 2026-05-14
**Phiên bản**: 1.0
**Tác giả**: Karaoke App Team
