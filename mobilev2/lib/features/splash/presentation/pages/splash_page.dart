import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/data/storage/secure_storage_service.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/widgets/karaoke_logo.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_decideNextRoute());
  }

  /// Đã đăng nhập (có `access_token`) → vào thẳng MainRoute, bỏ qua onboarding/login.
  /// Chưa đăng nhập → Onboarding như cũ. Giữ splash tối thiểu ~1.5s cho mượt.
  Future<void> _decideNextRoute() async {
    final storage = getIt<SecureStorageService>();
    final results = await Future.wait([
      storage.read('access_token'),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (!mounted) return;
    final token = results.first as String?;
    final loggedIn = token != null && token.isNotEmpty;
    await context.router.replaceAll([
      if (loggedIn) const MainRoute() else const OnboardingRoute(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.brandPrimary, context.brandSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const KaraokeLogo(size: 64, showText: false),
              SizedBox(height: 24.r),
              Text(
                'SingNow',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8.r),
              Text(
                'Hát mọi lúc, mọi nơi 🎤',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: 64.r),
              SizedBox(
                width: 32.r,
                height: 32.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
