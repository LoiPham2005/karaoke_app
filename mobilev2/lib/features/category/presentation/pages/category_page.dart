import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/song/presentation/providers/song_detail_providers.dart';
import 'package:karaoke/features/songs/presentation/providers/trending_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_categories.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/widgets/song_card.dart';

@RoutePage()
class CategoryPage extends ConsumerWidget {
  const CategoryPage({@PathParam('slug') required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTrending = slug == 'trending';
    final cat = mockCategories.firstWhere(
      (c) => c.slug == slug,
      orElse: () => mockCategories.first,
    );
    final title = isTrending ? 'Đang trending' : cat.name;

    // Trending → trendingProvider (DB, free). Thể loại → search YouTube theo tên.
    final songsAsync = isTrending
        ? ref.watch(trendingProvider)
        : ref.watch(songSearchProvider(cat.name));
    final songs = songsAsync.value ?? const <SongModel>[];
    final loading = songsAsync.isLoading && songs.isEmpty;

    return Scaffold(
      backgroundColor: context.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.r,
            pinned: true,
            backgroundColor: cat.gradient.first,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cat.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    isTrending ? '🔥' : cat.emoji,
                    style: TextStyle(fontSize: 80.sp),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Text(
                    loading ? 'Đang tải...' : '${songs.length} bài',
                    style: TextStyle(color: context.textSub, fontSize: 12.sp),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 36.r,
                    child: ElevatedButton.icon(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                              final s = songs[Random().nextInt(songs.length)];
                              context.router.push(PlayerRoute(id: s.youtubeId));
                            },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(
                        'Phát ngẫu nhiên',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.brandPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.circle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (songs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Chưa có bài nào',
                  style: TextStyle(color: context.textSub, fontSize: 14.sp),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.r,
                  crossAxisSpacing: 12.r,
                  // Khít với card (thumbnail 16:9 + 3 dòng text) → bớt khoảng trống dọc.
                  childAspectRatio: 0.86,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SongCard(
                    song: songs[i],
                    onTap: () => context.router
                        .push(SongDetailRoute(id: songs[i].youtubeId)),
                  ),
                  childCount: songs.length,
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24.r)),
        ],
      ),
    );
  }
}
