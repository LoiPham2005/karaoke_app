import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:flutter_base/shared/widgets/karaoke_logo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.r),
              const KaraokeLogo(size: 36),
              SizedBox(height: 48.r),
              Text(
                'Chào mừng trở lại 👋',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textTitle,
                ),
              ),
              SizedBox(height: 8.r),
              Text(
                'Đăng nhập để tiếp tục hát karaoke',
                style: TextStyle(fontSize: 14.sp, color: context.textSub),
              ),
              SizedBox(height: 32.r),

              const _FieldLabel('Email'),
              SizedBox(height: 6.r),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(context, 'ban@gmail.com', Icons.mail_outline),
              ),
              SizedBox(height: 16.r),

              const _FieldLabel('Mật khẩu'),
              SizedBox(height: 6.r),
              TextField(
                obscureText: !_showPassword,
                decoration: _decoration(
                  context,
                  '••••••••',
                  Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: context.textSub,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              SizedBox(height: 12.r),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(RouteNames.forgotPassword),
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: context.brandPrimary,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.r),

              SizedBox(
                width: double.infinity,
                height: 52.r,
                child: ElevatedButton(
                  onPressed: () => context.go(RouteNames.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                  ),
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 24.r),

              Row(
                children: [
                  Expanded(child: Divider(color: context.borderDefault)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.r),
                    child: Text(
                      'Hoặc',
                      style: TextStyle(color: context.textSub, fontSize: 12.sp),
                    ),
                  ),
                  Expanded(child: Divider(color: context.borderDefault)),
                ],
              ),
              SizedBox(height: 24.r),

              SizedBox(
                width: double.infinity,
                height: 52.r,
                child: OutlinedButton.icon(
                  onPressed: () => context.go(RouteNames.home),
                  icon: Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFDB4437),
                    ),
                    child: const Icon(Icons.g_mobiledata, color: Colors.white, size: 20),
                  ),
                  label: Text(
                    'Đăng nhập với Google',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.textTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.borderDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.r),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: context.textSub, fontSize: 13.sp),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: context.brandPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    BuildContext context,
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.textSub, fontSize: 14.sp),
      prefixIcon: Icon(icon, color: context.textSub),
      suffixIcon: suffix,
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
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: context.textBody,
      ),
    );
  }
}
