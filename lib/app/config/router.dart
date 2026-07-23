import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/views/splash_view.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/auth/presentation/views/pre_login_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/role_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/main_nav/presentation/views/main_nav_view.dart';
import '../../features/chat/presentation/views/chat_room_view.dart';
import '../../features/chat/presentation/views/room_detail_view.dart';
import '../../features/chat/presentation/views/chat_anon_matching_view.dart';
import '../../features/chat/presentation/views/chat_anon_room_view.dart';
part 'router.g.dart';

/// Disini urusan navigation
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: $appRoutes,
);

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashView();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const OnboardingView();
}

@TypedGoRoute<PreLoginRoute>(path: '/pre_login')
class PreLoginRoute extends GoRouteData with $PreLoginRoute {
  const PreLoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const PreLoginView();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginView();
}

@TypedGoRoute<RoleRoute>(path: '/role')
class RoleRoute extends GoRouteData with $RoleRoute {
  const RoleRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const RoleView();
}

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute({this.isKonselor});
  final bool? isKonselor;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RegisterView(isKonselor: isKonselor ?? false);
  }
}

@TypedGoRoute<MainRoute>(path: '/main')
class MainRoute extends GoRouteData with $MainRoute {
  const MainRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MainNavView();
}

@TypedGoRoute<ChatRoomRoute>(path: '/chat_room')
class ChatRoomRoute extends GoRouteData with $ChatRoomRoute {
  const ChatRoomRoute({this.counselorName = 'Konselor', this.isOnline = false});
  final String counselorName;
  final bool isOnline;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatRoomView(
      counselorName: counselorName,
      isOnline: isOnline,
    );
  }
}

@TypedGoRoute<RoomDetailRoute>(path: '/room_detail')
class RoomDetailRoute extends GoRouteData with $RoomDetailRoute {
  const RoomDetailRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const RoomDetailView();
}

@TypedGoRoute<ChatAnonMatchingRoute>(path: '/chat_anon_matching')
class ChatAnonMatchingRoute extends GoRouteData with $ChatAnonMatchingRoute {
  const ChatAnonMatchingRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const ChatAnonMatchingView();
}

@TypedGoRoute<ChatAnonRoomRoute>(path: '/chat_anon_room')
class ChatAnonRoomRoute extends GoRouteData with $ChatAnonRoomRoute {
  const ChatAnonRoomRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const ChatAnonRoomView();
}
