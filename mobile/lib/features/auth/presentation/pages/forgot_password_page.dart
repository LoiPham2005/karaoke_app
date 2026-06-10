import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textTitle),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_reset, size: 64.r, color: context.brandPrimary),
              SizedBox(height: 24.r),
              Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textTitle,
                ),
              ),
              SizedBox(height: 8.r),
              Text(
                'Nhập email — chúng tôi sẽ gửi link đặt lại mật khẩu cho bạn.',
                style: TextStyle(fontSize: 14.sp, color: context.textSub, height: 1.4),
              ),
              SizedBox(height: 32.r),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'ban@gmail.com',
                  hintStyle: TextStyle(color: context.textSub, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.mail_outline, color: context.textSub),
                  filled: true,
                  fillColor: context.bgInput,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                    borderSide: BorderSide(color: context.borderDefault),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                    borderSide: BorderSide(color: context.borderDefault),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                    borderSide: BorderSide(color: context.brandPrimary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 24.r),
              SizedBox(
                width: double.infinity,
                height: 52.r,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi link — kiểm tra email nhé')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                  ),
                  child: Text(
                    'Gửi link đặt lại',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
