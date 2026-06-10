import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _OnboardingSlide(
      emoji: '🎤',
      title: 'Kho nhạc vô tận',
      desc: 'Hàng triệu bài hát từ YouTube — bài nào cũng có, mới hay cũ đều đầy đủ',
    ),
    _OnboardingSlide(
      emoji: '🎵',
      title: 'Lyrics đồng bộ chuẩn',
      desc: 'Highlight từng chữ theo nhịp — không bao giờ bị lệch lời',
    ),
    _OnboardingSlide(
      emoji: '👯',
      title: 'Hát chung với bạn',
      desc: 'Tạo phòng riêng, mời bạn bè cùng hát từ xa qua mạng',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: TextButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: context.textSub,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _slides[i],
              ),
            ),
            // Dots indicator
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.r),
                    width: active ? 24.r : 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: active ? context.brandPrimary : context.borderDefault,
                      borderRadius: BorderRadius.circular(AppDimensions.circle),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.r),
              child: SizedBox(
                width: double.infinity,
                height: 52.r,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index < _slides.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      context.go(RouteNames.login);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                  ),
                  child: Text(
                    _index == _slides.length - 1 ? 'Bắt đầu hát' : 'Tiếp tục',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.desc,
  });

  final String emoji;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200.r,
            height: 200.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  context.brandPrimary.withValues(alpha: 0.2),
                  context.brandSecondary.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 96.sp))),
          ),
          SizedBox(height: 48.r),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: context.textTitle,
            ),
          ),
          SizedBox(height: 16.r),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: context.textSub,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
