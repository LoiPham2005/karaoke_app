import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:flutter_base/shared/widgets/karaoke_logo.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go(RouteNames.onboarding);
    });
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
