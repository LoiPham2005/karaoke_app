// ════════════════════════════════════════════════════════════════
// 📁 lib/core/state/bloc/bloc.dart
// ════════════════════════════════════════════════════════════════

/// 🎯 BLOC BASE CONFIGURATION
///
/// Export tất cả utilities, extensions, và helpers cho Bloc
///
/// Usage:
/// ```dart
/// import 'package:flutter_base/core/state/bloc/bloc.dart';
/// ```

export '../../errors/failures.dart';
// Re-export commonly used types
export '../../errors/result.dart';
export '../base_status.dart';
// Core Bloc
export 'package:flutter_bloc/flutter_bloc.dart';

// Base classes
export 'base_bloc.dart';
export 'base_event.dart';
export 'base_state.dart';
// Extensions
export 'auto_bloc/auto_bloc.dart';
// Listeners
export 'bloc_listeners.dart';
