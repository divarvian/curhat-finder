import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/features/onboarding/views/onboarding_view.dart';
import '../../ui/features/home/views/home_view.dart';
import '../../ui/features/counter_provider/views/provider_counter_view.dart';
import '../../ui/features/counter_riverpod/views/riverpod_counter_view.dart';
import '../../ui/features/counter_bloc/views/bloc_counter_view.dart';

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  routes: <RouteBase>[
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) =>
          const OnboardingView(),
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => 
          const HomeView(),
    ),
    GoRoute(
      path: '/provider',
      builder: (BuildContext context, GoRouterState state) =>
          const ProviderCounterView(),
    ),
    GoRoute(
      path: '/riverpod',
      builder: (BuildContext context, GoRouterState state) =>
          const RiverpodCounterView(),
    ),
    GoRoute(
      path: '/bloc',
      builder: (BuildContext context, GoRouterState state) =>
          const BlocCounterView(),
    ),
  ],
);
