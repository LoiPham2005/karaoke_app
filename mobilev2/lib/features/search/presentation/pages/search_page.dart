import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  String _filter = 'Tất cả';

  static const _filters = ['Tất cả', 'Karaoke', 'Có lời', 'Beat', 'Demo'];
  static const _recent = [
    'Hoa nở không màu',
    'Sơn Tùng',
    'Bolero buồn',
    'Despacito',
    'See you again',
  ];

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? <SongModel>[]
        : mockSongs.where(
            (s) =>
                s.title.toLowerCase().contains(_query.toLowerCase()) ||
                s.artist.toLowerCase().contains(_query.toLowerCase()),
          ).toList();

    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: TextField(
                controller: _controller,
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Tìm bài hát, ca sĩ...',
                  hintStyle: TextStyle(color: context.textSub),
                  prefixIcon: Icon(Icons.search, color: context.textSub),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.clear, color: context.textSub),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: context.bgInput,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Filter chips
            SizedBox(
              height: 36.r,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.r),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final active = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 6.r),
                      decoration: BoxDecoration(
                        color: active ? context.brandPrimary : context.bgInput,
                        borderRadius: BorderRadius.circular(AppDimensions.circle),
                      ),
                      child: Center(
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : context.textBody,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.r),
            Expanded(
              child: _query.isEmpty ? _buildRecent(context) : _buildResults(context, results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecent(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      children: [
        Row(
          children: [
            Icon(Icons.history, color: context.textSub, size: 16.r),
            SizedBox(width: 6.r),
            Text(
              'Tìm kiếm gần đây',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.textSub,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.r),
        Wrap(
          spacing: 8.r,
          runSpacing: 8.r,
          children: _recent
              .map(
                (q) => GestureDetector(
                  onTap: () {
                    _controller.text = q;
                    setState(() => _query = q);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                    decoration: BoxDecoration(
                      color: context.bgInput,
                      borderRadius: BorderRadius.circular(AppDimensions.circle),
                    ),
                    child: Text(
                      q,
                      style: TextStyle(fontSize: 13.sp, color: context.textBody),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, List<SongModel> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.r, color: context.textSub),
            SizedBox(height: 12.r),
            Text(
              'Không tìm thấy bài nào',
              style: TextStyle(color: context.textSub, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.r),
      itemCount: results.length,
      itemBuilder: (_, i) => SongTile(
        song: results[i],
        onTap: () => context.router.push(SongDetailRoute(id: results[i].youtubeId)),
      ),
    );
  }
}
