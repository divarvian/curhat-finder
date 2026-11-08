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
import '../../features/chat/domain/room_model.dart';
import '../../features/auth/presentation/views/counselor_pending_view.dart';
import '../../features/counselor/presentation/views/counselor_main_nav_view.dart';
import '../../features/counselor/presentation/views/counselor_chat_room_view.dart';
import '../../features/profile/presentation/views/settings_view.dart';
import '../../features/beranda/presentation/views/tips_view.dart';
import '../../features/beranda/presentation/views/tip_detail_view.dart';
import '../../features/beranda/domain/tip_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
part 'router.g.dart';

/// Disini urusan navigation
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: $appRoutes,
  redirect: (BuildContext context, GoRouterState state) {
    final publicRoutes = [
      '/splash',
      '/onboarding',
      '/pre_login',
      '/login',
      '/role',
      '/register',
      '/counselor_pending',
    ];

    final isPublic = publicRoutes.contains(state.matchedLocation);
    final session = SupabaseService.client.auth.currentSession;
    final hasSession = session != null;

    if (!hasSession && !isPublic) {
      return '/login';
    }

    if (hasSession) {
      if (state.matchedLocation == '/splash' || state.matchedLocation == '/onboarding') {
        return null;
      }

      String? role;
      bool? isVerified;

      // Prioritas 1: Ambil dari state in-memory AuthProvider jika tersedia di context
      try {
        final container = ProviderScope.containerOf(context, listen: false);
        final authState = container.read(authProvider);
        if (authState.isLoggedIn && authState.role != null) {
          role = authState.role?.toLowerCase();
          isVerified = authState.isVerified;
        }
      } catch (_) {
        // Fallback jika context belum terikat ProviderScope
      }

      // Prioritas 2: Ambil dari cache static AuthNotifier
      role ??= AuthNotifier.lastKnownRole?.toLowerCase();
      isVerified ??= AuthNotifier.lastKnownIsVerified;

      // Prioritas 3: Fallback ke metadata sesi Supabase jika data belum termuat
      if (role == null) {
        final userMetadata = session.user.userMetadata ?? {};
        role = (userMetadata['role'] as String?)?.toLowerCase() ?? 'mahasiswa';
        isVerified ??= (userMetadata['is_verified'] as bool?) ?? (role != 'konselor');
      }

      final currentLocation = state.matchedLocation;

      // 1. Konselor Pending dialihkan ke layar pending
      if (role == 'konselor' && isVerified == false) {
        if (currentLocation != '/counselor_pending') {
          return '/counselor_pending';
        }
        return null;
      }

      // 2. Mahasiswa dicegah mengakses dashboard & chat konselor
      if (role == 'mahasiswa' && currentLocation.startsWith('/counselor_')) {
        return '/main';
      }

      // 3. Konselor terverifikasi yang mengakses root /main diarahkan ke /counselor_main
      if (role == 'konselor' && isVerified == true && currentLocation == '/main') {
        return '/counselor_main';
      }

      // 4. Konselor terverifikasi yang berada di /counselor_pending diarahkan ke /counselor_main
      if (role == 'konselor' && isVerified == true && currentLocation == '/counselor_pending') {
        return '/counselor_main';
      }
    }

    return null;
  },
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
  const ChatRoomRoute({
    this.counselorName = 'Konselor',
    this.isOnline = false,
    this.sessionId = '',
    this.counselorAvatarUrl,
  });
  final String counselorName;
  final bool isOnline;
  final String sessionId;
  final String? counselorAvatarUrl;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatRoomView(
      counselorName: counselorName,
      isOnline: isOnline,
      sessionId: sessionId,
      counselorAvatarUrl: counselorAvatarUrl,
    );
  }
}

@TypedGoRoute<RoomDetailRoute>(path: '/room_detail')
class RoomDetailRoute extends GoRouteData with $RoomDetailRoute {
  const RoomDetailRoute({this.roomId = ''});
  final String roomId;
  @override
  Widget build(BuildContext context, GoRouterState state) => RoomDetailView(
        roomId: roomId,
        room: state.extra as RoomModel?,
      );
}

@TypedGoRoute<ChatAnonMatchingRoute>(path: '/chat_anon_matching')
class ChatAnonMatchingRoute extends GoRouteData with $ChatAnonMatchingRoute {
  const ChatAnonMatchingRoute({this.mode = 'Cuma mau didengar'});
  final String mode;
  @override
  Widget build(BuildContext context, GoRouterState state) => ChatAnonMatchingView(mode: mode);
}

@TypedGoRoute<ChatAnonRoomRoute>(path: '/chat_anon_room')
class ChatAnonRoomRoute extends GoRouteData with $ChatAnonRoomRoute {
  const ChatAnonRoomRoute({this.sessionId = '', this.mode = 'Cuma mau didengar'});
  final String sessionId;
  final String mode;
  @override
  Widget build(BuildContext context, GoRouterState state) => ChatAnonRoomView(sessionId: sessionId, mode: mode);
}

@TypedGoRoute<CounselorMainRoute>(path: '/counselor_main')
class CounselorMainRoute extends GoRouteData with $CounselorMainRoute {
  const CounselorMainRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const CounselorMainNavView();
}

@TypedGoRoute<CounselorChatRoomRoute>(path: '/counselor_chat_room')
class CounselorChatRoomRoute extends GoRouteData with $CounselorChatRoomRoute {
  const CounselorChatRoomRoute({
    this.sessionId = '',
    this.studentTitle = 'Anonym - FILKOM',
  });
  final String sessionId;
  final String studentTitle;

  @override
  Widget build(BuildContext context, GoRouterState state) => CounselorChatRoomView(
        sessionId: sessionId,
        studentTitle: studentTitle,
      );
}

@TypedGoRoute<CounselorPendingRoute>(path: '/counselor_pending')
class CounselorPendingRoute extends GoRouteData with $CounselorPendingRoute {
  const CounselorPendingRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const CounselorPendingView();
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SettingsView();
}

@TypedGoRoute<TipsRoute>(path: '/tips')
class TipsRoute extends GoRouteData with $TipsRoute {
  const TipsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const TipsView();
}

@TypedGoRoute<TipDetailRoute>(path: '/tip_detail')
class TipDetailRoute extends GoRouteData with $TipDetailRoute {
  const TipDetailRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => TipDetailView(
        tip: state.extra as TipModel?,
      );
}
