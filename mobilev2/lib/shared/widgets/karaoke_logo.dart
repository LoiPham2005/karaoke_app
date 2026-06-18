import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo SingNow — dùng chung 1 asset SVG với web (assets/icons/singnow_icon.svg):
/// ô bo góc gradient hồng→tím + mic trắng. `size` ≈ kích thước icon mic;
/// ô vuông tổng ≈ size * 1.5.
class KaraokeLogo extends StatelessWidget {
  const KaraokeLogo({super.key, this.size = 32, this.showText = true});

  final double size;
  final bool showText;

  // Brand SingNow (đồng bộ web): #ff3d71 → #8b5cf6.
  static const Color _pink = Color(0xFFFF3D71);
  static const Color _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final box = size * 1.5;
    final radius = box * 0.23;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.r),
            boxShadow: [
              BoxShadow(
                color: _pink.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius.r),
            child: SvgPicture.asset(
              'assets/icons/singnow_icon.svg',
              width: box.r,
              height: box.r,
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: 10.r),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [_pink, _purple],
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
