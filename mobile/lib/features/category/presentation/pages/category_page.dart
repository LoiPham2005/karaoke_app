import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_base/shared/mocks/mock_categories.dart';
import 'package:flutter_base/shared/mocks/mock_songs.dart';
import 'package:flutter_base/shared/widgets/song_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final cat = mockCategories.firstWhere(
      (c) => c.slug == slug,
      orElse: () => mockCategories.first,
    );
    final songs =
        mockSongs.where((s) => s.category == cat.slug).toList();
    final list = songs.isEmpty ? mockSongs : songs;

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
                cat.name,
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
                  child: Text(cat.emoji, style: TextStyle(fontSize: 80.sp)),
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
                    '${cat.songCount} bài',
                    style: TextStyle(color: context.textSub, fontSize: 12.sp),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 36.r,
                    child: ElevatedButton.icon(
                      onPressed: () {},
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
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.r,
                crossAxisSpacing: 12.r,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => SongCard(
                  song: list[i],
                  onTap: () => context.push('/song/${list[i].youtubeId}'),
                ),
                childCount: list.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.r)),
        ],
      ),
    );
  }
}
