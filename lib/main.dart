import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/config/router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';
import 'ui/features/auth/view_models/auth_notifier.dart';

void main() {
  runApp(const MainAppRoot());
}

class MainAppRoot extends StatelessWidget {
  const MainAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ProxyProvider<AuthService, AuthRepository>(
          update: (_, service, _) => AuthRepository(authService: service),
        ),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Template Androzon',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
