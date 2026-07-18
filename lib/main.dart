import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/config/router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';
import 'ui/features/auth/bloc/auth_cubit.dart';

void main() {
  runApp(const MainAppRoot());
}

class MainAppRoot extends StatelessWidget {
  const MainAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            authService: context.read<AuthService>(),
          ),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(
          authRepository: context.read<AuthRepository>(),
        ),
        child: const AppContent(),
      ),
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
