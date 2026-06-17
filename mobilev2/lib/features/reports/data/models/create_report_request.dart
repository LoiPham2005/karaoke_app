import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_report_request.freezed.dart';
part 'create_report_request.g.dart';

/// Body cho `POST /reports` (báo lỗi bài hát): metadata bài + lý do/chi tiết.
@freezed
abstract class CreateReportRequest with _$CreateReportRequest {
  const factory CreateReportRequest({
    required String youtubeId,
    required String title,
    required String reason,
    String? artist,
    String? thumbnailUrl,
    int? duration,
    String? detail,
  }) = _CreateReportRequest;

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReportRequestFromJson(json);
}
