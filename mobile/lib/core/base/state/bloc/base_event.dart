// ════════════════════════════════════════════════════════════
// 📁 lib/core/state/base_event.dart
// ════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';

/// Base class cho tất cả Events trong BLoC pattern
abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object?> get props => [];
}
