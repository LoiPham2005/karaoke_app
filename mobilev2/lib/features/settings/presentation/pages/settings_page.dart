import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoPlay = true;
  bool _crossfade = false;
  bool _karaokeEffect = true;
  bool _emailNotify = true;
  bool _publicHistory = false;
  String _theme = 'auto';
  final String _videoQuality = 'auto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      appBar: AppBar(
        backgroundColor: context.bgPage,
        elevation: 0,
        title: Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.textTitle,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          const _SectionTitle('Tài khoản'),
          _Group(children: [
            _Tile(icon: Icons.person_outline, label: 'Thông tin cá nhân', onTap: () {}),
            _Tile(icon: Icons.lock_outline, label: 'Đổi mật khẩu', onTap: () {}),
            _Tile(icon: Icons.delete_outline, label: 'Xóa tài khoản', titleColor: Colors.red, onTap: () {}),
          ]),
          SizedBox(height: 24.r),

          const _SectionTitle('Giao diện'),
          _Group(children: [
            _SwitchTile(
              icon: Icons.dark_mode_outlined,
              label: 'Chế độ tối',
              value: _theme == 'dark',
              onChanged: (v) => setState(() => _theme = v ? 'dark' : 'light'),
            ),
            _Tile(
              icon: Icons.language,
              label: 'Ngôn ngữ',
              trailing: Text('Tiếng Việt', style: TextStyle(color: context.textSub, fontSize: 13.sp)),
              onTap: () {},
            ),
          ]),
          SizedBox(height: 24.r),

          const _SectionTitle('Phát nhạc'),
          _Group(children: [
            _SwitchTile(
              icon: Icons.play_circle_outline,
              label: 'Tự động phát bài tiếp',
              value: _autoPlay,
              onChanged: (v) => setState(() => _autoPlay = v),
            ),
            _SwitchTile(
              icon: Icons.repeat,
              label: 'Crossfade',
              value: _crossfade,
              onChanged: (v) => setState(() => _crossfade = v),
            ),
            _SwitchTile(
              icon: Icons.mic,
              label: 'Hiệu ứng karaoke',
              value: _karaokeEffect,
              onChanged: (v) => setState(() => _karaokeEffect = v),
            ),
            _Tile(
              icon: Icons.high_quality,
              label: 'Chất lượng video',
              trailing: Text(_videoQuality.toUpperCase(),
                  style: TextStyle(color: context.textSub, fontSize: 13.sp)),
              onTap: () {},
            ),
          ]),
          SizedBox(height: 24.r),

          const _SectionTitle('Thông báo'),
          _Group(children: [
            _SwitchTile(
              icon: Icons.email_outlined,
              label: 'Email hàng tuần',
              value: _emailNotify,
              onChanged: (v) => setState(() => _emailNotify = v),
            ),
          ]),
          SizedBox(height: 24.r),

          const _SectionTitle('Riêng tư'),
          _Group(children: [
            _SwitchTile(
              icon: Icons.visibility_outlined,
              label: 'Lịch sử công khai',
              value: _publicHistory,
              onChanged: (v) => setState(() => _publicHistory = v),
            ),
          ]),
          SizedBox(height: 24.r),

          const _SectionTitle('Hỗ trợ'),
          _Group(children: [
            _Tile(icon: Icons.help_outline, label: 'Câu hỏi thường gặp', onTap: () {}),
            _Tile(icon: Icons.support_agent, label: 'Liên hệ', onTap: () {}),
            _Tile(icon: Icons.info_outline, label: 'Về SingNow', onTap: () {}),
          ]),
          SizedBox(height: 24.r),
          Center(
            child: Text(
              'SingNow v1.0.0',
              style: TextStyle(fontSize: 11.sp, color: context.textSub),
            ),
          ),
          SizedBox(height: 24.r),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.r, bottom: 8.r),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: context.textSub,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Column(children: children),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: titleColor ?? context.textBody, size: 22.r),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          color: titleColor ?? context.textTitle,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: context.textSub),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: context.brandPrimary,
      secondary: Icon(icon, color: context.textBody, size: 22.r),
      title: Text(
        label,
        style: TextStyle(fontSize: 14.sp, color: context.textTitle),
      ),
    );
  }
}
