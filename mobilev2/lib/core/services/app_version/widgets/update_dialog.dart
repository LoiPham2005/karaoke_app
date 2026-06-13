import 'package:flutter/material.dart';

/// 🏷️ I18n labels cho [UpdateDialog]. Ngôn ngữ khác → đổi instance.
class AppVersionLabels {
  const AppVersionLabels({
    required this.forceTitle,
    required this.optionalTitle,
    required this.updateButton,
    required this.laterButton,
    required this.currentLabel,
    required this.latestLabel,
    required this.forceFallback,
    required this.optionalFallback,
  });

  final String forceTitle;
  final String optionalTitle;
  final String updateButton;
  final String laterButton;
  final String currentLabel;
  final String latestLabel;

  /// Message mặc định khi server không trả `message`.
  final String forceFallback;
  final String optionalFallback;

  /// 🇻🇳 Preset tiếng Việt.
  static const vi = AppVersionLabels(
    forceTitle: 'Cập nhật bắt buộc',
    optionalTitle: 'Đã có phiên bản mới',
    updateButton: 'Cập nhật ngay',
    laterButton: 'Để sau',
    currentLabel: 'Phiên bản hiện tại',
    latestLabel: 'Phiên bản mới',
    forceFallback:
        'Phiên bản hiện tại đã quá cũ. Vui lòng cập nhật để tiếp tục sử dụng.',
    optionalFallback:
        'Đã có phiên bản mới với nhiều cải tiến. Bạn có muốn cập nhật ngay?',
  );

  /// 🇬🇧 Preset English.
  static const en = AppVersionLabels(
    forceTitle: 'Update required',
    optionalTitle: 'New version available',
    updateButton: 'Update now',
    laterButton: 'Later',
    currentLabel: 'Current version',
    latestLabel: 'New version',
    forceFallback:
        'This version is too old. Please update to continue using the app.',
    optionalFallback:
        'A new version with improvements is available. Update now?',
  );
}

/// Dialog thông báo cập nhật app.
///
/// - [isForce] = true  → KHÔNG tắt được (PopScope chặn back, KHÔNG nút "Để sau",
///   KHÔNG `exit()` — tránh App Store reject; user buộc phải cập nhật để qua).
/// - [isForce] = false → có nút "Để sau".
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    required this.labels,
    required this.currentVersion,
    required this.latestVersion,
    required this.isForce,
    required this.onUpdate,
    super.key,
    this.message,
  });

  final AppVersionLabels labels;
  final String currentVersion;
  final String latestVersion;
  final bool isForce;
  final String? message;
  final VoidCallback onUpdate;

  /// Dialog FORCE — không bao giờ tự pop (app kẹt tới khi user update + relaunch).
  static Future<void> showForce(
    BuildContext context, {
    required AppVersionLabels labels,
    required String currentVersion,
    required String latestVersion,
    required VoidCallback onUpdate,
    String? message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(
        labels: labels,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        isForce: true,
        message: message,
        onUpdate: onUpdate,
      ),
    );
  }

  /// Dialog OPTIONAL — trả `true` nếu user chọn cập nhật, `false` nếu để sau.
  static Future<bool> showOptional(
    BuildContext context, {
    required AppVersionLabels labels,
    required String currentVersion,
    required String latestVersion,
    required VoidCallback onUpdate,
    String? message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UpdateDialog(
        labels: labels,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        isForce: false,
        message: message,
        onUpdate: onUpdate,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = (message != null && message!.isNotEmpty)
        ? message!
        : (isForce ? labels.forceFallback : labels.optionalFallback);

    return PopScope(
      canPop: !isForce,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isForce ? labels.forceTitle : labels.optionalTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            _VersionRow(
              label: labels.currentLabel,
              version: currentVersion,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            _VersionRow(
              label: labels.latestLabel,
              version: latestVersion,
              color: theme.colorScheme.primary,
              bold: true,
            ),
          ],
        ),
        actions: [
          if (!isForce)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(labels.laterButton),
            ),
          FilledButton(
            onPressed: () {
              onUpdate();
              if (!isForce) Navigator.of(context).pop(true);
            },
            child: Text(labels.updateButton),
          ),
        ],
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.label,
    required this.version,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String version;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:', style: TextStyle(color: color, fontSize: 13)),
        Text(
          version,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
