import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/search/search_screen.dart';
import '../../presentation/detail/detail_screen.dart';
import '../../presentation/map/heat_map_screen.dart';
import '../../presentation/favorites/favorites_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/shared/widgets/main_scaffold.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.map,
            name: 'map',
            builder: (context, state) => const HeatMapScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            name: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.detail}/:hash',
        name: 'detail',
        builder: (context, state) {
          final hash = state.pathParameters['hash']!;
          final extra = state.extra as Map<String, dynamic>?;
          return DetailScreen(
            hash: hash,
            heroTag: extra?['heroTag'] as String?,
          );
        },
      ),
    ],
    // Deep link: cazadores://criminal/{hash}
    redirect: (context, state) {
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
}

class AppRoutes {
  AppRoutes._();
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String search = '/search';
  static const String detail = '/criminal';
  static const String map = '/map';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
}
