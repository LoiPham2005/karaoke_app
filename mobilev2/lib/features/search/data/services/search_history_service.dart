import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/search/data/models/search_history_item.dart';
import 'package:retrofit/retrofit.dart';

part 'search_history_service.g.dart';

/// Retrofit service cho SEARCH HISTORY (cần Bearer — `AuthInterceptor` tự gắn).
@RestApi()
abstract class SearchHistoryService {
  factory SearchHistoryService(Dio dio) = _SearchHistoryService;

  /// `GET /search-history` → `data [{ id, query, createdAt }]`.
  @GET('/search-history')
  Future<ApiResponse<List<SearchHistoryItem>>> list();

  /// `POST /search-history` body `{ query }`.
  @POST('/search-history')
  Future<ApiResponse<dynamic>> add(@Body() AddSearchRequest body);

  /// `DELETE /search-history/{id}`.
  @DELETE('/search-history/{id}')
  Future<ApiResponse<dynamic>> remove(@Path('id') String id);

  /// `DELETE /search-history` → xoá toàn bộ.
  @DELETE('/search-history')
  Future<ApiResponse<dynamic>> clear();
}
