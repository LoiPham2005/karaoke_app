import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KaraokeLogo extends StatelessWidget {
  const KaraokeLogo({super.key, this.size = 32, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(size * 0.25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.brandPrimary, context.brandSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: context.brandPrimary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.mic, color: Colors.white, size: size.r),
        ),
        if (showText) ...[
          SizedBox(width: 10.r),
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: [context.brandPrimary, context.brandSecondary],
            ).createShader(rect),
            child: Text(
              'SingNow',
              style: TextStyle(
                fontSize: (size * 0.7).sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
