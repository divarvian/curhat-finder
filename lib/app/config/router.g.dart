// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $onboardingRoute,
  $preLoginRoute,
  $loginRoute,
  $roleRoute,
  $registerRoute,
  $mainRoute,
  $chatRoomRoute,
  $roomDetailRoute,
  $chatAnonMatchingRoute,
  $chatAnonRoomRoute,
  $counselorMainRoute,
  $counselorChatRoomRoute,
  $counselorPendingRoute,
];

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/splash',
  hasOverriddenOnExit: false,
  factory: $SplashRoute._fromState,
);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/splash');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingRoute => GoRouteData.$route(
  path: '/onboarding',
  hasOverriddenOnExit: false,
  factory: $OnboardingRoute._fromState,
);

mixin $OnboardingRoute on GoRouteData {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  @override
  String get location => GoRouteData.$location('/onboarding');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $preLoginRoute => GoRouteData.$route(
  path: '/pre_login',
  hasOverriddenOnExit: false,
  factory: $PreLoginRoute._fromState,
);

mixin $PreLoginRoute on GoRouteData {
  static PreLoginRoute _fromState(GoRouterState state) => const PreLoginRoute();

  @override
  String get location => GoRouteData.$location('/pre_login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',
  hasOverriddenOnExit: false,
  factory: $LoginRoute._fromState,
);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $roleRoute => GoRouteData.$route(
  path: '/role',
  hasOverriddenOnExit: false,
  factory: $RoleRoute._fromState,
);

mixin $RoleRoute on GoRouteData {
  static RoleRoute _fromState(GoRouterState state) => const RoleRoute();

  @override
  String get location => GoRouteData.$location('/role');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $registerRoute => GoRouteData.$route(
  path: '/register',
  hasOverriddenOnExit: false,
  factory: $RegisterRoute._fromState,
);

mixin $RegisterRoute on GoRouteData {
  static RegisterRoute _fromState(GoRouterState state) => RegisterRoute(
    isKonselor: _$convertMapValue(
      'is-konselor',
      state.uri.queryParameters,
      _$boolConverter,
    ),
  );

  RegisterRoute get _self => this as RegisterRoute;

  @override
  String get location => GoRouteData.$location(
    '/register',
    queryParams: {
      if (_self.isKonselor != null) 'is-konselor': _self.isKonselor!.toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

RouteBase get $mainRoute => GoRouteData.$route(
  path: '/main',
  hasOverriddenOnExit: false,
  factory: $MainRoute._fromState,
);

mixin $MainRoute on GoRouteData {
  static MainRoute _fromState(GoRouterState state) => const MainRoute();

  @override
  String get location => GoRouteData.$location('/main');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatRoomRoute => GoRouteData.$route(
  path: '/chat_room',
  hasOverriddenOnExit: false,
  factory: $ChatRoomRoute._fromState,
);

mixin $ChatRoomRoute on GoRouteData {
  static ChatRoomRoute _fromState(GoRouterState state) => ChatRoomRoute(
    counselorName: state.uri.queryParameters['counselor-name'] ?? 'Konselor',
    isOnline:
        _$convertMapValue(
          'is-online',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
    sessionId: state.uri.queryParameters['session-id'] ?? '',
  );

  ChatRoomRoute get _self => this as ChatRoomRoute;

  @override
  String get location => GoRouteData.$location(
    '/chat_room',
    queryParams: {
      if (_self.counselorName != 'Konselor')
        'counselor-name': _self.counselorName,
      if (_self.isOnline != false) 'is-online': _self.isOnline.toString(),
      if (_self.sessionId.isNotEmpty) 'session-id': _self.sessionId,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $roomDetailRoute => GoRouteData.$route(
  path: '/room_detail',
  hasOverriddenOnExit: false,
  factory: $RoomDetailRoute._fromState,
);

mixin $RoomDetailRoute on GoRouteData {
  static RoomDetailRoute _fromState(GoRouterState state) =>
      RoomDetailRoute(
        roomId: state.uri.queryParameters['room-id'] ?? '',
      );

  RoomDetailRoute get _self => this as RoomDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/room_detail',
        queryParams: {
          if (_self.roomId.isNotEmpty) 'room-id': _self.roomId,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatAnonMatchingRoute => GoRouteData.$route(
  path: '/chat_anon_matching',
  hasOverriddenOnExit: false,
  factory: $ChatAnonMatchingRoute._fromState,
);

mixin $ChatAnonMatchingRoute on GoRouteData {
  static ChatAnonMatchingRoute _fromState(GoRouterState state) =>
      ChatAnonMatchingRoute(
        mode: state.uri.queryParameters['mode'] ?? 'Cuma mau didengar',
      );

  ChatAnonMatchingRoute get _self => this as ChatAnonMatchingRoute;

  @override
  String get location => GoRouteData.$location(
        '/chat_anon_matching',
        queryParams: {
          if (_self.mode != 'Cuma mau didengar') 'mode': _self.mode,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatAnonRoomRoute => GoRouteData.$route(
  path: '/chat_anon_room',
  hasOverriddenOnExit: false,
  factory: $ChatAnonRoomRoute._fromState,
);

mixin $ChatAnonRoomRoute on GoRouteData {
  static ChatAnonRoomRoute _fromState(GoRouterState state) =>
      ChatAnonRoomRoute(
        sessionId: state.uri.queryParameters['session-id'] ?? '',
        mode: state.uri.queryParameters['mode'] ?? 'Cuma mau didengar',
      );

  ChatAnonRoomRoute get _self => this as ChatAnonRoomRoute;

  @override
  String get location => GoRouteData.$location(
        '/chat_anon_room',
        queryParams: {
          if (_self.sessionId.isNotEmpty) 'session-id': _self.sessionId,
          if (_self.mode != 'Cuma mau didengar') 'mode': _self.mode,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $counselorMainRoute => GoRouteData.$route(
  path: '/counselor_main',
  hasOverriddenOnExit: false,
  factory: $CounselorMainRoute._fromState,
);

mixin $CounselorMainRoute on GoRouteData {
  static CounselorMainRoute _fromState(GoRouterState state) =>
      const CounselorMainRoute();

  @override
  String get location => GoRouteData.$location('/counselor_main');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $counselorChatRoomRoute => GoRouteData.$route(
  path: '/counselor_chat_room',
  hasOverriddenOnExit: false,
  factory: $CounselorChatRoomRoute._fromState,
);

mixin $CounselorChatRoomRoute on GoRouteData {
  static CounselorChatRoomRoute _fromState(GoRouterState state) =>
      CounselorChatRoomRoute(
        sessionId: state.uri.queryParameters['session-id'] ?? '',
        studentTitle:
            state.uri.queryParameters['student-title'] ?? 'Anonym - FILKOM',
      );

  CounselorChatRoomRoute get _self => this as CounselorChatRoomRoute;

  @override
  String get location => GoRouteData.$location(
    '/counselor_chat_room',
    queryParams: {
      if (_self.sessionId.isNotEmpty) 'session-id': _self.sessionId,
      if (_self.studentTitle != 'Anonym - FILKOM')
        'student-title': _self.studentTitle,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $counselorPendingRoute => GoRouteData.$route(
  path: '/counselor_pending',
  hasOverriddenOnExit: false,
  factory: $CounselorPendingRoute._fromState,
);

mixin $CounselorPendingRoute on GoRouteData {
  static CounselorPendingRoute _fromState(GoRouterState state) =>
      const CounselorPendingRoute();

  @override
  String get location => GoRouteData.$location('/counselor_pending');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
