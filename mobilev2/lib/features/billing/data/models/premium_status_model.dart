import 'package:freezed_annotation/freezed_annotation.dart';

part 'premium_status_model.freezed.dart';
part 'premium_status_model.g.dart';

/// Trạng thái Premium của user hiện tại.
///
/// `GET /subscriptions/me` →
/// `data { isPremium, plan?, status?, currentPeriodEnd?, autoRenew }`.
@freezed
abstract class PremiumStatusModel with _$PremiumStatusModel {
  const factory PremiumStatusModel({
    @Default(false) bool isPremium,
    String? plan,
    String? status,
    String? currentPeriodEnd,
    @Default(false) bool autoRenew,
  }) = _PremiumStatusModel;

  factory PremiumStatusModel.fromJson(Map<String, dynamic> json) =>
      _$PremiumStatusModelFromJson(json);
}
