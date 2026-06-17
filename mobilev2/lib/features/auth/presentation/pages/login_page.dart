import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/riverpod/riverpod_listeners.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/auth/presentation/providers/auth_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/widgets/karaoke_logo.dart';

@RoutePage()
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPassword = useState(false);
    final emailCtl = useTextEditingController();
    final passwordCtl = useTextEditingController();

    final state = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final isLoading = state.isLoading;

    // Toast lỗi tự động khi state chuyển sang error.
    useAsyncValueChange(state);

    // Khi đăng nhập thành công (state có user != null) → vào main.
    ref.listen(authProvider, (previous, next) {
      if (next.value != null && (previous?.value == null)) {
        context.router.replaceAll([const MainRoute()]);
      }
    });

    Future<void> submit() async {
      final email = emailCtl.text.trim();
      final password = passwordCtl.text;
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
        );
        return;
      }
      await notifier.login(email: email, password: password);
    }

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
                controller: emailCtl,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(
                  context,
                  'ban@gmail.com',
                  Icons.mail_outline,
                ),
              ),
              SizedBox(height: 16.r),

              const _FieldLabel('Mật khẩu'),
              SizedBox(height: 6.r),
              TextField(
                controller: passwordCtl,
                obscureText: !showPassword.value,
                onSubmitted: (_) => submit(),
                decoration: _decoration(
                  context,
                  '••••••••',
                  Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      showPassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: context.textSub,
                    ),
                    onPressed: () => showPassword.value = !showPassword.value,
                  ),
                ),
              ),
              SizedBox(height: 12.r),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      context.router.push(const ForgotPasswordRoute()),
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
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                  onPressed: () =>
                      context.router.replaceAll([const MainRoute()]),
                  icon: Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFDB4437),
                    ),
                    child: const Icon(
                      Icons.g_mobiledata,
                      color: Colors.white,
                      size: 20,
                    ),
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
                      onTap: () => context.router.push(const RegisterRoute()),
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
