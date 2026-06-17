import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_model.freezed.dart';
part 'plan_model.g.dart';

/// Một gói Premium từ backend.
///
/// `GET /subscriptions/plans` → `data [{ plan, label, priceVnd, durationDays }]`.
@freezed
abstract class PlanModel with _$PlanModel {
  const factory PlanModel({
    required String plan,
    required String label,
    required int priceVnd,
    required int durationDays,
  }) = _PlanModel;

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);
}
