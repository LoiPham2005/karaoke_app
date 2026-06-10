import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../models/ad_placements.dart';
import '../services/ad_manager.dart';

/// Gắn vào MaterialApp để theo dõi vòng đời.
/// Tự động hiển thị App Open ad khi app resume từ background.
@lazySingleton
class AdLifecycleObserver extends WidgetsBindingObserver {
  AdLifecycleObserver(this._adManager);

  final AdManager _adManager;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _adManager.showAppOpen(AppOpenPlacement.resume);
    }
  }
}
