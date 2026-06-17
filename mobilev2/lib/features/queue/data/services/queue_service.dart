import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:karaoke/features/queue/data/models/queue_item_model.dart';
import 'package:retrofit/retrofit.dart';

part 'queue_service.g.dart';

/// Retrofit service cho QUEUE (cần Bearer — `AuthInterceptor` tự gắn token).
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/queue...`.
@RestApi()
abstract class QueueService {
  factory QueueService(Dio dio) = _QueueService;

  /// `GET /queue` → `data [{ id, song, position }]`.
  @GET('/queue')
  Future<ApiResponse<List<QueueItemModel>>> list();

  /// `POST /queue` body `SongRef`.
  @POST('/queue')
  Future<ApiResponse<QueueItemModel>> add(@Body() SongRefRequest body);

  /// `DELETE /queue/{id}`.
  @DELETE('/queue/{id}')
  Future<ApiResponse<dynamic>> removeItem(@Path('id') String id);

  /// `DELETE /queue` → xoá toàn bộ hàng chờ.
  @DELETE('/queue')
  Future<ApiResponse<dynamic>> clear();
}
