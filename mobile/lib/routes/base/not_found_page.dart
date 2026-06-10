import 'package:flutter/material.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:go_router/go_router.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text('404 - Không tìm thấy trang', style: TextStyle(fontSize: 20)),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error.toString(), style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.main),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
