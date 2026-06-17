import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/features/songs/data/services/songs_service.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_detail_providers.g.dart';

/// FutureProvider-family: chi tiết 1 bài theo [id] (`GET /songs/:id`). Public.
/// Lỗi (404 / id không tồn tại) → throw → UI hiển thị trạng thái lỗi.
@riverpod
Future<SongModel> songDetail(Ref ref, String id) async {
  final service = SongsService(ref.read(dioProvider));
  final res = await service.detail(id);
  final data = res.data;
  if (data == null) {
    throw Exception('Không tìm thấy bài hát');
  }
  return data;
}

/// FutureProvider-family: bài tương tự theo [id] (`GET /songs/:id/similar`).
/// Public. Rỗng = chưa có bài tương tự.
@riverpod
Future<List<SongModel>> similarSongs(Ref ref, String id) async {
  final service = SongsService(ref.read(dioProvider));
  final res = await service.similar(id);
  return res.data ?? const [];
}

/// FutureProvider-family: tìm bài theo [query] (`GET /songs/search`). Public.
/// `keepAlive` → cache theo query suốt phiên (đỡ tốn quota YouTube khi
/// dùng cho "Đề xuất" / trang Thể loại — mỗi search tốn ~100 quota).
@Riverpod(keepAlive: true)
Future<List<SongModel>> songSearch(Ref ref, String query) async {
  final service = SongsService(ref.read(dioProvider));
  final res = await service.search(query, 20);
  return res.data ?? const [];
}
