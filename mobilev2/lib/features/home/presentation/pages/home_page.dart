import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:karaoke/features/song/presentation/providers/song_detail_providers.dart';
import 'package:karaoke/features/songs/presentation/providers/recent_notifier.dart';
import 'package:karaoke/features/songs/presentation/providers/trending_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_categories.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/utils/format_utils.dart';
import 'package:karaoke/shared/widgets/category_card.dart';
import 'package:karaoke/shared/widgets/karaoke_logo.dart';
import 'package:karaoke/shared/widgets/section_header.dart';
import 'package:karaoke/shared/widgets/song_card.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trending lấy từ backend; trong lúc loading/lỗi fallback sang mock để giữ UI.
    final trending = ref.watch(trendingProvider).value ?? trendingSongs;
    final hero = trending.isNotEmpty ? trending.first : mockSongs.first;
    // "Đề xuất" lấy thật từ YouTube (search theo từ khoá gợi ý); lúc đang tải thì
    // tạm hiển thị trending để không bị trống.
    final recommendedReal = ref
        .watch(songSearchProvider('Nhạc Trẻ Việt hay nhất'))
        .value;
    final recommended = (recommendedReal == null || recommendedReal.isEmpty)
        ? trending
        : recommendedReal;
    // "Mới ra" lấy thật từ backend (bài mới thêm hệ thống). Rỗng/đang tải → ẩn
    // section (không fallback mock).
    final recent = ref.watch(recentProvider).value ?? const [];
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Topbar ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
                child: Row(
                  children: [
                    const KaraokeLogo(size: 28),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: context.textBody,
                      ),
                    ),
                    CircleAvatar(
                      radius: 18.r,
                      backgroundImage: const NetworkImage(
                        'https://i.pravatar.cc/200?img=1',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Hero banner ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                child: GestureDetector(
                  onTap: () =>
                      context.router.push(PlayerRoute(id: hero.youtubeId)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(hero.thumbnailUrl, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16.r,
                            right: 16.r,
                            bottom: 16.r,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.r,
                                    vertical: 3.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.brandPrimary,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.circle,
                                    ),
                                  ),
                                  child: Text(
                                    '🔥 ĐANG HOT',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.r),
                                Text(
                                  hero.title,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${hero.artist} • ${formatNumber(hero.viewCount)} lượt xem',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Trending ───────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: '🔥 Đang trending',
                subtitle: 'Top 10 bài hot nhất tuần này',
                onSeeAll: () =>
                    context.router.push(CategoryRoute(slug: 'trending')),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200.r,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  itemCount: trending.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.r),
                  itemBuilder: (_, i) => SongCard(
                    song: trending[i],
                    width: 160.r,
                    favoriteButton: FavoriteButton(
                      song: trending[i],
                      color: Colors.white,
                    ),
                    onTap: () => context.router.push(
                      SongDetailRoute(id: trending[i].youtubeId),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Categories ─────────────────────────────
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: '🎵 Thể loại',
                subtitle: 'Hát theo phong cách bạn thích',
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.r,
                  crossAxisSpacing: 12.r,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => CategoryCard(
                    category: mockCategories[i],
                    onTap: () => context.router.push(
                      CategoryRoute(slug: mockCategories[i].slug),
                    ),
                  ),
                  childCount: mockCategories.length,
                ),
              ),
            ),

            // ─── Recommended ────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: '✨ Đề xuất cho bạn',
                subtitle: 'Dựa trên lịch sử hát',
                onSeeAll: () =>
                    context.router.push(CategoryRoute(slug: 'nhactre')),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200.r,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  itemCount: recommended.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.r),
                  itemBuilder: (_, i) => SongCard(
                    song: recommended[i],
                    width: 160.r,
                    onTap: () => context.router.push(
                      SongDetailRoute(id: recommended[i].youtubeId),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Top charts ─────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: '🏆 Top tuần này',
                subtitle: 'Bài được hát nhiều nhất',
                onSeeAll: () =>
                    context.router.push(CategoryRoute(slug: 'trending')),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SongTile(
                    song: trending[i],
                    index: i + 1,
                    trailing: FavoriteButton(song: trending[i]),
                    onTap: () => context.router.push(
                      SongDetailRoute(id: trending[i].youtubeId),
                    ),
                  ),
                  childCount: trending.length < 5 ? trending.length : 5,
                ),
              ),
            ),

            // ─── Mới ra ─────────────────────────────────
            if (recent.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: '🆕 Mới ra',
                  subtitle: 'Bài mới thêm gần đây',
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200.r,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    itemCount: recent.length,
                    separatorBuilder: (_, _) => SizedBox(width: 12.r),
                    itemBuilder: (_, i) => SongCard(
                      song: recent[i],
                      width: 160.r,
                      favoriteButton: FavoriteButton(
                        song: recent[i],
                        color: Colors.white,
                      ),
                      onTap: () => context.router.push(
                        SongDetailRoute(id: recent[i].youtubeId),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(child: SizedBox(height: 24.r)),
          ],
        ),
      ),
    );
  }
}
