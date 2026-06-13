import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/app_theme.dart';
import 'package:karaoke/design/theme/providers/theme_notifier.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';

class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    return AlertDialog(
      title: const Text('🎨 Chọn Theme'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bộ màu', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: AppPalette.values.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final palette = AppPalette.values[index];
                return _PaletteButton(
                  palette: palette,
                  isSelected: state.palette == palette,
                  onTap: () => notifier.changePalette(palette),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text('Chế độ', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    icon: Icons.light_mode,
                    label: 'Light',
                    isSelected: state.themeMode == AppThemeMode.light,
                    onTap: () => notifier.changeMode(AppThemeMode.light),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _ModeButton(
                    icon: Icons.dark_mode,
                    label: 'Dark',
                    isSelected: state.themeMode == AppThemeMode.dark,
                    onTap: () => notifier.changeMode(AppThemeMode.dark),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _ModeButton(
                    icon: Icons.brightness_auto,
                    label: 'System',
                    isSelected: state.themeMode == AppThemeMode.system,
                    onTap: () => notifier.changeMode(AppThemeMode.system),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
    );
  }
}

class _PaletteButton extends StatelessWidget {

  const _PaletteButton({required this.palette, required this.isSelected, required this.onTap});
  final AppPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = palette.tokens.brandPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: preview.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(palette.icon, size: 24.sp, color: preview),
            SizedBox(height: 4.h),
            Text(
              palette.label,
              style: TextStyle(fontSize: 10.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
