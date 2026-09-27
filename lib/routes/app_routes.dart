import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/auth/login_screen.dart';
import '../presentation/owner/owner_dashboard_screen.dart';
import '../presentation/owner/owner_drivers_screen.dart';
import '../presentation/owner/owner_payments_screen.dart';
import '../presentation/driver/driver_home_screen.dart';
import '../presentation/fleet_map_screen/fleet_map_screen.dart';
import '../widgets/owner_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String dashboardScreen = '/dashboard-screen';
  static const String fleetMapScreen = '/fleet-map-screen';
  static const String driversScreen = '/drivers-screen';
  static const String paymentsScreen = '/payments-screen';
  static const String driverHome = '/driver-home';
}

String _getInitialLocation() {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return AppRoutes.login;
  final role = user.userMetadata?['role'] as String?;
  if (role == 'propietaria') return AppRoutes.dashboardScreen;
  return AppRoutes.driverHome;
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoginPage =
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.initial;

    if (user == null && !isLoginPage) {
      return AppRoutes.login;
    }
    if (user != null && isLoginPage) {
      final role = user.userMetadata?['role'] as String?;
      if (role == 'propietaria') return AppRoutes.dashboardScreen;
      return AppRoutes.driverHome;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.initial,
      redirect: (context, state) => _getInitialLocation(),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    // Driver route (standalone, no bottom nav)
    GoRoute(
      path: AppRoutes.driverHome,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DriverHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    // Owner routes with bottom nav shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return OwnerScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboardScreen,
              builder: (context, state) => const OwnerDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.fleetMapScreen,
              builder: (context, state) => const FleetMapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.driversScreen,
              builder: (context, state) => const OwnerDriversScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.paymentsScreen,
              builder: (context, state) => const OwnerPaymentsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
