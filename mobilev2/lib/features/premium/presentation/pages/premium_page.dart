import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/riverpod/riverpod_listeners.dart';
import 'package:karaoke/core/common/extensions/datetime_extensions.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/billing/data/models/plan_model.dart';
import 'package:karaoke/features/billing/data/models/premium_status_model.dart';
import 'package:karaoke/features/billing/presentation/providers/billing_notifier.dart';

@RoutePage()
class PremiumPage extends HookConsumerWidget {
  const PremiumPage({super.key});

  static const _features = [
    ('🎤', 'Không quảng cáo', 'Trải nghiệm liền mạch'),
    ('🎯', 'Chấm điểm AI', 'Phân tích giọng hát'),
    ('🎬', 'Ghi & chia sẻ bản thu', 'Lưu giọng hát của bạn'),
    ('📺', 'Cast lên TV không giới hạn', 'Hát trên màn hình lớn'),
    ('🎨', 'Theme độc quyền', 'Giao diện đặc biệt'),
    ('☁️', 'Sync nhiều thiết bị', 'Hát mọi nơi'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansState = ref.watch(plansProvider);
    final billingState = ref.watch(billingProvider);
    // Toast lỗi/success cho luồng mua gói (buyPlan).
    useAsyncValueChange(billingState);

    final selected = useState(0);
    final plans = plansState.value ?? const <PlanModel>[];
    final status = billingState.value;
    final isPremium = status?.isPremium ?? false;
    final isBuying = billingState.isLoading;

    // Giữ index chọn hợp lệ khi danh sách gói thay đổi.
    final selectedIndex = plans.isEmpty
        ? 0
        : selected.value.clamp(0, plans.length - 1);

    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                // Hero gradient
                Container(
                  margin: EdgeInsets.only(top: 40.r, bottom: 24.r),
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.brandPrimary, context.brandSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('👑', style: TextStyle(fontSize: 56.sp)),
                      SizedBox(height: 12.r),
                      Text(
                        'SingNow Premium',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        'Trải nghiệm karaoke không giới hạn',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      if (isPremium) ...[
                        SizedBox(height: 12.r),
                        _PremiumBadge(status: status!),
                      ],
                    ],
                  ),
                ),

                // Features
                Text(
                  'Đặc quyền Premium',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textTitle,
                  ),
                ),
                SizedBox(height: 12.r),
                ..._features.map(
                  (f) => Padding(
                    padding: EdgeInsets.only(bottom: 12.r),
                    child: Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: context.brandPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius,
                            ),
                          ),
                          child: Text(f.$1, style: TextStyle(fontSize: 22.sp)),
                        ),
                        SizedBox(width: 12.r),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.$2,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: context.textTitle,
                                ),
                              ),
                              Text(
                                f.$3,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: context.statusSuccess,
                          size: 20.r,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.r),

                // Plans
                Text(
                  'Chọn gói',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textTitle,
                  ),
                ),
                SizedBox(height: 12.r),
                if (plansState.isLoading && plans.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.r),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else if (plansState.hasError && plans.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.r),
                    child: Center(
                      child: TextButton(
                        onPressed: () => ref.invalidate(plansProvider),
                        child: const Text('Tải lại bảng giá'),
                      ),
                    ),
                  )
                else
                  ...List.generate(plans.length, (i) {
                    final p = plans[i];
                    final active = selectedIndex == i;
                    return GestureDetector(
                      onTap: () => selected.value = i,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.r),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: active
                              ? context.brandPrimary.withValues(alpha: 0.1)
                              : context.bgCard,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius,
                          ),
                          border: Border.all(
                            color: active
                                ? context.brandPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              active
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: active
                                  ? context.brandPrimary
                                  : context.textSub,
                            ),
                            SizedBox(width: 12.r),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.label,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.textTitle,
                                    ),
                                  ),
                                  SizedBox(height: 2.r),
                                  Text(
                                    '${p.durationDays} ngày',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: context.textSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_formatVnd(p.priceVnd)}đ',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: context.brandPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                SizedBox(height: 12.r),
                Text(
                  '(DEV) Thanh toán giả lập — không phát sinh giao dịch thật.',
                  style: TextStyle(fontSize: 11.sp, color: context.textSub),
                ),

                SizedBox(height: 80.r),
              ],
            ),
            Positioned(
              top: 8.r,
              right: 8.r,
              child: IconButton(
                onPressed: () => context.router.maybePop(),
                icon: Icon(Icons.close, color: context.textTitle),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: SizedBox(
            width: double.infinity,
            height: 52.r,
            child: ElevatedButton(
              onPressed: plans.isEmpty || isBuying
                  ? null
                  : () => _onBuy(context, ref, plans[selectedIndex].plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                ),
              ),
              child: isBuying
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isPremium ? 'Gia hạn Premium' : 'Nâng cấp Premium',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onBuy(BuildContext context, WidgetRef ref, String plan) async {
    final isAuthenticated = ref.read(appAuthProvider).isAuthenticated;
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập để nâng cấp Premium')),
      );
      return;
    }
    await ref.read(billingProvider.notifier).buyPlan(plan);
  }

  /// `39000` → `39.000` (phân nhóm hàng nghìn bằng dấu chấm).
  String _formatVnd(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Badge "Premium đến [ngày]" hiển thị trong hero khi user đang là Premium.
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge({required this.status});

  final PremiumStatusModel status;

  @override
  Widget build(BuildContext context) {
    final end = status.currentPeriodEnd;
    final parsed = end == null ? null : DateTime.tryParse(end);
    final label = parsed != null
        ? 'Premium đến ${parsed.toLocal().format()}'
        : 'Đang là Premium';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
