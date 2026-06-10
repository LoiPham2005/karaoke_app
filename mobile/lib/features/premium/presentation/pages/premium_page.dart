import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _selected = 1;

  static const _plans = [
    ('1 tháng', '39.000', '39k/tháng', ''),
    ('12 tháng', '299.000', '~25k/tháng', 'Tiết kiệm 40%'),
    ('Trọn đời', '999.000', 'Một lần', 'Tốt nhất'),
  ];

  static const _features = [
    ('🎤', 'Không quảng cáo', 'Trải nghiệm liền mạch'),
    ('🎯', 'Chấm điểm AI', 'Phân tích giọng hát'),
    ('🎬', 'Ghi & chia sẻ bản thu', 'Lưu giọng hát của bạn'),
    ('📺', 'Cast lên TV không giới hạn', 'Hát trên màn hình lớn'),
    ('🎨', 'Theme độc quyền', 'Giao diện đặc biệt'),
    ('☁️', 'Sync nhiều thiết bị', 'Hát mọi nơi'),
  ];

  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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
                ..._features.map((f) => Padding(
                      padding: EdgeInsets.only(bottom: 12.r),
                      child: Row(
                        children: [
                          Container(
                            width: 44.r,
                            height: 44.r,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.brandPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radius),
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
                          Icon(Icons.check_circle,
                              color: context.statusSuccess, size: 20.r),
                        ],
                      ),
                    )),
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
                ...List.generate(_plans.length, (i) {
                  final p = _plans[i];
                  final active = _selected == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.r),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: active
                            ? context.brandPrimary.withValues(alpha: 0.1)
                            : context.bgCard,
                        borderRadius: BorderRadius.circular(AppDimensions.radius),
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
                            color: active ? context.brandPrimary : context.textSub,
                          ),
                          SizedBox(width: 12.r),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      p.$1,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.textTitle,
                                      ),
                                    ),
                                    if (p.$4.isNotEmpty) ...[
                                      SizedBox(width: 8.r),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6.r, vertical: 2.r),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          p.$4,
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 2.r),
                                Text(
                                  p.$3,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: context.textSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${p.$2}đ',
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

                SizedBox(height: 80.r),
              ],
            ),
            Positioned(
              top: 8.r,
              right: 8.r,
              child: IconButton(
                onPressed: () => context.pop(),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: context.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                ),
              ),
              child: Text(
                'Nâng cấp Premium',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
