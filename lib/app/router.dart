import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/auth_repository.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/admin_profile_screen.dart';
import '../features/admin/presentation/edit_rate_screen.dart';
import '../features/admin/presentation/preview_rate_screen.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/calculator/presentation/calculator_screen.dart';
import '../features/exchange_rates/presentation/rate_details_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/language_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final isGoingToAdmin = state.matchedLocation.startsWith('/admin') &&
          state.matchedLocation != '/admin/login';

      // Protected Admin route guard
      if (isGoingToAdmin) {
        if (!authState.isAuthenticated || !authState.isAuthorizedAdmin) {
          return '/admin/login';
        }
      }

      // If already logged in as authorized admin and navigating to /admin/login, forward to dashboard
      if (state.matchedLocation == '/admin/login' &&
          authState.isAuthenticated &&
          authState.isAuthorizedAdmin) {
        return '/admin/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const CalculatorScreen(),
      ),
      GoRoute(
        path: '/rate-details',
        builder: (context, state) => const RateDetailsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageScreen(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/edit-rates',
        builder: (context, state) => const EditRateScreen(),
      ),
      GoRoute(
        path: '/admin/preview-rates',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final buy = extra?['buyRate'] as Decimal? ?? Decimal.parse('26300');
          final sell = extra?['sellRate'] as Decimal? ?? Decimal.parse('26500');
          return PreviewRateScreen(newBuyRate: buy, newSellRate: sell);
        },
      ),
      GoRoute(
        path: '/admin/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => const AdminProfileScreen(),
      ),
    ],
  );
});
