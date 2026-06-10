// ════════════════════════════════════════════════════════════════
// 📁 Typed Routes Definition cho Karaoke App
// ════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_base/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_base/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_base/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_base/features/category/presentation/pages/category_page.dart';
import 'package:flutter_base/features/main/presentation/pages/main_page.dart';
import 'package:flutter_base/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_base/features/player/presentation/pages/player_page.dart';
import 'package:flutter_base/features/playlist/presentation/pages/playlist_detail_page.dart';
import 'package:flutter_base/features/premium/presentation/pages/premium_page.dart';
import 'package:flutter_base/features/queue/presentation/pages/queue_page.dart';
import 'package:flutter_base/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_base/features/song/presentation/pages/song_detail_page.dart';
import 'package:flutter_base/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

// ─── Splash & Onboarding ────────────────────────────────────────
@TypedGoRoute<SplashRoute>(path: RouteNames.splash)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

@TypedGoRoute<OnboardingRoute>(path: RouteNames.onboarding)
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const OnboardingPage();
}

// ─── Auth ───────────────────────────────────────────────────────
@TypedGoRoute<LoginRoute>(path: RouteNames.login)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

@TypedGoRoute<RegisterRoute>(path: RouteNames.register)
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const RegisterPage();
}

@TypedGoRoute<ForgotPasswordRoute>(path: RouteNames.forgotPassword)
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const ForgotPasswordPage();
}

// ─── Main shell ─────────────────────────────────────────────────
@TypedGoRoute<MainRoute>(path: RouteNames.main)
class MainRoute extends GoRouteData with $MainRoute {
  const MainRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MainPage();
}

@TypedGoRoute<HomeRoute>(path: RouteNames.home)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MainPage();
}

@TypedGoRoute<SearchRoute>(path: RouteNames.search)
class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MainPage();
}

@TypedGoRoute<LibraryRoute>(path: RouteNames.library)
class LibraryRoute extends GoRouteData with $LibraryRoute {
  const LibraryRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MainPage();
}

@TypedGoRoute<ProfileRoute>(path: RouteNames.profile)
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MainPage();
}

// ─── Song / Player / Playlist ───────────────────────────────────
@TypedGoRoute<SongDetailRoute>(path: RouteNames.songDetail)
class SongDetailRoute extends GoRouteData with $SongDetailRoute {
  const SongDetailRoute({required this.id});
  final String id;
  @override
  Widget build(BuildContext context, GoRouterState state) => SongDetailPage(id: id);
}

@TypedGoRoute<PlayerRoute>(path: RouteNames.player)
class PlayerRoute extends GoRouteData with $PlayerRoute {
  const PlayerRoute({required this.id});
  final String id;
  @override
  Widget build(BuildContext context, GoRouterState state) => PlayerPage(id: id);
}

@TypedGoRoute<PlaylistDetailRoute>(path: RouteNames.playlistDetail)
class PlaylistDetailRoute extends GoRouteData with $PlaylistDetailRoute {
  const PlaylistDetailRoute({required this.id});
  final String id;
  @override
  Widget build(BuildContext context, GoRouterState state) => PlaylistDetailPage(id: id);
}

@TypedGoRoute<QueueRoute>(path: RouteNames.queue)
class QueueRoute extends GoRouteData with $QueueRoute {
  const QueueRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const QueuePage();
}

@TypedGoRoute<CategoryRoute>(path: RouteNames.category)
class CategoryRoute extends GoRouteData with $CategoryRoute {
  const CategoryRoute({required this.slug});
  final String slug;
  @override
  Widget build(BuildContext context, GoRouterState state) => CategoryPage(slug: slug);
}

// ─── Settings & Premium ─────────────────────────────────────────
@TypedGoRoute<SettingsRoute>(path: RouteNames.settings)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SettingsPage();
}

@TypedGoRoute<PremiumRoute>(path: RouteNames.premium)
class PremiumRoute extends GoRouteData with $PremiumRoute {
  const PremiumRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const PremiumPage();
}
