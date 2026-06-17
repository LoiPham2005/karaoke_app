import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_request.freezed.dart';
part 'checkout_request.g.dart';

/// Body cho `POST /subscriptions/checkout`.
///
/// Quy tắc vàng: KHÔNG dùng `Map<String, dynamic>` cho request body — luôn dùng
/// `@freezed` Request class có `toJson`.
@freezed
abstract class CheckoutRequest with _$CheckoutRequest {
  const factory CheckoutRequest({required String plan, String? provider}) =
      _CheckoutRequest;

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestFromJson(json);
}
