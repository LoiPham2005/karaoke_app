import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:karaoke/features/auth/presentation/pages/login_page.dart';
import 'package:karaoke/features/auth/presentation/pages/register_page.dart';
import 'package:karaoke/features/category/presentation/pages/category_page.dart';
import 'package:karaoke/features/main/presentation/pages/main_page.dart';
import 'package:karaoke/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:karaoke/features/player/presentation/pages/player_page.dart';
import 'package:karaoke/features/playlist/presentation/pages/playlist_detail_page.dart';
import 'package:karaoke/features/premium/presentation/pages/premium_page.dart';
import 'package:karaoke/features/queue/presentation/pages/queue_page.dart';
import 'package:karaoke/features/settings/presentation/pages/settings_page.dart';
import 'package:karaoke/features/song/presentation/pages/song_detail_page.dart';
import 'package:karaoke/features/splash/presentation/pages/splash_page.dart';

part 'app_router.gr.dart';

/// Router chính của app (auto_route). MainPage tự quản bottom-nav nội bộ
/// (IndexedStack) nên KHÔNG cần AutoTabsRouter.
@LazySingleton()
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // ── Splash & Onboarding ───────────────────────────────────
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),

    // ── Auth ──────────────────────────────────────────────────
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),

    // ── Main (bottom-nav nội bộ) ──────────────────────────────
    AutoRoute(page: MainRoute.page, path: '/main'),

    // ── Song / Player / Playlist ──────────────────────────────
    AutoRoute(page: SongDetailRoute.page, path: '/song/:id'),
    AutoRoute(page: PlayerRoute.page, path: '/play/:id'),
    AutoRoute(page: PlaylistDetailRoute.page, path: '/playlist/:id'),
    AutoRoute(page: QueueRoute.page, path: '/queue'),
    AutoRoute(page: CategoryRoute.page, path: '/category/:slug'),

    // ── Settings & Premium ────────────────────────────────────
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: PremiumRoute.page, path: '/premium'),
  ];
}
