// 📁 lib/modules/app_config/pages/app_config_debug_page.dart
//
// Page debug — hiển thị toàn bộ giá trị AppConfig hiện tại từ Firebase
// Remote Config. Listen `ValueNotifier<AppConfig>` để reactive khi remote
// config push update.
import 'package:flutter/material.dart';

import '../../../routes/base/route_annotation.dart';
import '../models/app_config.dart';
import '../services/app_config_service.dart';

// @route: /app-config-debug [Debug]
@route
class AppConfigDebugPage extends StatelessWidget {
  const AppConfigDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = appConfigService;
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Config (Debug)'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => service.initialize(),
          ),
        ],
      ),
      body: ValueListenableBuilder<AppConfig>(
        valueListenable: service.config,
        builder: (context, config, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: '📦 Cập nhật',
                icon: Icons.system_update,
                children: [
                  _Row(label: 'Phiên bản mới nhất', value: config.latestVersion),
                  _Row(label: 'Phiên bản tối thiểu', value: config.minVersion),
                  _Row(label: 'Store URL', value: config.storeUrl, monospace: true),
                  _Row(
                    label: 'Force update (vs 1.0.0)',
                    value: config.needsForceUpdate('1.0.0').toString(),
                  ),
                  _Row(
                    label: 'Soft update (vs 1.0.0)',
                    value: config.hasSoftUpdate('1.0.0').toString(),
                  ),
                ],
              ),
              _Section(
                title: '📢 Thông báo',
                icon: Icons.campaign_outlined,
                children: [
                  _Row(label: 'Bật', value: config.noticeEnabled.toString()),
                  _Row(label: 'Tiêu đề', value: config.noticeTitle),
                  _Row(label: 'Nội dung', value: config.noticeBody),
                  _Row(label: 'URL', value: config.noticeUrl, monospace: true),
                  _Row(
                    label: 'Có announcement',
                    value: config.hasAnnouncement.toString(),
                  ),
                  _Row(
                    label: 'Có action URL',
                    value: config.hasAnnouncementAction.toString(),
                  ),
                ],
              ),
              _Section(
                title: '🛠 Bảo trì',
                icon: Icons.build_circle_outlined,
                children: [
                  _Row(label: 'Maintenance', value: config.maintenance.toString()),
                  _Row(label: 'Message', value: config.maintenanceMessage),
                ],
              ),
              _Section(
                title: '⚖️ Pháp lý',
                icon: Icons.gavel_outlined,
                children: [
                  _Row(label: 'Policy URL', value: config.policyUrl, monospace: true),
                  _Row(label: 'Terms URL', value: config.termsUrl, monospace: true),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Source: Firebase Remote Config\n'
                  'Pull-to-refresh không có — bấm icon refresh ở góc.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  const _Row({required this.label, required this.value, this.monospace = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final display = value.isEmpty ? '—' : value;
    final isEmpty = value.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              display,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: monospace ? 'monospace' : null,
                color: isEmpty
                    ? scheme.onSurface.withValues(alpha: 0.4)
                    : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
