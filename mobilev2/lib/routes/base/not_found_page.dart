import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:karaoke/routes/config/app_router.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 12),
            const Text('Trang không tồn tại'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.router.replaceAll([const MainRoute()]),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
