import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/errors/failures.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/features/billing/data/models/checkout_request.dart';
import 'package:karaoke/features/billing/data/models/plan_model.dart';
import 'package:karaoke/features/billing/data/models/premium_status_model.dart';
import 'package:karaoke/features/billing/data/services/billing_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_notifier.g.dart';

/// Riverpod notifier cho trạng thái Premium của user (cần đăng nhập).
///
/// State = `PremiumStatusModel?` (`GET /subscriptions/me`). Sau khi mua gói:
/// checkout → (DEV) confirm-mock → refresh lại `me()` để đồng bộ trạng thái.
@riverpod
class BillingNotifier extends _$BillingNotifier
    with BaseNotifier<PremiumStatusModel?> {
  late BillingService _service;

  @override
  Future<PremiumStatusModel?> build() async {
    _service = BillingService(ref.read(dioProvider));
    final response = await _service.me();
    return response.data;
  }

  /// Tải lại trạng thái Premium.
  Future<void> refresh() => runUnwrap(
    action: _service.me,
    mapper: (data) => data,
    keepPreviousOnLoading: true,
  );

  /// Mua gói [plan]: tạo phiên thanh toán → (DEV) xác nhận giả lập → refresh.
  Future<void> buyPlan(String plan) => runAsync(
    action: () async {
      final checkout = await _service.checkout(CheckoutRequest(plan: plan));
      final data = checkout.data;
      if (!checkout.isSuccess || data == null) {
        throw ServerFailure(checkout.message ?? 'Không tạo được thanh toán');
      }
      // (DEV) xác nhận thanh toán giả lập để kích hoạt Premium ngay.
      await _service.confirmMock(data.paymentId);
      // Đồng bộ lại trạng thái từ server sau khi nâng cấp.
      final me = await _service.me();
      return me.data;
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã nâng cấp Premium',
  );
}

/// FutureProvider: bảng giá các gói Premium (`GET /subscriptions/plans`, PUBLIC).
@riverpod
Future<List<PlanModel>> plans(Ref ref) async {
  final service = BillingService(ref.read(dioProvider));
  final response = await service.plans();
  return response.data ?? const [];
}
