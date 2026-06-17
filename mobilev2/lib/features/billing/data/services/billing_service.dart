import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/billing/data/models/checkout_request.dart';
import 'package:karaoke/features/billing/data/models/checkout_response.dart';
import 'package:karaoke/features/billing/data/models/plan_model.dart';
import 'package:karaoke/features/billing/data/models/premium_status_model.dart';
import 'package:retrofit/retrofit.dart';

part 'billing_service.g.dart';

/// Retrofit service cho BILLING (gói Premium / subscriptions).
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/subscriptions...`
/// và `/payments...`. Các endpoint cần Bearer được `AuthInterceptor` tự gắn token
/// (riêng `/subscriptions/plans` là PUBLIC).
@RestApi()
abstract class BillingService {
  factory BillingService(Dio dio) = _BillingService;

  /// `GET /subscriptions/plans` (PUBLIC) →
  /// `data [{ plan, label, priceVnd, durationDays }]`.
  @GET('/subscriptions/plans')
  Future<ApiResponse<List<PlanModel>>> plans();

  /// `GET /subscriptions/me` (Bearer) →
  /// `data { isPremium, plan?, status?, currentPeriodEnd?, autoRenew }`.
  @GET('/subscriptions/me')
  Future<ApiResponse<PremiumStatusModel>> me();

  /// `POST /subscriptions/checkout` (Bearer) body `{ plan, provider? }` →
  /// `data { paymentId, subscriptionId, amount, plan, provider, payUrl }`.
  @POST('/subscriptions/checkout')
  Future<ApiResponse<CheckoutResponse>> checkout(@Body() CheckoutRequest body);

  /// `POST /payments/{id}/confirm-mock` (Bearer, DEV) →
  /// `data { success, plan, premiumUntil }`.
  @POST('/payments/{id}/confirm-mock')
  Future<ApiResponse<dynamic>> confirmMock(@Path('id') String id);
}
