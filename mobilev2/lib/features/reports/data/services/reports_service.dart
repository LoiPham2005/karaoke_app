import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/reports/data/models/create_report_request.dart';
import 'package:retrofit/retrofit.dart';

part 'reports_service.g.dart';

/// Retrofit service cho REPORTS (cần Bearer — `AuthInterceptor` tự gắn token).
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/reports`.
@RestApi()
abstract class ReportsService {
  factory ReportsService(Dio dio) = _ReportsService;

  /// `POST /reports` body `{ ...songRef, reason, detail? }`.
  @POST('/reports')
  Future<ApiResponse<dynamic>> create(@Body() CreateReportRequest body);
}
