import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../../core/theme/app_text_styles.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          String username = 'Guest';
          String email = '';

          if (state is AuthSuccess) {
            username = state.username;
            email = state.email;
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    size: 100,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Selamat Datang,',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    username,
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      context.go('/login');
                    },
                    child: const Text('Keluar Akun'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
