import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_history_item.freezed.dart';
part 'search_history_item.g.dart';

/// 1 mục lịch sử tìm kiếm từ `GET /search-history`.
@freezed
abstract class SearchHistoryItem with _$SearchHistoryItem {
  const factory SearchHistoryItem({
    required String id,
    required String query,
    String? createdAt,
  }) = _SearchHistoryItem;

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryItemFromJson(json);
}

/// Body cho `POST /search-history`.
@freezed
abstract class AddSearchRequest with _$AddSearchRequest {
  const factory AddSearchRequest({required String query}) = _AddSearchRequest;

  factory AddSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$AddSearchRequestFromJson(json);
}
