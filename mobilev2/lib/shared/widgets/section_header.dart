import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title, super.key,
    this.subtitle,
    this.onSeeAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textTitle,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.r),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12.sp, color: context.textSub),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 13.sp, color: context.brandPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
