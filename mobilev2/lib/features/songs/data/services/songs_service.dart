import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/songs/data/models/lyrics_response.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:retrofit/retrofit.dart';

part 'songs_service.g.dart';

/// Retrofit service cho SONGS (public, không cần Bearer).
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/songs/...`.
/// Response backend bọc `{ statusCode, message, data }` → map sang `ApiResponse<T>`.
@RestApi()
abstract class SongsService {
  factory SongsService(Dio dio) = _SongsService;

  /// `GET /songs/search?q=&maxResults=` → `data Song[]` (tìm từ YouTube).
  @GET('/songs/search')
  Future<ApiResponse<List<SongModel>>> search(
    @Query('q') String q,
    @Query('maxResults') int? maxResults,
  );

  /// `GET /songs/trending` → `data Song[]`.
  @GET('/songs/trending')
  Future<ApiResponse<List<SongModel>>> trending();

  /// `GET /songs/recent` → `data Song[]` (bài mới thêm hệ thống).
  @GET('/songs/recent')
  Future<ApiResponse<List<SongModel>>> recent();

  /// `GET /songs/{youtubeId}` → `data Song`.
  @GET('/songs/{youtubeId}')
  Future<ApiResponse<SongModel>> detail(@Path('youtubeId') String youtubeId);

  /// `GET /songs/{youtubeId}/similar` → `data Song[]` (bài tương tự).
  @GET('/songs/{youtubeId}/similar')
  Future<ApiResponse<List<SongModel>>> similar(
    @Path('youtubeId') String youtubeId,
  );

  /// `GET /lyrics?youtubeId=&title=&artist=&duration=` → `data { lrcContent, source, language }`.
  @GET('/lyrics')
  Future<ApiResponse<LyricsResponse>> getLyrics(
    @Query('youtubeId') String? youtubeId,
    @Query('title') String title,
    @Query('artist') String? artist,
    @Query('duration') int? duration,
  );
}
