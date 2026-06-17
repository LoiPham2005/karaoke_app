import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/history/data/models/history_add_request.dart';
import 'package:karaoke/features/history/data/models/history_item_model.dart';
import 'package:retrofit/retrofit.dart';

part 'history_service.g.dart';

/// Retrofit service cho HISTORY (cần Bearer — `AuthInterceptor` tự gắn token).
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/history...`.
@RestApi()
abstract class HistoryService {
  factory HistoryService(Dio dio) = _HistoryService;

  /// `GET /history` → `data [{ id, song, playedAt, secondsPlayed }]`.
  @GET('/history')
  Future<ApiResponse<List<HistoryItemModel>>> list();

  /// `POST /history` body `{ SongRef, secondsPlayed? }`.
  @POST('/history')
  Future<ApiResponse<HistoryItemModel>> add(@Body() HistoryAddRequest body);

  /// `DELETE /history` → xoá toàn bộ lịch sử.
  @DELETE('/history')
  Future<ApiResponse<dynamic>> clear();
}
