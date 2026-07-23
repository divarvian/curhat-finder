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
  );

  ChatRoomRoute get _self => this as ChatRoomRoute;

  @override
  String get location => GoRouteData.$location(
    '/chat_room',
    queryParams: {
      if (_self.counselorName != 'Konselor')
        'counselor-name': _self.counselorName,
      if (_self.isOnline != false) 'is-online': _self.isOnline.toString(),
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
      const RoomDetailRoute();

  @override
  String get location => GoRouteData.$location('/room_detail');

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
      const ChatAnonMatchingRoute();

  @override
  String get location => GoRouteData.$location('/chat_anon_matching');

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
      const ChatAnonRoomRoute();

  @override
  String get location => GoRouteData.$location('/chat_anon_room');

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
