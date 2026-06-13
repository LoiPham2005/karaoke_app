import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_categories.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/utils/format_utils.dart';
import 'package:karaoke/shared/widgets/category_card.dart';
import 'package:karaoke/shared/widgets/karaoke_logo.dart';
import 'package:karaoke/shared/widgets/section_header.dart';
import 'package:karaoke/shared/widgets/song_card.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hero = mockSongs.first;
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
                      icon: Icon(Icons.notifications_outlined, color: context.textBody),
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
                  onTap: () => context.router.push(PlayerRoute(id: hero.youtubeId)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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
                                    borderRadius:
                                        BorderRadius.circular(AppDimensions.circle),
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
                onSeeAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200.r,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  itemCount: trendingSongs.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.r),
                  itemBuilder: (_, i) => SongCard(
                    song: trendingSongs[i],
                    width: 160.r,
                    onTap: () => context.router.push(SongDetailRoute(id: trendingSongs[i].youtubeId)),
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
                    onTap: () => context.router.push(CategoryRoute(slug: mockCategories[i].slug)),
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
                onSeeAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200.r,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  itemCount: recommendedSongs.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.r),
                  itemBuilder: (_, i) => SongCard(
                    song: recommendedSongs[i],
                    width: 160.r,
                    onTap: () => context.router.push(SongDetailRoute(id: recommendedSongs[i].youtubeId)),
                  ),
                ),
              ),
            ),

            // ─── Top charts ─────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: '🏆 Top tuần này',
                subtitle: 'Bài được hát nhiều nhất',
                onSeeAll: () {},
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SongTile(
                    song: trendingSongs[i],
                    index: i + 1,
                    onTap: () => context.router.push(SongDetailRoute(id: trendingSongs[i].youtubeId)),
                  ),
                  childCount: 5,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.r)),
          ],
        ),
      ),
    );
  }
}
