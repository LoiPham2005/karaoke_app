import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/auth/presentation/providers/auth_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_user.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = mockUser;
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // ─── Header ─────────────────────────────────
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundImage: NetworkImage(user.avatarUrl!),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: context.brandPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.bgPage, width: 2),
                        ),
                        child: Icon(Icons.camera_alt, size: 12.r, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textTitle,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isPremium) ...[
                            SizedBox(width: 6.r),
                            Icon(Icons.workspace_premium, color: Colors.amber, size: 18.r),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 13.sp, color: context.textSub),
                      ),
                      if (user.bio != null) ...[
                        SizedBox(height: 4.r),
                        Text(
                          user.bio!,
                          style: TextStyle(fontSize: 12.sp, color: context.textBody),
                        ),
                      ],
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.brandPrimary,
                    side: BorderSide(color: context.brandPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.circle),
                    ),
                  ),
                  child: Text('Sửa', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
            SizedBox(height: 24.r),

            // ─── Stats ──────────────────────────────────
            Row(
              children: [
                _StatCard(value: '${user.songsSung}', label: 'Bài đã hát'),
                _StatCard(value: '${user.totalMinutes ~/ 60}h', label: 'Thời gian'),
                _StatCard(value: '${user.playlistCount}', label: 'Playlist'),
                _StatCard(value: '${user.contributionCount}', label: 'Đóng góp'),
              ],
            ),
            SizedBox(height: 24.r),

            // ─── Menu items ─────────────────────────────
            _MenuTile(
              icon: Icons.workspace_premium,
              iconColor: Colors.amber,
              title: 'Nâng cấp Premium',
              subtitle: 'Bỏ quảng cáo, chấm điểm AI',
              onTap: () => context.router.push(const PremiumRoute()),
            ),
            _MenuTile(
              icon: Icons.queue_music,
              title: 'Hàng chờ phát',
              onTap: () => context.router.push(const QueueRoute()),
            ),
            _MenuTile(
              icon: Icons.history,
              title: 'Lịch sử hát',
              onTap: () => context.router.push(const HistoryRoute()),
            ),
            _MenuTile(
              icon: Icons.favorite_border,
              title: 'Yêu thích',
              onTap: () => context.router.push(const FavoritesRoute()),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Cài đặt',
              onTap: () => context.router.push(const SettingsRoute()),
            ),
            _MenuTile(
              icon: Icons.help_outline,
              title: 'Trợ giúp & Hỗ trợ',
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'Đăng xuất',
              titleColor: Colors.red,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// Xác nhận → đăng xuất (revoke refresh token + xoá token local) → về login.
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogCtx.bgCard,
        title: Text('Đăng xuất', style: TextStyle(color: dialogCtx.textTitle)),
        content: Text(
          'Bạn chắc chắn muốn đăng xuất?',
          style: TextStyle(color: dialogCtx.textBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Đăng xuất',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      await context.router.replaceAll([const LoginRoute()]);
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.r),
        padding: EdgeInsets.symmetric(vertical: 16.r),
        decoration: BoxDecoration(
          color: context.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: context.brandPrimary,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: context.textSub),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.bgCard,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? context.textBody, size: 22.r),
              SizedBox(width: 16.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? context.textTitle,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.r),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 11.sp, color: context.textSub),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.textSub),
            ],
          ),
        ),
      ),
    ).paddedBottom();
  }
}

extension on Widget {
  Widget paddedBottom() => Padding(padding: EdgeInsets.only(bottom: 8.r), child: this);
}
