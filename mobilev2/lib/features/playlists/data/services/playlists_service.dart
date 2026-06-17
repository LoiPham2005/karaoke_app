import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:karaoke/features/playlists/data/models/create_playlist_request.dart';
import 'package:karaoke/features/playlists/data/models/playlist_model.dart';
import 'package:karaoke/features/playlists/data/models/reorder_playlist_request.dart';
import 'package:retrofit/retrofit.dart';

part 'playlists_service.g.dart';

/// Retrofit service cho PLAYLISTS (cần Bearer — `AuthInterceptor` tự gắn token).
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/playlists...`.
@RestApi()
abstract class PlaylistsService {
  factory PlaylistsService(Dio dio) = _PlaylistsService;

  /// `GET /playlists` → `data PlaylistModel[]`.
  @GET('/playlists')
  Future<ApiResponse<List<PlaylistModel>>> list();

  /// `POST /playlists` body `{ name, description?, isPublic? }`.
  @POST('/playlists')
  Future<ApiResponse<PlaylistModel>> create(@Body() CreatePlaylistRequest body);

  /// `GET /playlists/{id}` → `data playlist + items[{ id, song, position }]`.
  @GET('/playlists/{id}')
  Future<ApiResponse<PlaylistModel>> detail(@Path('id') String id);

  /// `POST /playlists/{id}/songs` body `SongRef`.
  @POST('/playlists/{id}/songs')
  Future<ApiResponse<dynamic>> addSong(
    @Path('id') String id,
    @Body() SongRefRequest body,
  );

  /// `DELETE /playlists/{id}/songs/{youtubeId}`.
  @DELETE('/playlists/{id}/songs/{youtubeId}')
  Future<ApiResponse<dynamic>> removeSong(
    @Path('id') String id,
    @Path('youtubeId') String youtubeId,
  );

  /// `PATCH /playlists/{id}/reorder` body `{ orderedYoutubeIds }`.
  @PATCH('/playlists/{id}/reorder')
  Future<ApiResponse<dynamic>> reorder(
    @Path('id') String id,
    @Body() ReorderPlaylistRequest body,
  );

  /// `DELETE /playlists/{id}`.
  @DELETE('/playlists/{id}')
  Future<ApiResponse<dynamic>> delete(@Path('id') String id);
}
