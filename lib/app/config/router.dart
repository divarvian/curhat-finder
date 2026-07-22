import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/features/splash/views/splash_view.dart';
import '../../ui/features/onboarding/views/onboarding_view.dart';
import '../../ui/features/auth/views/pre_login_view.dart';
import '../../ui/features/auth/views/login_view.dart';
import '../../ui/features/auth/views/role_view.dart';
import '../../ui/features/auth/views/register_view.dart';
import '../../ui/features/main_nav/views/main_nav_view.dart';
import '../../ui/features/chat/views/chat_room_view.dart';
import '../../ui/features/chat/views/room_detail_view.dart';
import '../../ui/features/chat/views/chat_anon_matching_view.dart';
import '../../ui/features/chat/views/chat_anon_room_view.dart';

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
      builder: (BuildContext context, GoRouterState state) {
        final isKonselor = (state.extra as int?) == 1;
        return RegisterView(isKonselor: isKonselor);
      },
    ),
    GoRoute(
      path: '/main',
      builder: (BuildContext context, GoRouterState state) => const MainNavView(),
    ),
    GoRoute(
      path: '/chat_room',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>? ?? {};
        return ChatRoomView(
          counselorName: extras['name'] as String? ?? 'Konselor',
          isOnline: extras['isOnline'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: '/room_detail',
      builder: (BuildContext context, GoRouterState state) => const RoomDetailView(),
    ),
    GoRoute(
      path: '/chat_anon_matching',
      builder: (BuildContext context, GoRouterState state) => const ChatAnonMatchingView(),
    ),
    GoRoute(
      path: '/chat_anon_room',
      builder: (BuildContext context, GoRouterState state) => const ChatAnonRoomView(),
    ),
  ],
);
