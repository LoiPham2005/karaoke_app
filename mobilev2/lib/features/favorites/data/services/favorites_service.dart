import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/favorites/data/models/favorite_model.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:retrofit/retrofit.dart';

part 'favorites_service.g.dart';

/// Retrofit service cho FAVORITES (cần Bearer — `AuthInterceptor` tự gắn token).
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/favorites...`.
@RestApi()
abstract class FavoritesService {
  factory FavoritesService(Dio dio) = _FavoritesService;

  /// `GET /favorites` → `data [{ id, song, createdAt }]`.
  @GET('/favorites')
  Future<ApiResponse<List<FavoriteModel>>> list();

  /// `POST /favorites` body `{ youtubeId, title, artist, thumbnailUrl, duration }`.
  @POST('/favorites')
  Future<ApiResponse<FavoriteModel>> add(@Body() SongRefRequest body);

  /// `DELETE /favorites/{youtubeId}`.
  @DELETE('/favorites/{youtubeId}')
  Future<ApiResponse<dynamic>> remove(@Path('youtubeId') String youtubeId);
}
