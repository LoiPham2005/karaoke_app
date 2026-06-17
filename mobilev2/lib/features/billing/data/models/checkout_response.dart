import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_response.freezed.dart';
part 'checkout_response.g.dart';

/// Kết quả tạo phiên thanh toán.
///
/// `POST /subscriptions/checkout` →
/// `data { paymentId, subscriptionId, amount, plan, provider, payUrl }`.
@freezed
abstract class CheckoutResponse with _$CheckoutResponse {
  const factory CheckoutResponse({
    required String paymentId,
    required int amount,
    required String plan,
    required String provider,
    required String payUrl,
  }) = _CheckoutResponse;

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResponseFromJson(json);
}
