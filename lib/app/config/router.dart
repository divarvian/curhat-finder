import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/features/splash/views/splash_view.dart';
import '../../ui/features/onboarding/views/onboarding_view.dart';
import '../../ui/features/auth/views/pre_login_view.dart';
import '../../ui/features/auth/views/login_view.dart';
import '../../ui/features/auth/views/role_view.dart';
import '../../ui/features/auth/views/register_view.dart';
import '../../ui/features/dashboard/views/dashboard_view.dart';

/// Disini urusan navigation
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) => const SplashView(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) => const OnboardingView(),
    ),
    GoRoute(
      path: '/pre_login',
      builder: (BuildContext context, GoRouterState state) => const PreLoginView(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginView(),
    ),
    GoRoute(
      path: '/role',
      builder: (BuildContext context, GoRouterState state) => const RoleView(),
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) => const RegisterView(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) => const DashboardView(),
    ),
  ],
);
