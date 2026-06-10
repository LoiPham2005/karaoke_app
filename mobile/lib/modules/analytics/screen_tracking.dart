// Dùng cho màn hình KHÔNG đi qua route (tab page, bottom sheet...):
//   → Thay StatefulWidget  bằng StatefulLoggableWidget
//   → Thay StatelessWidget bằng StatelessLoggableWidget
// Màn hình đi qua GoRouter được track tự động qua AppRoutesObserver.

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_base/core/base/di/injection.dart';
import 'package:flutter_base/modules/analytics/analytics_service.dart';

void _trackScreen(String name) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    getIt<AnalyticsService>().logScreenView(screenName: name);
  });
}

// ──────────────────────────────────────────────────────────────

/// Thay [StatefulWidget] bằng widget này để tự động log screen view
/// khi widget mount (phù hợp cho tab page / bottom sheet / dialog).
abstract class StatefulLoggableWidget extends StatefulWidget {
  const StatefulLoggableWidget({super.key});

  @override
  StatefulElement createElement() {
    _trackScreen(runtimeType.toString());
    return StatefulElement(this);
  }
}

// ──────────────────────────────────────────────────────────────

/// Thay [StatelessWidget] bằng widget này để tự động log screen view.
abstract class StatelessLoggableWidget extends StatelessWidget {
  const StatelessLoggableWidget({super.key});

  @override
  StatelessElement createElement() {
    _trackScreen(runtimeType.toString());
    return StatelessElement(this);
  }
}
