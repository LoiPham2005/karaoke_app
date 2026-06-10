import 'package:flutter/material.dart';

class AppUpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final bool isMandatory;
  final String? message;
  final String? customUrl;
  final VoidCallback onUpdate;
  final VoidCallback onExit;

  const AppUpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.isMandatory,
    this.message,
    this.customUrl,
    required this.onUpdate,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isMandatory,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update_rounded, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isMandatory ? '🚨 Cập Nhật Bắt Buộc' : '🎉 Phiên Bản Mới!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Version info
              Text(
                'Phiên bản hiện tại: $currentVersion',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                'Phiên bản mới: $latestVersion',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                message ??
                    (isMandatory
                        ? 'Bạn cần cập nhật ứng dụng lên phiên bản mới nhất để tiếp tục sử dụng.'
                        : 'Ứng dụng đã có phiên bản mới với nhiều tính năng và cải tiến. Cập nhật ngay để trải nghiệm tốt nhất!'),
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Exit button (chỉ hiện khi force update)
                  if (isMandatory)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onExit,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: const Text(
                          'Thoát',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  // Later button (chỉ hiện khi optional update)
                  if (!isMandatory)
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Để sau',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Update button
                  Expanded(
                    flex: isMandatory ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: onUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cập nhật ngay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
