import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/features/onboarding/views/onboarding_view.dart';
import '../../ui/features/auth/views/login_view.dart';
import '../../ui/features/auth/views/register_view.dart';
import '../../ui/features/dashboard/views/dashboard_view.dart';


final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  routes: <RouteBase>[
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) => const OnboardingView(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginView(),
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
