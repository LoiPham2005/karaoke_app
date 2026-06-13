import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/routes/config/app_router.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _showPassword = false;
  String _password = '';

  int get _strength {
    if (_password.isEmpty) return 0;
    int s = 0;
    if (_password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(_password)) s++;
    if (RegExp(r'[0-9]').hasMatch(_password)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(_password)) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final strengthColors = <Color>[
      context.borderDefault,
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green,
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textTitle),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo tài khoản 🎉',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textTitle,
                ),
              ),
              SizedBox(height: 8.r),
              Text(
                'Đăng ký miễn phí — không có quảng cáo phiền phức',
                style: TextStyle(fontSize: 14.sp, color: context.textSub),
              ),
              SizedBox(height: 32.r),

              const _FieldLabel('Tên hiển thị'),
              SizedBox(height: 6.r),
              TextField(
                decoration: _decoration(context, 'Nguyễn Văn A', Icons.person_outline),
              ),
              SizedBox(height: 16.r),

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
                onChanged: (v) => setState(() => _password = v),
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
              if (_password.isNotEmpty) ...[
                SizedBox(height: 8.r),
                Row(
                  children: List.generate(4, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.r),
                        height: 4.r,
                        decoration: BoxDecoration(
                          color: i < _strength
                              ? strengthColors[_strength]
                              : context.borderDefault,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 4.r),
                Text(
                  'Độ mạnh: ${['Rất yếu', 'Yếu', 'Trung bình', 'Khá', 'Mạnh'][_strength]}',
                  style: TextStyle(fontSize: 11.sp, color: context.textSub),
                ),
              ],
              SizedBox(height: 24.r),

              SizedBox(
                width: double.infinity,
                height: 52.r,
                child: ElevatedButton(
                  onPressed: () => context.router.replaceAll([const MainRoute()]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                  ),
                  child: Text(
                    'Đăng ký miễn phí',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 24.r),

              Center(
                child: GestureDetector(
                  onTap: () => context.router.maybePop(),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13.sp, color: context.textSub),
                      children: [
                        const TextSpan(text: 'Đã có tài khoản? '),
                        TextSpan(
                          text: 'Đăng nhập',
                          style: TextStyle(
                            color: context.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
